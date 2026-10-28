import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';

class StudentAssessments extends StatelessWidget {
  const StudentAssessments({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(children: const [
        TabBar(tabs: [Tab(text: 'Devoirs & quiz'), Tab(text: 'Relevé de notes')]),
        Expanded(child: TabBarView(children: [_QuizList(), _Transcript()])),
      ]),
    );
  }
}

class _QuizList extends StatelessWidget {
  const _QuizList();
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final u = s.user!;
    final list = s.myQuizzes;
    if (list.isEmpty) return const EmptyState(Icons.quiz, 'Aucun quiz disponible.');
    return ListView(padding: const EdgeInsets.all(16), children: [
      for (final q in list)
        Builder(builder: (_) {
          final a = s.attemptOf(q.id, u.id);
          final inProgress = a?.status == 'in_progress';
          final expired = !inProgress && q.due.isBefore(DateTime.now());
          final canStart =
              inProgress || (!expired && q.attemptsUsed < q.maxAttempts);
          final (label, color) = switch (a?.status) {
            'in_progress' => ('En cours', AppColors.warn),
            'submitted' => ('En correction', AppColors.warn),
            'graded' => ('${a!.score.toStringAsFixed(1)}/20', AppColors.accent),
            _ => expired
                ? ('Expiré', AppColors.danger)
                : ('À faire', AppColors.primary),
          };
          final deadline =
              q.due.year < 2100 ? ' • avant le ${fmtDate(q.due)}' : '';
          return AppCard(
            onTap: canStart
                ? () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => QuizScreen(quiz: q)))
                : null,
            child: Row(children: [
              IconBadge(Icons.quiz_rounded, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(q.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                      '${s.courseById(q.courseId)?.title ?? ''}$deadline • ${q.attemptsUsed}/${q.maxAttempts} tentative(s)',
                      style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ]),
              ),
              StatusChip(label, color),
            ]),
          );
        }),
    ]);
  }
}

class _Transcript extends StatelessWidget {
  const _Transcript();
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final g = s.gradesOf(s.user!.id);
    final avg = s.averageOf(s.user!.id);
    return ListView(padding: const EdgeInsets.all(16), children: [
      AppCard(
        color: AppColors.primary,
        child: Row(children: [
          const Expanded(
              child: Text('Moyenne générale',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))),
          Text(avg == null ? '-' : '${avg.toStringAsFixed(2)}/20',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
        ]),
      ),
      if (g.isEmpty) const EmptyState(Icons.grade_outlined, 'Aucune note publiée.'),
      for (final e in g)
        AppCard(
          child: Row(children: [
            IconBadge(e.isQuiz ? Icons.quiz_rounded : Icons.edit_note, color: AppColors.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text('${e.courseTitle} • ${fmtDate(e.date)}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ]),
            ),
            Text('${e.value.toStringAsFixed(1)}/20', style: const TextStyle(fontWeight: FontWeight.w800)),
          ]),
        ),
    ]);
  }
}

/// Passage d'un quiz avec surveillance anti-triche (simulée : sortie de l'app).
class QuizScreen extends StatefulWidget {
  final Quiz quiz;
  const QuizScreen({super.key, required this.quiz});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with WidgetsBindingObserver {
  String? _attemptId, _error;
  List<Question> _qs = [];
  List<Set<int>> _sel = [];
  List<TextEditingController> _txt = [];
  int _i = 0, _warnings = 0;
  bool _loading = true, _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  Future<void> _start() async {
    final r = await context.read<AppState>().startAttempt(widget.quiz);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = r.error;
      if (r.attempt != null) {
        _attemptId = r.attempt!.id;
        _qs = r.questions;
        _sel = [for (final _ in _qs) <int>{}];
        _txt = [for (final _ in _qs) TextEditingController()];
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final c in _txt) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) setState(() => _warnings++);
  }

  Future<void> _finish() async {
    setState(() => _sending = true);
    final s = context.read<AppState>();
    final answers = [
      for (var k = 0; k < _qs.length; k++)
        {
          'question': int.parse(_qs[k].id),
          'selected_choices': [
            for (final c in _sel[k]) int.parse(_qs[k].choiceIds[c])
          ],
          'text_answer': _txt[k].text,
        }
    ];
    final err = await s.submitAttempt(_attemptId!, answers);
    if (!mounted) return;
    if (err != null) {
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    final a = s.attempts.where((x) => x.id == _attemptId).firstOrNull;
    final graded = a?.status == 'graded';
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(graded ? 'Quiz corrigé' : 'Réponses envoyées'),
        content: Text(graded
            ? 'Votre note : ${a!.score.toStringAsFixed(1)}/20'
            : 'Vos réponses libres seront corrigées par l\'enseignant.'),
        actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final title = Text(widget.quiz.title, style: const TextStyle(fontSize: 16));
    if (_loading) {
      return Scaffold(
          appBar: AppBar(title: title),
          body: const Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _qs.isEmpty) {
      return Scaffold(
          appBar: AppBar(title: title),
          body: Center(
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_error ?? 'Ce quiz ne contient aucune question.',
                      textAlign: TextAlign.center))));
    }
    final q = _qs[_i];
    final last = _i == _qs.length - 1;
    final multiple = q.type == 'multiple';
    final isText = q.type == 'text';
    final canNext = isText || _sel[_i].isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: title),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.shield_outlined, size: 18, color: AppColors.accent),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('Surveillance anti-triche active • alertes : $_warnings',
                      style: const TextStyle(fontSize: 12))),
            ]),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: (_i + 1) / _qs.length),
          const SizedBox(height: 8),
          Text('Question ${_i + 1} / ${_qs.length}', style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(q.text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                if (multiple)
                  const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text('Plusieurs réponses possibles',
                          style: TextStyle(color: AppColors.muted, fontSize: 12))),
                const SizedBox(height: 16),
                if (isText)
                  TextField(
                      controller: _txt[_i],
                      maxLines: 6,
                      decoration: const InputDecoration(hintText: 'Votre réponse'))
                else
                  for (var k = 0; k < q.options.length; k++)
                    AppCard(
                      color: _sel[_i].contains(k) ? AppColors.primary.withValues(alpha: .1) : Colors.white,
                      onTap: () => setState(() {
                        if (multiple) {
                          _sel[_i].contains(k) ? _sel[_i].remove(k) : _sel[_i].add(k);
                        } else {
                          _sel[_i] = {k};
                        }
                      }),
                      child: Row(children: [
                        Icon(
                            multiple
                                ? (_sel[_i].contains(k) ? Icons.check_box : Icons.check_box_outline_blank)
                                : (_sel[_i].contains(k) ? Icons.radio_button_checked : Icons.radio_button_off),
                            color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(child: Text(q.options[k])),
                      ]),
                    ),
              ]),
            ),
          ),
          Row(children: [
            if (_i > 0)
              Expanded(
                  child: OutlinedButton(
                      onPressed: () => setState(() => _i--), child: const Text('Précédent'))),
            if (_i > 0) const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: !canNext || _sending
                    ? null
                    : (last ? _finish : () => setState(() => _i++)),
                child: Text(_sending ? 'Envoi…' : (last ? 'Terminer' : 'Suivant')),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
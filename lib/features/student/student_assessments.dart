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
          final expired = a == null && q.due.isBefore(DateTime.now());
          final (label, color) = a != null
              ? (a.synced ? ('${a.score.toStringAsFixed(1)}/20', AppColors.accent) : ('En attente de sync', AppColors.warn))
              : expired
                  ? ('Expiré', AppColors.danger)
                  : ('À faire', AppColors.primary);
          return AppCard(
            onTap: a == null && !expired
                ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(quiz: q)))
                : null,
            child: Row(children: [
              IconBadge(Icons.quiz_rounded, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(q.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('${s.courseById(q.courseId)?.title} • avant le ${fmtDate(q.due)}',
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
  late final List<int> _answers = List.filled(widget.quiz.questions.length, -1);
  int _i = 0, _warnings = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) setState(() => _warnings++);
  }

  Future<void> _finish() async {
    final s = context.read<AppState>();
    final a = s.submitQuiz(widget.quiz, _answers, _warnings);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(a.synced ? 'Quiz corrigé' : 'Réponses enregistrées'),
        content: Text(a.synced
            ? 'Votre note : ${a.score.toStringAsFixed(1)}/20'
            : 'Vous êtes hors connexion. Vos réponses seront envoyées et corrigées dès le retour du réseau.'),
        actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.quiz.questions[_i];
    final last = _i == widget.quiz.questions.length - 1;
    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz.title, style: const TextStyle(fontSize: 16))),
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
          LinearProgressIndicator(value: (_i + 1) / widget.quiz.questions.length),
          const SizedBox(height: 8),
          Text('Question ${_i + 1} / ${widget.quiz.questions.length}', style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 8),
          Text(q.text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          for (var k = 0; k < q.options.length; k++)
            AppCard(
              color: _answers[_i] == k ? AppColors.primary.withValues(alpha: .1) : Colors.white,
              onTap: () => setState(() => _answers[_i] = k),
              child: Row(children: [
                Icon(_answers[_i] == k ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(q.options[k])),
              ]),
            ),
          const Spacer(),
          Row(children: [
            if (_i > 0)
              Expanded(
                  child: OutlinedButton(
                      onPressed: () => setState(() => _i--), child: const Text('Précédent'))),
            if (_i > 0) const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _answers[_i] < 0 ? null : (last ? _finish : () => setState(() => _i++)),
                child: Text(last ? 'Terminer' : 'Suivant'),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

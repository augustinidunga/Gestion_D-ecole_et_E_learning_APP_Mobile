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
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(text: 'Devoirs & quiz'),
              Tab(text: 'Relevé de notes'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: const [_QuizList(), _Transcript()],
            ),
          ),
        ],
      ),
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
    if (list.isEmpty) return const EmptyState(Icons.quiz, 'Aucun quiz disponible.', 'Les quiz apparaîtront ici.');
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        for (final q in list)
          Builder(
            builder: (_) {
              final a = s.attemptOf(q.id, u.id);
              final expired = a == null && q.due.isBefore(DateTime.now());
              final (label, color) = a != null
                  ? (a.synced
                      ? ('${a.score.toStringAsFixed(1)}/20', AppColors.accent)
                      : ('En attente de sync', AppColors.warn))
                  : expired
                      ? ('Expiré', AppColors.danger)
                      : ('À faire', AppColors.primary);
              return AppCardElevated(
                margin: const EdgeInsets.only(bottom: 12),
                onTap: a == null && !expired
                    ? () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => QuizScreen(quiz: q)))
                    : null,
                child: Row(
                  children: [
                    IconBadge(Icons.quiz_rounded, color: color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${s.courseById(q.courseId)?.title} • avant le ${fmtDate(q.due)}',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    StatusChip(label, color),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _Transcript extends StatelessWidget {
  const _Transcript();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final g = s.gradesOf(s.user!.id);
    final avg = s.averageOf(s.user!.id);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        AppCard(
          color: AppColors.primary,
          padding: const EdgeInsets.all(18),
          elevation: 0.5,
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Moyenne générale',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                avg == null ? '-' : '${avg.toStringAsFixed(2)}/20',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (g.isEmpty)
          const EmptyState(Icons.grade_outlined, 'Aucune note publiée.',
              'Les notes apparaîtront ici.')
        else
          for (final e in g)
            AppCardElevated(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  IconBadge(
                    e.isQuiz ? Icons.quiz_rounded : Icons.edit_note,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.label,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${e.courseTitle} • ${fmtDate(e.date)}',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${e.value.toStringAsFixed(1)}/20',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        fontSize: 16),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Quiz terminé',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(a.synced
            ? 'Votre note : ${a.score.toStringAsFixed(1)}/20'
            : 'Vous êtes hors connexion. Vos réponses seront envoyées et corrigées dès le retour du réseau.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.quiz.questions[_i];
    final last = _i == widget.quiz.questions.length - 1;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(widget.quiz.title, style: const TextStyle(fontSize: 16)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined,
                      size: 18, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Surveillance active • alertes : $_warnings',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${_i + 1} / ${widget.quiz.questions.length}',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: (_i + 1) / widget.quiz.questions.length,
                        minHeight: 8,
                        backgroundColor: AppColors.border,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              q.text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            ...List.generate(q.options.length, (k) {
              final selected = _answers[_i] == k;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  color: selected
                      ? AppColors.primary.withOpacity(0.08)
                      : Colors.white,
                  onTap: () => setState(() => _answers[_i] = k),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : Colors.white,
                          border: Border.all(
                            color: AppColors.border,
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: selected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Text(q.options[k])),
                    ],
                  ),
                ),
              );
            }),
            const Spacer(),
            Row(
              children: [
                if (_i > 0)
                  Expanded(
                    child: AppFormButton(
                      onPressed: () => setState(() => _i--),
                      text: 'Précédent',
                      expanded: true,
                      color: AppColors.surface,
                      icon: Icons.chevron_left,
                    ),
                  ),
                if (_i > 0) const SizedBox(width: 12),
                Expanded(
                  child: AppFormButton(
                    onPressed: _answers[_i] < 0 ? null : (last ? _finish : () => setState(() => _i++)),
                    text: last ? 'Terminer' : 'Suivant',
                    expanded: true,
                    icon: last ? Icons.check : Icons.chevron_right,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
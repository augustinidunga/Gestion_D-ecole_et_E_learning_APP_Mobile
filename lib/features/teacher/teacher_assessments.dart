import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';

class TeacherAssessments extends StatelessWidget {
  const TeacherAssessments({super.key});

  Future<void> _create(BuildContext context) async {
    final s = context.read<AppState>();
    final head = await askForm(context, 'Nouveau quiz', [
      Fld('course', 'Cours', options: {for (final c in s.myCourses) c.id: c.title}),
      const Fld('title', 'Titre du quiz'),
      const Fld('days', 'Échéance (jours)', number: true),
      const Fld('n', 'Nombre de questions (1 à 5)', number: true),
    ], ok: 'Continuer');
    if (head == null || head['title']!.isEmpty || head['course']!.isEmpty) return;
    final n = (int.tryParse(head['n']!) ?? 1).clamp(1, 5);
    final qs = <Question>[];
    for (var i = 1; i <= n; i++) {
      if (!context.mounted) return;
      final r = await askForm(context, 'Question $i / $n', const [
        Fld('q', 'Énoncé'),
        Fld('a', 'Réponse A'),
        Fld('b', 'Réponse B'),
        Fld('c', 'Réponse C'),
        Fld('ok', 'Bonne réponse', options: {'0': 'A', '1': 'B', '2': 'C'}),
      ], ok: i == n ? 'Publier' : 'Suivante');
      if (r == null) return;
      qs.add(Question(r['q']!, [r['a']!, r['b']!, r['c']!], int.parse(r['ok']!)));
    }
    s.createQuiz(head['course']!, head['title']!, int.tryParse(head['days']!) ?? 7, qs);
    if (context.mounted) toast(context, 'Quiz publié, les étudiants sont notifiés.');
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.myQuizzes;
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: s.myCourses.isEmpty ? null : () => _create(context),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau quiz'),
      ),
      body: list.isEmpty
          ? const EmptyState(Icons.quiz, 'Aucun quiz créé.')
          : ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 90), children: [
              for (final q in list)
                AppCard(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizResults(quiz: q))),
                  child: Row(children: [
                    const IconBadge(Icons.quiz_rounded, color: AppColors.warn),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(q.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text('${s.courseById(q.courseId)?.title} • échéance ${fmtDate(q.due)}',
                            style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                      ]),
                    ),
                    StatusChip('${s.attempts.where((a) => a.quizId == q.id && a.synced).length} rendu(s)', AppColors.primary),
                  ]),
                ),
            ]),
    );
  }
}

class QuizResults extends StatelessWidget {
  final Quiz quiz;
  const QuizResults({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final course = s.courseById(quiz.courseId)!;
    final studs = s.students.where((e) => e.classId == course.classId).toList();
    final diff = s.difficultyOf(quiz);
    return Scaffold(
      appBar: AppBar(title: Text(quiz.title, style: const TextStyle(fontSize: 16))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const SectionTitle('Soumissions des étudiants'),
        for (final st in studs)
          Builder(builder: (_) {
            final a = s.attemptOf(quiz.id, st.id);
            return AppCard(
              child: Row(children: [
                CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: .12), child: Text(st.initials)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(st.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (a != null && a.warnings > 0)
                      Text('${a.warnings} alerte(s) anti-triche',
                          style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                  ]),
                ),
                a == null || !a.synced
                    ? const StatusChip('Non rendu', AppColors.muted)
                    : StatusChip('${a.score.toStringAsFixed(1)}/20', AppColors.accent),
              ]),
            );
          }),
        const SectionTitle('Analyse par question'),
        for (var i = 0; i < quiz.questions.length; i++)
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${i + 1}. ${quiz.questions[i].text}', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: diff[i], color: AppColors.danger, minHeight: 6),
              const SizedBox(height: 4),
              Text('${(diff[i] * 100).round()} % d\'erreurs',
                  style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            ]),
          ),
      ]),
    );
  }
}

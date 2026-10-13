import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';

class TeacherHome extends StatelessWidget {
  const TeacherHome({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final u = s.user!;
    final studs = s.studentsOfTeacher(u.id);
    final quizzes = s.myQuizzes;
    final subs = s.attempts.where((a) => a.synced && quizzes.any((q) => q.id == a.quizId)).length;
    return ListView(padding: const EdgeInsets.all(16), children: [
      GradientHeader('Bonjour, ${u.name}', 'Espace enseignant', icon: Icons.cast_for_education),
      Row(children: [
        StatTile(Icons.menu_book_rounded, 'Cours', '${s.myCourses.length}'),
        StatTile(Icons.groups_rounded, 'Étudiants', '${studs.length}', color: AppColors.accent),
        StatTile(Icons.inbox_rounded, 'Soumissions', '$subs', color: AppColors.warn),
      ]),
      const SizedBox(height: 8),
      const SectionTitle('Difficultés fréquentes (statistiques agrégées)'),
      if (quizzes.every((q) => s.difficultyOf(q).every((d) => d == 0)))
        const AppCard(child: Text('Pas encore assez de résultats pour détecter des difficultés.')),
      for (final q in quizzes)
        for (var i = 0; i < q.questions.length; i++)
          if (s.difficultyOf(q)[i] > 0)
            AppCard(
              child: Row(children: [
                const IconBadge(Icons.insights, color: AppColors.danger),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(q.questions[i].text, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(q.title, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  ]),
                ),
                StatusChip('${(s.difficultyOf(q)[i] * 100).round()} % d\'erreurs', AppColors.danger),
              ]),
            ),
      const SectionTitle('Paiements de vos étudiants'),
      for (final st in studs)
        AppCard(
          child: Row(children: [
            CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: .12), child: Text(st.initials)),
            const SizedBox(width: 12),
            Expanded(child: Text(st.name, style: const TextStyle(fontWeight: FontWeight.w700))),
            s.dueOf(st.id) == 0
                ? const StatusChip('À jour', AppColors.accent)
                : const StatusChip('Solde en attente', AppColors.warn),
          ]),
        ),
    ]);
  }
}

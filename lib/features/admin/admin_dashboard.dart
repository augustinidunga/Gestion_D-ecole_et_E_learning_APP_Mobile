import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final total = s.totalCollected + s.totalPending;
    final rate = total == 0 ? 0.0 : s.totalCollected / total;
    return ListView(padding: const EdgeInsets.all(16), children: [
      const GradientHeader('Vue d\'ensemble', 'Rapports et indicateurs de l\'établissement',
          icon: Icons.insights),
      Row(children: [
        StatTile(Icons.school, 'Étudiants', '${s.students.length}'),
        StatTile(Icons.cast_for_education, 'Enseignants', '${s.teachers.length}', color: AppColors.accent),
        StatTile(Icons.class_, 'Classes', '${s.classes.length}', color: AppColors.warn),
      ]),
      const SizedBox(height: 12),
      const SectionTitle('Recouvrement des frais'),
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('Encaissé : ${fmtMoney(s.totalCollected)}', style: const TextStyle(fontWeight: FontWeight.w700))),
            Text('${(rate * 100).round()} %', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.accent)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: rate, minHeight: 8, color: AppColors.accent)),
          const SizedBox(height: 6),
          Text('En attente : ${fmtMoney(s.totalPending)}', style: const TextStyle(color: AppColors.muted)),
        ]),
      ),
      const SectionTitle('Activité pédagogique'),
      AppCard(
        child: Column(children: [
          _row(Icons.menu_book_rounded, 'Cours publiés', '${s.courses.length}'),
          _row(Icons.quiz_rounded, 'Quiz créés', '${s.quizzes.length}'),
          _row(Icons.inbox_rounded, 'Soumissions', '${s.attempts.length}'),
          _row(Icons.grade_rounded, 'Notes saisies', '${s.grades.length}'),
        ]),
      ),
      const SectionTitle('Dernières notifications émises'),
      for (final n in (s.notifs.toList()..sort((a, b) => b.date.compareTo(a.date))).take(4))
        AppCard(
          child: Row(children: [
            const IconBadge(Icons.notifications_active_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(n.body, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ]),
            ),
          ]),
        ),
    ]);
  }

  Widget _row(IconData i, String l, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Icon(i, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(l)),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w800)),
        ]),
      );
}

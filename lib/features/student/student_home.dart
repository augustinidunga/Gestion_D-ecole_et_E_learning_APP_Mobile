import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';

class StudentHome extends StatelessWidget {
  const StudentHome({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final u = s.user!;
    final avg = s.averageOf(u.id);
    final next = s.nextSlot(u.classId);
    final todo = s.myQuizzes
        .where((q) => s.attemptOf(q.id, u.id) == null && q.due.isAfter(DateTime.now()))
        .toList();
    final grades = s.gradesOf(u.id).take(3).toList();
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        GradientHeader(
          'Bonjour, ${u.name.split(' ').first}',
          s.className(u.classId),
          icon: Icons.person_rounded,
          gradientColors: const [AppColors.primary, AppColors.primaryLight],
        ),
        Row(
          children: [
            StatTile(
              Icons.grade_rounded,
              'Moyenne',
              avg == null ? '-' : '${avg.toStringAsFixed(1)}/20',
              color: AppColors.accent,
            ),
            StatTile(
              Icons.quiz_rounded,
              'Quiz à faire',
              '${todo.length}',
              color: AppColors.warn,
            ),
            StatTile(
              Icons.account_balance_wallet_rounded,
              'Solde dû',
              fmtMoney(s.dueOf(u.id)),
              color: AppColors.danger,
            ),
          ],
        ),
        const SizedBox(height: 8),
        const SectionTitle('Prochain cours'),
        if (next == null)
          const AppCard(
            child: Row(
              children: [
                IconBadge(Icons.schedule, color: AppColors.textMuted),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Aucun cours programmé.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          )
        else
          AppCard(
            child: Row(
              children: [
                const IconBadge(Icons.schedule, color: AppColors.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        next.$1.subject,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${next.$2 == 0 ? "Aujourd\'hui" : weekdays[DateTime.now().add(Duration(days: next.$2)).weekday]} • ${next.$1.start}-${next.$1.end} • ${next.$1.room}',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SectionTitle('À faire'),
        if (todo.isEmpty)
          const AppCard(
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.accent),
                SizedBox(width: 10),
                Text('Tout est à jour'),
              ],
            ),
          )
        else
          for (final q in todo)
            AppCard(
              child: Row(
                children: [
                  const IconBadge(Icons.quiz_rounded, color: AppColors.warn),
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
                          'À rendre avant le ${fmtDate(q.due)}',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  StatusChip('À faire', AppColors.primary),
                ],
              ),
            ),
        const SectionTitle('Dernières notes'),
        if (grades.isEmpty)
          const AppCard(
            child: Text(
              'Aucune note publiée pour le moment.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          )
        else
          for (final g in grades)
            AppCard(
              child: Row(
                children: [
                  IconBadge(
                    g.isQuiz ? Icons.quiz_rounded : Icons.edit_note,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.label,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          g.courseTitle,
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${g.value.toStringAsFixed(1)}/20',
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

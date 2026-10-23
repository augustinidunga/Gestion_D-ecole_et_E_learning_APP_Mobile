import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';

class TeacherAnalytics extends StatelessWidget {
  const TeacherAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final u = s.user!;
    final st = s.teacherStats(u.id);
    final myCourses = s.myCourses;
    return Scaffold(
      appBar: AppBar(title: const Text('Analytique')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GradientHeader('Tableau de bord analytique', u.name, icon: Icons.analytics_rounded),
          Row(children: [
            StatTile(Icons.menu_book_rounded, 'Cours', '${st['courses']}', color: AppColors.primary),
            StatTile(Icons.quiz_rounded, 'Quiz', '${st['quizzes']}', color: AppColors.warn),
            StatTile(Icons.groups_rounded, 'Étudiants', '${st['students']}', color: AppColors.info),
          ]),
          const SectionTitle('Cours et progression'),
          for (final c in myCourses)
            AppCardElevated(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: s.progressOf(c), color: AppColors.accent, backgroundColor: AppColors.border),
                const SizedBox(height: 4),
                Text('${(s.progressOf(c) * 100).toStringAsFixed(0)}% complété', style: TextStyle(fontSize: 11, color: Neumo.of(context).textMuted)),
              ]),
            ),
        ],
      ),
    );
  }
}

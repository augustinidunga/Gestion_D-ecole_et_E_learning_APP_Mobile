import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';

class TeacherAnalytics extends StatelessWidget {
  const TeacherAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    final u = s.user!;
    final st = s.teacherStats(u.id);
    final myCourses = s.myCourses;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('teacher.analytics.title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GradientHeader(l10n.t('teacher.analytics.title'), u.name, icon: Icons.analytics_rounded),
          Row(children: [
            StatTile(Icons.menu_book_rounded, l10n.t('teacher.courses.title'), '${st['courses']}', color: AppColors.primary),
            StatTile(Icons.quiz_rounded, l10n.t('student.quiz.title'), '${st['quizzes']}', color: AppColors.warn),
            StatTile(Icons.groups_rounded, l10n.t('teacher.student.title'), '${st['students']}', color: AppColors.info),
          ]),
          SectionTitle(l10n.t('teacher.courses.detail')),
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

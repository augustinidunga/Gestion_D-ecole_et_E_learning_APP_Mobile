import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';

class StudentAttendance extends StatelessWidget {
  const StudentAttendance({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    final u = s.user!;
    final rate = s.attendanceRate(u.id);
    final recs = s.attendance.where((a) => a.studentId == u.id).toList()..sort((a, b) => b.date.compareTo(a.date));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('student.attendance.title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GradientHeader(l10n.t('student.attendance.title'), '${(rate * 100).toStringAsFixed(0)}% de présence', icon: Icons.fact_check_rounded, gradientColors: const [AppColors.accent, AppColors.primary]),
          if (recs.isEmpty)
            const EmptyState(Icons.event_available, '', '')
          else
            for (final r in recs)
              AppCardElevated(
                child: Row(children: [
                  Icon(r.present ? Icons.check_circle_rounded : Icons.cancel_rounded, color: r.present ? AppColors.accent : AppColors.danger),
                  const SizedBox(width: 12),
                  Expanded(child: Text(fmtDate(r.date), style: const TextStyle(fontWeight: FontWeight.w600))),
                  StatusChip(r.present ? 'Présent' : 'Absent', r.present ? AppColors.accent : AppColors.danger),
                ]),
              ),
        ],
      ),
    );
  }
}

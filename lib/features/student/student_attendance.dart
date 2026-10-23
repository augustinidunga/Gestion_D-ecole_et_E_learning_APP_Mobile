import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';

class StudentAttendance extends StatelessWidget {
  const StudentAttendance({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final u = s.user!;
    final rate = s.attendanceRate(u.id);
    final recs = s.attendance.where((a) => a.studentId == u.id).toList()..sort((a, b) => b.date.compareTo(a.date));
    return Scaffold(
      appBar: AppBar(title: const Text('Mes présences')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GradientHeader('Assiduité', '${(rate * 100).toStringAsFixed(0)}% de présence', icon: Icons.fact_check_rounded, gradientColors: const [AppColors.accent, AppColors.primary]),
          if (recs.isEmpty)
            const EmptyState(Icons.event_available, 'Aucun enregistrement')
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

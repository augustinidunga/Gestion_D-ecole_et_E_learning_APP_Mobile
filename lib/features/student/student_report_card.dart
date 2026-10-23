import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';

class StudentReportCard extends StatelessWidget {
  const StudentReportCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final u = s.user!;
    final rc = s.reportCard(u.id);
    final grades = rc['grades'] as List;
    final avg = rc['average'] as double?;
    final att = rc['attendance'] as double;
    return Scaffold(
      appBar: AppBar(title: const Text('Bulletin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GradientHeader('Bulletin de ${u.name}', s.className(u.classId), icon: Icons.description_rounded),
          Row(children: [
            StatTile(Icons.grade_rounded, 'Moyenne', avg == null ? '-' : '${avg.toStringAsFixed(1)}/20', color: AppColors.accent),
            StatTile(Icons.fact_check_rounded, 'Assiduité', '${(att * 100).toStringAsFixed(0)}%', color: AppColors.info),
            StatTile(Icons.assignment_rounded, 'Notes', '${grades.length}', color: AppColors.warn),
          ]),
          const SectionTitle('Détail des notes'),
          if (grades.isEmpty)
            const EmptyState(Icons.grade_outlined, 'Aucune note')
          else
            for (final g in grades)
              AppCardElevated(
                child: Row(children: [
                  IconBadge(g.isQuiz ? Icons.quiz_rounded : Icons.edit_note, color: AppColors.accent),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(g.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(g.courseTitle, style: TextStyle(fontSize: 12, color: Neumo.of(context).textMuted)),
                  ])),
                  Text('${g.value.toStringAsFixed(1)}/20', style: const TextStyle(fontWeight: FontWeight.w800)),
                ]),
              ),
        ],
      ),
    );
  }
}

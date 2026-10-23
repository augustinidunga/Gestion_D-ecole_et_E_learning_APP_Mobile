import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';

class StudentAssignments extends StatelessWidget {
  const StudentAssignments({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final u = s.user!;
    final list = s.assignmentsForStudent(u.id);
    return Scaffold(
      appBar: AppBar(title: const Text('Devoirs')),
      body: list.isEmpty
          ? const EmptyState(Icons.assignment_outlined, 'Aucun devoir pour le moment')
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (ctx, i) {
                final a = list[i];
                final c = s.courseById(a.courseId);
                final sub = s.submissionOf(a.id, u.id);
                return AppCardElevated(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      IconBadge(Icons.assignment_rounded, color: AppColors.info),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(c?.title ?? '', style: TextStyle(fontSize: 12, color: Neumo.of(context).textMuted)),
                      ])),
                      StatusChip(sub == null ? 'À faire' : (sub.grade == null ? 'Rendu' : '${sub.grade!.toStringAsFixed(1)}/20'),
                          sub == null ? AppColors.warn : (sub.grade == null ? AppColors.info : AppColors.accent)),
                    ]),
                    const SizedBox(height: 8),
                    Text(a.description, style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('À rendre avant le ${fmtDate(a.due)}', style:  TextStyle(fontSize: 12, color: Neumo.of(context).textMuted)),
                    const SizedBox(height: 10),
                    if (sub == null || sub.grade == null)
                      AppFormButton(
                        text: sub == null ? 'Rendre' : 'Modifier',
                        icon: Icons.upload_rounded,
                        onPressed: () async {
                          final res = await askForm(context, 'Rendre le devoir', [Fld('content', 'Votre réponse', multiline: true)]);
                          if (res != null && res['content']!.isNotEmpty) {
                            s.submitAssignment(a.id, res['content']!);
                            toast(context, 'Devoir envoyé');
                          }
                        },
                      ),
                    if (sub?.feedback != null) ...[
                      const SizedBox(height: 8),
                      AppCard(color: AppColors.accent.withOpacity(0.08), child: Text('Feedback : ${sub!.feedback}', style: const TextStyle(fontSize: 12))),
                    ],
                  ]),
                );
              },
            ),
    );
  }
}

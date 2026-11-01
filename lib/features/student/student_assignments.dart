import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';

void _previewAttachment(BuildContext context, String url) {
  final lower = url.toLowerCase();
  if (lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.gif') || lower.endsWith('.webp')) {
    showDialog(context: context, builder: (ctx) => Dialog(child: InteractiveViewer(child: Image.network(url, errorBuilder: (_, __, ___) => const Padding(padding: EdgeInsets.all(16), child: Text('Impossible de charger l\'image'))))));
  } else {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Pièce jointe'),
      content: Text(url),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer'))],
    ));
  }
}
class StudentAssignments extends StatelessWidget {
  const StudentAssignments({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    final u = s.user!;
    final list = s.assignmentsForStudent(u.id);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('teacher.assignment.title'))),
      body: list.isEmpty
          ? const EmptyState(Icons.assignment_outlined, '', '')
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
               itemBuilder: (ctx, i) {
                  final a = list[i];
                  final c = s.courseById(a.courseId);
                 final sub = s.submissionOf(a.id, u.id);
                 final myGrade = (sub != null && a.isGroup)
                     ? (sub.memberGrades[u.id] ?? sub.grade)
                     : sub?.grade;
                 final pastDue = a.due.isBefore(DateTime.now());
                  return AppCardElevated(
                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                     Row(children: [
                       IconBadge(Icons.assignment_rounded, color: AppColors.info),
                       const SizedBox(width: 12),
                       Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                         Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                         Text(c?.title ?? '', style: TextStyle(fontSize: 12, color: Neumo.of(context).textMuted)),
                       ])),
                       StatusChip(
                         pastDue && sub == null
                             ? 'Fermé'
                             : (sub == null ? 'À faire' : (myGrade == null ? 'Rendu' : '${myGrade.toStringAsFixed(1)}/20')),
                         pastDue && sub == null ? AppColors.danger : (sub == null ? AppColors.warn : (myGrade == null ? AppColors.info : AppColors.accent)),
                       ),
                     ]),
                     const SizedBox(height: 8),
                     Text(a.description, style: const TextStyle(fontSize: 13)),
                     if (a.isGroup) ...[
                       const SizedBox(height: 4),
                       Text('Groupe : ${a.groupMembers.map((id) => s.userById(id)?.name ?? id).join(', ')}',
                           style: TextStyle(fontSize: 11, color: AppColors.info)),
                     ],
                     const SizedBox(height: 4),
                     Text('À rendre avant le ${fmtDate(a.due)} à ${a.due.hour.toString().padLeft(2, '0')}:${a.due.minute.toString().padLeft(2, '0')}${pastDue ? ' (échéance dépassée)' : ''}',
                         style: TextStyle(fontSize: 12, color: pastDue ? AppColors.danger : Neumo.of(context).textMuted)),
                     const SizedBox(height: 10),
                     if (sub == null || sub.grade == null)
                       AppFormButton(
                         text: pastDue ? 'Fermé' : (sub == null ? l10n.t('teacher.attendance.mark') : l10n.t('edit')),
                         icon: Icons.upload_rounded,
                         onPressed: pastDue
                             ? null
                             : () async {
                                 final res = await askForm(context, l10n.t('teacher.assignment.title'), [
                                   Fld('content', l10n.t('student.quiz.score'), multiline: true),
                                   Fld('attach', 'Pièces jointes (URLs séparées par ;)', multiline: true),
                                 ]);
                                 if (res != null && res['content']!.isNotEmpty) {
                                   final atts = res['attach']!.split(';').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                                   s.submitAssignment(a.id, res['content']!, attachments: atts);
                                   toast(context, l10n.t('student.payments.confirmed'));
                                 }
                               },
                       ),
                     if (sub != null && sub.attachments.isNotEmpty) ...[
                       const SizedBox(height: 6),
                       Wrap(
                         spacing: 6,
                         children: [
                           for (final att in sub.attachments)
                             ActionChip(
                               label: Text(att.split('/').last, style: const TextStyle(fontSize: 11)),
                               avatar: const Icon(Icons.attach_file, size: 14),
                               onPressed: () => _previewAttachment(context, att),
                             ),
                         ],
                       ),
                     ],
                       if (sub != null && !sub.synced) Text('En attente de synchronisation', style: TextStyle(fontSize: 11, color: AppColors.warn)),
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

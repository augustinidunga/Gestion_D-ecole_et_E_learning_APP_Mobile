import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
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

class TeacherAssignments extends StatefulWidget {
  const TeacherAssignments({super.key});
  @override
  State<TeacherAssignments> createState() => _TeacherAssignmentsState();
}

class _TeacherAssignmentsState extends State<TeacherAssignments> {
  String? _selectedAssignmentId;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    final u = s.user!;
    final list = s.assignmentsForTeacher(u.id);
    if (_selectedAssignmentId != null) {
      final a = list.firstWhere((x) => x.id == _selectedAssignmentId, orElse: () => list.first);
      final subs = s.submissionsForAssignment(a.id);
       return Scaffold(
         appBar: AppBar(title: Text(a.title), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _selectedAssignmentId = null))),
         body: Column(
           children: [
             Padding(
               padding: const EdgeInsets.all(12),
               child: Row(
                 children: [
                   Expanded(child: AppFormButton(text: 'Stats', icon: Icons.bar_chart, onPressed: () {
                     final st = s.assignmentStats(a.id);
                     showDialog(context: context, builder: (ctx) => AlertDialog(
                       title: const Text('Statistiques'),
                       content: Text('Total: ${st['total']}\nCorrigés: ${st['graded']}\nEn attente: ${st['pending']}\nMoyenne: ${st['average'] == null ? '-' : (st['average'] as double).toStringAsFixed(2)}\nEn retard: ${st['late']}'),
                       actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
                     ));
                   })),
                   const SizedBox(width: 8),
                   Expanded(child: AppFormButton(text: 'Plagiat', icon: Icons.content_copy, onPressed: () {
                     final rep = s.plagiarismReport(a.id);
                     showDialog(context: context, builder: (ctx) => AlertDialog(
                       title: const Text('Plagiat'),
                       content: Text(rep.isEmpty ? 'Aucune similitude élevée détectée.' : rep.entries.map((e) => '${e.key}: ${(e.value*100).round()}%').join('\n')),
                       actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
                     ));
                   })),
                   const SizedBox(width: 8),
                   Expanded(child: AppFormButton(text: 'Export CSV', icon: Icons.download, onPressed: () {
                     final csv = s.exportAssignmentCsv(a.id);
                     toast(context, 'CSV généré (${csv.split('\\n').length} lignes)');
                   })),
                 ],
               ),
             ),
             Expanded(
               child: subs.isEmpty
                   ? const EmptyState(Icons.inbox_outlined, '', '')
                   : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: subs.length,
                itemBuilder: (ctx, i) {
                  final sub = subs[i];
                  final st = s.userById(sub.studentId);
                   return AppCardElevated(
                     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                       Row(children: [
                         CircleAvatar(backgroundColor: AppColors.primary, child: Text(st?.initials ?? '?', style: const TextStyle(color: Colors.white))),
                         const SizedBox(width: 12),
                         Expanded(child: Text(st?.name ?? '-', style: const TextStyle(fontWeight: FontWeight.w700))),
                         if (sub.date.isAfter(a.due)) StatusChip('En retard', AppColors.danger),
                         if (sub.grade != null) StatusChip('${sub.grade!.toStringAsFixed(1)}/20', AppColors.accent),
                       ]),
                      const SizedBox(height: 8),
                      Text(sub.content, style: const TextStyle(fontSize: 13)),
                      if (sub.attachments.isNotEmpty) ...[
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
                      if (sub.contributors.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Contributeurs : ${sub.contributors.map((id) => s.userById(id)?.name ?? id).join(', ')}',
                            style: TextStyle(fontSize: 11, color: AppColors.info)),
                      ],
                      const SizedBox(height: 8),
                   if (sub.grade == null)
                     AppFormButton(
                       text: l10n.t('edit'),
                       icon: Icons.grade_rounded,
                       onPressed: () async {
                         final a = list.firstWhere((x) => x.id == _selectedAssignmentId, orElse: () => list.first);
                         final fields = <Fld>[];
                         if (a.rubric.isNotEmpty) {
                           for (var i = 0; i < a.rubric.length; i++) {
                             fields.add(Fld('c$i', '${a.rubric[i].label} (pond. ${(a.rubric[i].weight * 100).round()}%)', number: true));
                           }
                         } else {
                           fields.add(Fld('grade', l10n.t('student.quiz.score'), number: true));
                         }
                         if (a.isGroup && sub.contributors.isNotEmpty) {
                           for (final m in sub.contributors) {
                             final name = s.userById(m)?.name ?? m;
                             fields.add(Fld('m_$m', 'Note $name', number: true));
                           }
                         }
                         fields.add(Fld('feedback', 'Feedback', multiline: true));
                         final res = await askForm(context, l10n.t('teacher.assignment.title'), fields);
                         if (res != null) {
                           double g;
                           List<RubricCriterion> scores = [];
                           if (a.rubric.isNotEmpty) {
                             var total = 0.0;
                             for (var i = 0; i < a.rubric.length; i++) {
                               final sc = double.tryParse(res['c$i'] ?? '') ?? 0;
                               scores.add(a.rubric[i].copyWith(score: sc));
                               total += sc * a.rubric[i].weight;
                             }
                             g = total;
                           } else {
                             g = double.tryParse(res['grade'] ?? '') ?? 0;
                           }
                           final fb = res['feedback']!.isEmpty ? s.suggestFeedback(sub.content, g) : res['feedback']!;
                           s.gradeSubmission(sub.id, g, fb, rubricScores: scores);
                           if (a.isGroup && sub.contributors.isNotEmpty) {
                             for (final m in sub.contributors) {
                               final mg = double.tryParse(res['m_$m'] ?? '');
                               if (mg != null) s.gradeGroupMember(sub.id, m, mg, fb);
                             }
                           }
                           toast(context, l10n.t('student.payments.confirmed'));
                         }
                       },
                     ),
                    ]),
                  );
                },
              ),
             ),
           ],
         ),
       );
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('teacher.assignment.title'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final courses = s.myCourses;
          if (courses.isEmpty) { toast(context, l10n.t('student.courses.no.courses')); return; }
          final res = await askForm(context, l10n.t('teacher.assignment.new'), [
            Fld('title', l10n.t('teacher.courses.content.title')),
            Fld('course', l10n.t('teacher.courses.content.type'), options: {for (final c in courses) c.id: c.title}),
            Fld('desc', l10n.t('teacher.courses.content.url'), multiline: true),
            Fld('type', 'Type de remise', options: {'text': 'Texte', 'file': 'Fichier', 'link': 'Lien'}),
            Fld('penalty', 'Pénalité / jour (pts)', number: true),
            Fld('group', 'Travail de groupe', options: {'0': 'Non', '1': 'Oui'}),
          ]);
          if (res == null || res['title']!.isEmpty) return;
          final isGroup = res['group'] == '1';
          List<String> members = [];
          if (isGroup) {
            final studs = s.students.where((st) => st.classId == s.courseById(res['course']!)?.classId).toList();
            if (studs.isEmpty) { toast(context, 'Aucun étudiant dans la classe.'); return; }
            final picked = await showDialog<List<String>>(
              context: context,
              builder: (ctx) {
                final sel = <String>{};
                return StatefulBuilder(builder: (ctx, set) => AlertDialog(
                  title: const Text('Membres du groupe'),
                  content: SizedBox(
                    width: 320,
                    height: 300,
                    child: ListView(
                      children: [
                        for (final st in studs)
                          CheckboxListTile(
                            title: Text(st.name),
                            value: sel.contains(st.id),
                            onChanged: (v) => set(() { if (v == true) sel.add(st.id); else sel.remove(st.id); }),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Annuler')),
                    FilledButton(onPressed: () => Navigator.pop(ctx, sel.toList()), child: const Text('Valider')),
                  ],
                ));
              },
            );
            if (picked == null || picked.isEmpty) return;
            members = picked;
          }
          final date = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 7)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
          if (date == null) return;
          final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 23, minute: 59));
          if (time == null) return;
          final due = DateTime(date.year, date.month, date.day, time.hour, time.minute);
          s.createAssignment(res['course']!, res['title']!, res['desc']!, due,
              isGroup: isGroup,
              groupMembers: members,
              submissionType: res['type'] ?? 'text',
              latePenaltyPerDay: double.tryParse(res['penalty'] ?? '') ?? 0);
          toast(context, l10n.t('student.payments.confirmed'));
        },
        child: const Icon(Icons.add),
      ),
      body: list.isEmpty
          ? const EmptyState(Icons.assignment_outlined, '', '')
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (ctx, i) {
                final a = list[i];
                final c = s.courseById(a.courseId);
                final subs = s.submissionsForAssignment(a.id);
                final graded = subs.where((x) => x.grade != null).length;
                return AppCardElevated(
                  onTap: () => setState(() => _selectedAssignmentId = a.id),
                  child: Row(children: [
                    IconBadge(Icons.assignment_rounded, color: AppColors.info),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(c?.title ?? '', style: TextStyle(fontSize: 12, color: Neumo.of(context).textMuted)),
                      Text('${subs.length} soumission(s) • $graded corrigée(s)', style:  TextStyle(fontSize: 11, color: Neumo.of(context).textMuted)),
                    ])),
                     Icon(Icons.chevron_right_rounded, color: Neumo.of(context).textMuted),
                  ]),
                );
              },
            ),
    );
  }
}

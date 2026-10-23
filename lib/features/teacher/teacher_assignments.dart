import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';

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
    final u = s.user!;
    final list = s.assignmentsForTeacher(u.id);
    if (_selectedAssignmentId != null) {
      final a = list.firstWhere((x) => x.id == _selectedAssignmentId, orElse: () => list.first);
      final subs = s.submissionsForAssignment(a.id);
      return Scaffold(
        appBar: AppBar(title: Text(a.title), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _selectedAssignmentId = null))),
        body: subs.isEmpty
            ? const EmptyState(Icons.inbox_outlined, 'Aucune soumission')
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
                        if (sub.grade != null) StatusChip('${sub.grade!.toStringAsFixed(1)}/20', AppColors.accent),
                      ]),
                      const SizedBox(height: 8),
                      Text(sub.content, style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 8),
                      if (sub.grade == null)
                        AppFormButton(
                          text: 'Corriger',
                          icon: Icons.grade_rounded,
                          onPressed: () async {
                            final res = await askForm(context, 'Correction', [
                              Fld('grade', 'Note /20', number: true),
                              Fld('feedback', 'Feedback', multiline: true),
                            ]);
                            if (res != null) {
                              final g = double.tryParse(res['grade']!);
                              if (g != null) {
                                s.gradeSubmission(sub.id, g, res['feedback']!);
                                toast(context, 'Note publiée');
                              }
                            }
                          },
                        ),
                    ]),
                  );
                },
              ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Devoirs')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final courses = s.myCourses;
          if (courses.isEmpty) { toast(context, 'Aucun cours'); return; }
          final res = await askForm(context, 'Nouveau devoir', [
            Fld('title', 'Titre'),
            Fld('course', 'Cours', options: {for (final c in courses) c.id: c.title}),
            Fld('desc', 'Description', multiline: true),
            Fld('days', 'Jours avant échéance', number: true),
          ]);
          if (res != null && res['title']!.isNotEmpty) {
            s.createAssignment(res['course']!, res['title']!, res['desc']!, int.tryParse(res['days']!) ?? 7);
            toast(context, 'Devoir créé');
          }
        },
        child: const Icon(Icons.add),
      ),
      body: list.isEmpty
          ? const EmptyState(Icons.assignment_outlined, 'Aucun devoir créé')
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

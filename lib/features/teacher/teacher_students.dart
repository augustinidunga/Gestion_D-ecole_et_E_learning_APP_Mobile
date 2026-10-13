import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';

class TeacherStudents extends StatelessWidget {
  const TeacherStudents({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.studentsOfTeacher(s.user!.id);
    if (list.isEmpty) return const EmptyState(Icons.groups, 'Aucun étudiant suivi.');
    return ListView(padding: const EdgeInsets.all(16), children: [
      for (final st in list)
        AppCard(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentDetail(student: st))),
          child: Row(children: [
            CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: .12), child: Text(st.initials)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(st.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(s.className(st.classId), style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ]),
            ),
            Text(s.averageOf(st.id) == null ? '-' : '${s.averageOf(st.id)!.toStringAsFixed(1)}/20',
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ]),
        ),
    ]);
  }
}

class StudentDetail extends StatelessWidget {
  final AppUser student;
  const StudentDetail({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final grades = s.gradesOf(student.id);
    final myCourses = s.myCourses.where((c) => c.classId == student.classId).toList();
    return Scaffold(
      appBar: AppBar(title: Text(student.name)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: myCourses.isEmpty
            ? null
            : () async {
                final r = await askForm(context, 'Saisir une note', [
                  Fld('course', 'Cours', options: {for (final c in myCourses) c.id: c.title}),
                  const Fld('label', 'Intitulé (devoir, examen…)'),
                  const Fld('value', 'Note sur 20', number: true),
                ], ok: 'Publier');
                if (r == null) return;
                final v = double.tryParse(r['value']!.replaceAll(',', '.'));
                if (v == null || v < 0 || v > 20 || r['label']!.isEmpty) {
                  if (context.mounted) toast(context, 'Note invalide (0 à 20).');
                  return;
                }
                s.enterGrade(student.id, r['course']!, r['label']!, v);
                if (context.mounted) toast(context, 'Note publiée, l\'étudiant est notifié.');
              },
        icon: const Icon(Icons.edit_note),
        label: const Text('Saisir une note'),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 90), children: [
        GradientHeader(student.name, '${s.className(student.classId)} • ${student.email}', icon: Icons.person),
        Row(children: [
          StatTile(Icons.grade_rounded, 'Moyenne',
              s.averageOf(student.id) == null ? '-' : s.averageOf(student.id)!.toStringAsFixed(1),
              color: AppColors.accent),
          StatTile(Icons.payments_rounded, 'Paiement', s.dueOf(student.id) == 0 ? 'À jour' : 'En attente',
              color: s.dueOf(student.id) == 0 ? AppColors.accent : AppColors.warn),
        ]),
        const SectionTitle('Résultats'),
        if (grades.isEmpty) const EmptyState(Icons.grade_outlined, 'Aucun résultat.'),
        for (final g in grades)
          AppCard(
            child: Row(children: [
              IconBadge(g.isQuiz ? Icons.quiz_rounded : Icons.edit_note, color: AppColors.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(g.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('${g.courseTitle} • ${fmtDate(g.date)}',
                      style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ]),
              ),
              Text('${g.value.toStringAsFixed(1)}/20', style: const TextStyle(fontWeight: FontWeight.w800)),
            ]),
          ),
      ]),
    );
  }
}

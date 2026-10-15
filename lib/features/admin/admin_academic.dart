import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';

/// Classes, matières/cours et emplois du temps.
class AdminAcademic extends StatelessWidget {
  const AdminAcademic({super.key});

  Future<void> _createClass(BuildContext context) async {
    final r = await askForm(context, 'Créer une classe', const [
      Fld('name', 'Nom de la classe (ex. L1 Informatique)'),
    ], ok: 'Créer la classe');
    if (r == null) return;
    final created = context.read<AppState>().createClass(r['name']!);
    if (context.mounted) {
      toast(
        context,
        created
            ? 'Classe créée.'
            : 'Saisissez un nom unique. Une classe porte peut-être déjà ce nom.',
      );
    }
  }

  Future<void> _createCourse(BuildContext context) async {
    final s = context.read<AppState>();
    if (s.classes.isEmpty || s.teachers.where((teacher) => teacher.active).isEmpty) {
      toast(context, 'Créez d’abord une classe et un compte enseignant actif.');
      return;
    }
    final r = await askForm(context, 'Créer un cours', [
      const Fld('title', 'Nom du cours'),
      const Fld('subject', 'Matière'),
      Fld('class', 'Classe', options: {for (final c in s.classes) c.id: c.name}),
      Fld('teacher', 'Enseignant', options: {
        for (final teacher in s.teachers.where((teacher) => teacher.active))
          teacher.id: teacher.name
      }),
      const Fld('description', 'Description', multiline: true),
    ], ok: 'Créer le cours');
    if (r == null) return;
    final err = await s.createAcademicCourse(
  r['title']!,
  r['subject']!,
  r['class']!,
  r['teacher']!,
  r['description']!,
);
  if (context.mounted) {
  toast(context, err ?? 'Cours créé.');
}
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final r = await askForm(context, 'Ajouter un créneau', [
            Fld('class', 'Classe', options: {for (final c in s.classes) c.id: c.name}),
            Fld('day', 'Jour', options: {for (var d = 1; d <= 6; d++) '$d': weekdays[d]}),
            const Fld('start', 'Début (ex. 08:00)'),
            const Fld('end', 'Fin (ex. 10:00)'),
            Fld('course', 'Matière', options: {for (final c in s.courses) c.title: c.title}),
            const Fld('room', 'Salle'),
          ], ok: 'Ajouter');
          if (r == null) return;
          final ok = RegExp(r'^\d{2}:\d{2}$');
          if (!ok.hasMatch(r['start']!) || !ok.hasMatch(r['end']!)) {
            if (context.mounted) toast(context, 'Format d\'heure attendu : HH:MM');
            return;
          }
          final teacher = s.courses.firstWhere((c) => c.title == r['course']).teacherId;
          s.addSlot(Slot(r['class']!, int.parse(r['day']!), r['start']!, r['end']!, r['course']!,
              r['room']!.isEmpty ? 'Salle ?' : r['room']!, s.userById(teacher)?.name ?? ''));
          if (context.mounted) toast(context, 'Emploi du temps mis à jour.');
        },
        icon: const Icon(Icons.event),
        label: const Text('Créneau'),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 90), children: [
        Row(children: [
          StatTile(Icons.class_rounded, 'Classes', '${s.classes.length}'),
          StatTile(Icons.menu_book_rounded, 'Cours', '${s.courses.length}', color: AppColors.accent),
        ]),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => _createClass(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nouvelle classe'),
            ),
            FilledButton.icon(
              onPressed: () => _createCourse(context),
              icon: const Icon(Icons.menu_book_rounded),
              label: const Text('Nouveau cours'),
            ),
          ],
        ),
        const SectionTitle('Classes de l’établissement'),
        for (final c in s.classes)
          AppCard(
            child: Row(children: [
              const IconBadge(Icons.class_, color: AppColors.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text('${s.students.where((e) => e.classId == c.id).length} étudiant(s) • '
                      '${s.courses.where((k) => k.classId == c.id).length} matière(s) • '
                      '${s.schedule.where((x) => x.classId == c.id).length} créneaux/semaine',
                      style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ]),
              ),
            ]),
          ),
        const SectionTitle('Cours et enseignants'),
        for (final c in s.courses)
          AppCard(
            child: Row(children: [
              const IconBadge(Icons.menu_book_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('${s.className(c.classId)} • ${s.userById(c.teacherId)?.name ?? ''}',
                      style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ]),
              ),
              StatusChip('${c.lessons.length} contenus', AppColors.primary),
            ]),
          ),
      ]),
    );
  }
}

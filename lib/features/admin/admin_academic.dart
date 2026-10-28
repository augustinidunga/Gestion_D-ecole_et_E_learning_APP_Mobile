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
    final r = await askForm(
        context,
        'Créer une classe',
        const [
          Fld('name', 'Nom de la classe (ex. L1 Informatique)'),
        ],
        ok: 'Créer la classe');
    if (r == null) return;
    final created = context.read<AppState>().createClass(r['name']!);
    final err = await context.read<AppState>().createClass(r['name']!);
     if (context.mounted) toast(context, err ?? 'Classe créée.');
  }

  Future<void> _enroll(BuildContext context) async {
    final s = context.read<AppState>();
    final students = s.students.where((u) => u.active).toList();
    if (students.isEmpty || s.courses.isEmpty) {
      toast(context, 'Il faut au moins un étudiant et un cours.');
      return;
    }
    final r = await askForm(
        context,
        'Inscrire un étudiant',
        [
          Fld('student', 'Étudiant',
              options: {for (final u in students) u.id: u.name}),
          Fld('course', 'Cours',
              options: {for (final c in s.courses) c.id: c.title}),
        ],
        ok: 'Inscrire');
    if (r == null) return;
    final err = await s.enrollStudent(r['student']!, r['course']!);
    if (context.mounted) toast(context, err ?? 'Étudiant inscrit.');
  }

  Future<void> _createCourse(BuildContext context) async {
    final s = context.read<AppState>();
    if (s.classes.isEmpty ||
        s.teachers.where((teacher) => teacher.active).isEmpty) {
      toast(context, 'Créez d’abord une classe et un compte enseignant actif.');
      return;
    }
    final r = await askForm(
        context,
        'Créer un cours',
        [
          const Fld('title', 'Nom du cours'),
          const Fld('subject', 'Matière'),
          Fld('class', 'Classe',
              options: {for (final c in s.classes) c.id: c.name}),
          Fld('teacher', 'Enseignant', options: {
            for (final teacher in s.teachers.where((teacher) => teacher.active))
              teacher.id: teacher.name
          }),
          const Fld('description', 'Description', multiline: true),
        ],
        ok: 'Créer le cours');
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

    Future<void> _addSlot(BuildContext context) async {
    final s = context.read<AppState>();
    if (s.courses.isEmpty) {
      toast(context, 'Créez d\'abord un cours.');
      return;
    }
    final r = await askForm(
        context,
        'Ajouter un créneau',
        [
          Fld('course', 'Cours',
              options: {for (final c in s.courses) c.id: c.title}),
          Fld('day', 'Jour', options: {
            for (var d = 1; d <= 7; d++) '$d': AppState.weekdays[d]
          }),
          const Fld('start', 'Début (ex. 08:00)'),
          const Fld('end', 'Fin (ex. 10:00)'),
          const Fld('room', 'Salle'),
        ],
        ok: 'Ajouter');
    if (r == null) return;
    final ok = RegExp(r'^\d{2}:\d{2}$');
    if (!ok.hasMatch(r['start']!) || !ok.hasMatch(r['end']!)) {
      if (context.mounted) toast(context, 'Format d\'heure attendu : HH:MM');
      return;
    }
    final err = await s.createSlot(
      courseId: r['course']!,
      weekday: int.parse(r['day']!),
      start: r['start']!,
      end: r['end']!,
      room: r['room']!,
    );
    if (context.mounted) toast(context, err ?? 'Emploi du temps mis à jour.');
  }

  Widget _table(List<String> cols, List<List<Widget>> rows) => AppCard(
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: c.maxWidth),
              child: DataTable(
                headingTextStyle: const TextStyle(fontWeight: FontWeight.w800),
                columns: [for (final h in cols) DataColumn(label: Text(h))],
                rows: [
                  for (final r in rows)
                    DataRow(cells: [for (final w in r) DataCell(w)])
                ],
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(children: [
          const TabBar(tabs: [
            Tab(text: 'Classes'),
            Tab(text: 'Cours'),
            Tab(text: 'Emploi du temps'),
          ]),
          Expanded(
            child: TabBarView(children: [
              _classesTab(context, s),
              _coursesTab(context, s),
              _scheduleTab(context, s),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _classesTab(BuildContext context, AppState s) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            StatTile(Icons.class_rounded, 'Classes', '${s.classes.length}'),
          ]),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () => _createClass(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nouvelle classe'),
            ),
          ),
          const SectionTitle('Classes de l’établissement'),
                  _table(['Classe', 'Étudiants'], [
            for (final c in s.classes)
              [
                Text(c.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text('${s.studentsInClass(c)}'),
              ]
          ]),
        ],
      );

  Widget _coursesTab(BuildContext context, AppState s) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            StatTile(Icons.menu_book_rounded, 'Cours', '${s.courses.length}',
                color: AppColors.accent),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton.icon(
              onPressed: () => _createCourse(context),
              icon: const Icon(Icons.menu_book_rounded),
              label: const Text('Nouveau cours'),
            ),
            OutlinedButton.icon(
              onPressed: () => _enroll(context),
              icon: const Icon(Icons.how_to_reg_rounded),
              label: const Text('Inscrire un étudiant'),
            ),
          ]),
          const SectionTitle('Cours et enseignants'),
          _table(['Code', 'Cours', 'Enseignant', 'Inscrits'], [
            for (final c in s.courses)
              [
                Text(c.subject),
                Text(c.title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(s.userById(c.teacherId)?.name ?? '-'),
                StatusChip('${s.enrolledCount(c.id)}', AppColors.primary),
              ]
          ]),
        ],
      );

  Widget _scheduleTab(BuildContext context, AppState s) => Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _addSlot(context),
          icon: const Icon(Icons.event),
          label: const Text('Créneau'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          children: [
                       _table(['Jour', 'Horaire', 'Matière', 'Enseignant', 'Salle'], [
              for (final x in s.schedule)
                [
                  Text(AppState.weekdays[x.weekday]),
                  Text('${x.start} - ${x.end}'),
                  Text(x.subject,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(x.teacher),
                  Text(x.room),
                ]
            ]),
          ],
        ),
      );
}
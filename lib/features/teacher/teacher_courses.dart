import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';

class TeacherCourses extends StatelessWidget {
  const TeacherCourses({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final r = await askForm(context, 'Nouveau cours', [
            const Fld('title', 'Titre du cours'),
            const Fld('subject', 'Matière'),
            Fld('class', 'Classe', options: {for (final c in s.classes) c.id: c.name}),
            const Fld('desc', 'Description', multiline: true),
          ], ok: 'Publier');
          if (r == null || r['title']!.isEmpty) return;
          s.publishCourse(r['title']!, r['subject']!, r['class']!, r['desc']!);
          if (context.mounted) toast(context, 'Cours publié, les étudiants sont notifiés.');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau cours'),
      ),
      body: s.myCourses.isEmpty
          ? const EmptyState(Icons.menu_book, 'Vous n\'avez publié aucun cours.')
          : ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 90), children: [
              for (final c in s.myCourses)
                AppCard(
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => TeacherCourseDetail(courseId: c.id))),
                  child: Row(children: [
                    const IconBadge(Icons.menu_book_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(c.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text('${s.className(c.classId)} • ${c.lessons.length} contenus',
                            style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                      ]),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.muted),
                  ]),
                ),
            ]),
    );
  }
}

class TeacherCourseDetail extends StatelessWidget {
  final String courseId;
  const TeacherCourseDetail({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final c = s.courseById(courseId)!;
    return Scaffold(
      appBar: AppBar(title: Text(c.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final r = await askForm(context, 'Ajouter un contenu', const [
            Fld('title', 'Titre'),
            Fld('type', 'Type', options: {'video': 'Vidéo', 'pdf': 'Document PDF'}),
          ], ok: 'Ajouter');
          if (r == null || r['title']!.isEmpty) return;
          s.addLesson(c, r['title']!, r['type'] == 'video');
          if (context.mounted) toast(context, 'Contenu ajouté, notification envoyée.');
        },
        icon: const Icon(Icons.upload_file),
        label: const Text('Ajouter un contenu'),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 90), children: [
        GradientHeader(c.title, '${s.className(c.classId)} • ${c.description}', icon: Icons.menu_book_rounded),
        const SectionTitle('Contenus publiés'),
        if (c.lessons.isEmpty) const EmptyState(Icons.video_library_outlined, 'Aucun contenu.'),
        for (final l in c.lessons)
          AppCard(
            child: Row(children: [
              IconBadge(l.isVideo ? Icons.play_circle_fill : Icons.picture_as_pdf,
                  color: l.isVideo ? AppColors.primary : AppColors.danger),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('${l.isVideo ? "Vidéo" : "PDF"} • ${l.info}',
                      style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ]),
              ),
            ]),
          ),
      ]),
    );
  }
}

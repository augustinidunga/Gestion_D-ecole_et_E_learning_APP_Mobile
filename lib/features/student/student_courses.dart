import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';

class StudentCourses extends StatelessWidget {
  const StudentCourses({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.myCourses;
    if (list.isEmpty) return const EmptyState(Icons.menu_book, 'Aucun cours pour votre classe.');
    return ListView(padding: const EdgeInsets.all(16), children: [
      for (final c in list)
        AppCard(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetail(courseId: c.id))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const IconBadge(Icons.menu_book_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text('${s.userById(c.teacherId)?.name ?? ''} • ${c.lessons.length} contenus',
                      style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ]),
              ),
            ]),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: s.progressOf(c), minHeight: 6),
            ),
            const SizedBox(height: 4),
            Text('${(s.progressOf(c) * 100).round()} % complété',
                style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ]),
        ),
    ]);
  }
}

class CourseDetail extends StatelessWidget {
  final String courseId;
  const CourseDetail({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final c = s.courseById(courseId)!;
    return Scaffold(
      appBar: AppBar(title: Text(c.title)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        GradientHeader(c.title, c.description, icon: Icons.menu_book_rounded),
        const SectionTitle('Contenus du cours'),
        if (c.lessons.isEmpty) const EmptyState(Icons.hourglass_empty, 'Aucun contenu publié pour l\'instant.'),
        for (final l in c.lessons)
          AppCard(
            onTap: () {
              if (!s.canOpen(l)) {
                toast(context, 'Hors connexion : téléchargez ce contenu avant de le consulter.');
                return;
              }
              s.markDone(l);
              Navigator.push(context, MaterialPageRoute(builder: (_) => LessonViewer(lesson: l)));
            },
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
              if (s.doneLessons.contains(l.id)) const Icon(Icons.check_circle, color: AppColors.accent, size: 20),
              IconButton(
                tooltip: 'Télécharger',
                onPressed: s.offline && !s.downloaded.contains(l.id) ? null : () => s.toggleDownload(l),
                icon: Icon(s.downloaded.contains(l.id) ? Icons.download_done : Icons.download_outlined,
                    color: s.downloaded.contains(l.id) ? AppColors.accent : AppColors.muted),
              ),
            ]),
          ),
      ]),
    );
  }
}

/// Lecteur simulé (vidéo HLS / PDF). Brancher video_player / pdfx ici.
class LessonViewer extends StatefulWidget {
  final Lesson lesson;
  const LessonViewer({super.key, required this.lesson});
  @override
  State<LessonViewer> createState() => _LessonViewerState();
}

class _LessonViewerState extends State<LessonViewer> {
  bool _play = false;
  double _pos = 0;

  @override
  Widget build(BuildContext context) {
    final l = widget.lesson;
    return Scaffold(
      appBar: AppBar(title: Text(l.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          AspectRatio(
            aspectRatio: l.isVideo ? 16 / 9 : 3 / 4,
            child: Container(
              decoration: BoxDecoration(
                  color: l.isVideo ? AppColors.dark : Colors.white, borderRadius: BorderRadius.circular(18)),
              child: Center(
                child: Icon(l.isVideo ? (_play ? Icons.pause_circle : Icons.play_circle) : Icons.picture_as_pdf,
                    size: 64, color: l.isVideo ? Colors.white : AppColors.danger),
              ),
            ),
          ),
          if (l.isVideo) ...[
            Slider(value: _pos, onChanged: (v) => setState(() => _pos = v)),
            FilledButton.icon(
              onPressed: () => setState(() => _play = !_play),
              icon: Icon(_play ? Icons.pause : Icons.play_arrow),
              label: Text(_play ? 'Pause' : 'Lecture'),
            ),
            const SizedBox(height: 8),
            const Text('Diffusion adaptative HLS (360p à 1080p) - lecteur simulé.',
                style: TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
        ]),
      ),
    );
  }
}

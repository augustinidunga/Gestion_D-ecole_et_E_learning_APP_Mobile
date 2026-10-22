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
    final s = context.read<AppState>();
    final list = s.myCourses;
    if (list.isEmpty) return const EmptyState(Icons.menu_book, 'Aucun cours pour votre classe.', 'Commencez à suivre vos cours.');
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        for (final c in list)
          AppCardElevated(
            margin: const EdgeInsets.only(bottom: 16),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => CourseDetail(courseId: c.id))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconBadge(Icons.menu_book_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.title,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                          Text(
                            '${s.userById(c.teacherId)?.name ?? ''} • ${c.lessons.length} contenus',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: s.progressOf(c),
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(s.progressOf(c) * 100).round()} % complété',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => CourseDetail(courseId: c.id))),
                      child: const Text('Voir les détails'),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(c.title, style: const TextStyle(fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          GradientHeader(
            c.title,
            c.description,
            icon: Icons.menu_book_rounded,
          ),
          const SectionTitle('Contenus du cours'),
          if (c.lessons.isEmpty)
            const EmptyState(Icons.hourglass_empty, 'Aucun contenu publié pour l\'instant.',
                'Revenez plus tard pour de nouveaux contenus.')
          else
            for (final l in c.lessons)
              AppCardElevated(
                margin: const EdgeInsets.only(bottom: 12),
                onTap: () {
                  if (!s.canOpen(l)) {
                    toast(context, 'Hors connexion : téléchargez ce contenu avant de le consulter.');
                    return;
                  }
                  s.markDone(l);
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => LessonViewer(lesson: l)));
                },
                child: Row(
                  children: [
                    IconBadge(
                      l.isVideo ? Icons.play_circle_fill : Icons.picture_as_pdf,
                      color: l.isVideo ? AppColors.primary : AppColors.danger,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${l.isVideo ? "Vidéo" : "PDF"} • ${l.info}',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (s.doneLessons.contains(l.id))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Terminé',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    IconButton(
                      tooltip: 'Télécharger',
                      onPressed: s.offline && !s.downloaded.contains(l.id)
                          ? null
                          : () => s.toggleDownload(l),
                      icon: Icon(
                        s.downloaded.contains(l.id)
                            ? Icons.download_done
                            : Icons.download_outlined,
                        color: s.downloaded.contains(l.id)
                            ? AppColors.accent
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(l.title, style: const TextStyle(fontSize: 16)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: l.isVideo ? AppColors.dark : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Icon(
                  l.isVideo
                      ? (_play ? Icons.pause_circle : Icons.play_circle)
                      : Icons.picture_as_pdf,
                  size: 72,
                  color: l.isVideo ? Colors.white : AppColors.danger,
                ),
              ),
            ),
            if (l.isVideo) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progression',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: _pos,
                          minHeight: 10,
                          backgroundColor: AppColors.border,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(_pos * 100).round()} %',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppFormButton(
                      onPressed: () => setState(() => _play = !_play),
                      text: _play ? 'Pause' : 'Lecture',
                      icon: _play ? Icons.pause : Icons.play_arrow,
                      expanded: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Diffusion adaptative HLS (360p à 1080p) - lecteur simulé.',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

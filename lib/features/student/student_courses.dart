import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../shared/video_player_screen.dart';

class StudentCourses extends StatelessWidget {
  const StudentCourses({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    final l10n = AppLocalizations.of(context)!;
    final list = s.myCourses;
    if (list.isEmpty) return const EmptyState(Icons.menu_book, '', '');
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
                            style: TextStyle(color: Neumo.of(context).textMuted, fontSize: 12),
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
                      style:  TextStyle(fontSize: 11, color: Neumo.of(context).textMuted),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => CourseDetail(courseId: c.id))),
                      child: Text(l10n.t('student.courses.detail')),
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
    final l10n = AppLocalizations.of(context)!;
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
          SectionTitle(l10n.t('student.courses.lessons')),
          if (c.lessons.isEmpty)
            const EmptyState(Icons.hourglass_empty, '', '')
          else
            for (final l in c.lessons)
              AppCardElevated(
                margin: const EdgeInsets.only(bottom: 12),
onTap: () async {
                  final canOpen = await s.canOpen(l);
                  if (!canOpen) {
                    toast(context, 'Hors connexion : téléchargez ce contenu avant de le consulter.');
                    return;
                  }
                  s.markDone(l);
                  if (l.isVideo) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => VideoLessonScreen(lesson: l)));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => LessonViewer(lesson: l)));
                  }
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
                            '${l.isVideo ? l10n.t('student.courses.video') : l10n.t('student.courses.pdf')} • ${l.info}',
                            style:  TextStyle(
                                color: Neumo.of(context).textMuted, fontSize: 12),
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
                      tooltip: l10n.t('download'),
                      onPressed: s.offline
                          ? null
                          : () => s.toggleDownload(l),
                      icon: FutureBuilder<bool>(
                        future: s.isDownloaded(l.id),
                        builder: (context, snapshot) {
                          final isDownloaded = snapshot.data ?? false;
                          return Icon(
                            isDownloaded
                                ? Icons.download_done
                                : Icons.download_outlined,
                            color: isDownloaded
                                ? AppColors.accent
                                : Neumo.of(context).textMuted,
                          );
                        },
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
  String? _localPath;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    final s = context.read<AppState>();
    final l = widget.lesson;
    String? path;
    if (await s.isDownloaded(l.id)) {
      path = await s.getLocalPath(l.id);
    } else if (l.url != null && l.url!.isNotEmpty) {
      path = l.url;
    }
    if (mounted) {
      setState(() {
        _localPath = path;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lesson;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(l.title, style: const TextStyle(fontSize: 16)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _localPath == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf, size: 72, color: AppColors.danger),
                      const SizedBox(height: 16),
                      Text('Fichier PDF non disponible',
                          style: TextStyle(color: Neumo.of(context).textMuted)),
                    ],
                  ),
                )
              : PDFView(
                  filePath: _localPath!,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: true,
                  pageSnap: true,
                  defaultPage: 0,
                  fitPolicy: FitPolicy.BOTH,
                  onError: (error) {
                    toast(context, 'Erreur chargement PDF: $error');
                  },
                  onRender: (pages) {
                    // PDF rendu avec $pages pages
                  },
                ),
    );
  }
}

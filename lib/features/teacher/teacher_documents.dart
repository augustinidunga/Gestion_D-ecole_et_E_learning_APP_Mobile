import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../shared/video_player_screen.dart';
import '../student/student_courses.dart';

/// Module dédié à l'enseignant pour envoyer des documents
/// (PDF, vidéos, photos) à sa classe.
class TeacherDocuments extends StatefulWidget {
  const TeacherDocuments({super.key});

  @override
  State<TeacherDocuments> createState() => _TeacherDocumentsState();
}

class _TeacherDocumentsState extends State<TeacherDocuments> {
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    final courses = s.myCourses;
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showAddDialog(context, s, l10n, courses),
        icon: const Icon(Icons.cloud_upload_outlined),
        label: Text(l10n.t('teacher.documents.send')),
      ),
      body: courses.isEmpty
          ? const EmptyState(Icons.cloud_outlined, '', '')
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                for (final c in courses) ...[
                  GradientHeader(
                    c.title,
                    '${s.className(c.classId)} • ${c.lessons.length} document(s)',
                    icon: Icons.folder_outlined,
                  ),
                  if (c.lessons.isEmpty)
                    const EmptyState(Icons.description_outlined, '', '')
                  else
                    for (final l in c.lessons)
                      AppCardElevated(
                        margin: const EdgeInsets.only(bottom: 12),
                        onTap: () {
                          if (l.isVideo) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => VideoLessonScreen(lesson: l)));
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => LessonViewer(lesson: l)));
                          }
                        },
                        child: Row(
                          children: [
                            IconBadge(
                              l.isVideo
                                  ? Icons.videocam_outlined
                                  : l.isPhoto
                                      ? Icons.photo_camera_outlined
                                      : Icons.description_outlined,
                              color: l.isVideo
                                  ? AppColors.primary
                                  : l.isPhoto
                                      ? AppColors.warn
                                      : AppColors.danger,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    '${l.isVideo ? l10n.t('teacher.courses.content.video') : l.isPhoto ? l10n.t('teacher.courses.content.photo') : l10n.t('teacher.courses.content.pdf')} • ${l.info}',
                                    style: TextStyle(
                                        color: Neumo.of(context).textMuted,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.share, color: AppColors.primary),
                              onPressed: () => _shareDoc(context, s, l10n, l),
                            ),
                          ],
                        ),
                      ),
                ],
              ],
            ),
    );
  }

  Future<void> _showAddDialog(
      BuildContext context, AppState s, AppLocalizations l10n, List<Course> courses) async {
    if (courses.isEmpty) {
      toast(context, l10n.t('teacher.documents.no.course'));
      return;
    }

    // File Picker standard
    final r = await askForm(context, l10n.t('teacher.documents.send'), [
      Fld('course', l10n.t('teacher.courses.title'),
          options: {for (final c in courses) c.id: c.title}),
      Fld('title', l10n.t('teacher.courses.content.title')),
      Fld('type', l10n.t('teacher.courses.content.type'), options: {
        'video': l10n.t('teacher.courses.content.video'),
        'pdf': l10n.t('teacher.courses.content.pdf'),
      }),
    ], ok: l10n.t('upload'));
    if (r == null || r['title']!.isEmpty || r['course']!.isEmpty) return;
    final course = courses.firstWhere((c) => c.id == r['course']!);
    PlatformFile? picked;
    if (r['type'] == 'video') {
      final files = await FilePicker.pickFiles(
        type: FileType.video,
      );
      if (files.isNotEmpty) picked = files.first;
    } else if (r['type'] == 'pdf') {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      if (files.isNotEmpty) picked = files.first;
    }
    final filePath = picked?.path;
    final isVideo = r['type'] == 'video';
    s.addLesson(course, r['title']!,
        isVideo, url: filePath?.isEmpty == true ? null : filePath,
        isPhoto: false);
    if (context.mounted)
      toast(context, l10n.t('teacher.documents.uploaded'));
  }

  Future<void> _shareDoc(BuildContext context, AppState s, AppLocalizations l10n, Lesson l) async {
    try {
      final filePath = l.url;
      if (filePath != null && File(filePath).existsSync()) {
        await Share.shareXFiles(
          [XFile(filePath)],
          subject: l10n.t('share.subject'),
          text: '${l10n.t('share.text')}\n${l.title}',
        );
      } else {
        await Share.share(
          '${l10n.t('share.text')}\n${l.title}',
          subject: l10n.t('share.subject'),
        );
      }
    } catch (e) {
      if (context.mounted) toast(context, l10n.t('error'));
    }
  }
}
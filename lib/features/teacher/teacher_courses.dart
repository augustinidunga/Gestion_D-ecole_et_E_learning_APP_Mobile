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
import 'teacher_course_upload.dart';

class TeacherCourses extends StatelessWidget {
  const TeacherCourses({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () async {
          final r = await askForm(context, l10n.t('teacher.courses.new'), [
            Fld('title', l10n.t('teacher.courses.content.title')),
            Fld('subject', l10n.t('teacher.courses.content.type')),
            Fld('class', 'Classe', options: {for (final c in s.classes) c.id: c.name}),
            Fld('desc', l10n.t('teacher.courses.content.url'), multiline: true),
          ], ok: l10n.t('teacher.courses.publish'));
          if (r == null || r['title']!.isEmpty) return;
          s.publishCourse(r['title']!, r['subject']!, r['class']!, r['desc']!);
          if (context.mounted)
            toast(context, 'Cours publié, les étudiants sont notifiés.');
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.t('teacher.courses.new')),
      ),
      body: s.myCourses.isEmpty
          ? const EmptyState(Icons.menu_book, '', '')
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                for (final c in s.myCourses)
                  AppCardElevated(
                    margin: const EdgeInsets.only(bottom: 16),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                TeacherCourseDetail(courseId: c.id))),
                    child: Row(
                      children: [
                        const IconBadge(Icons.menu_book_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800),
                              ),
                              Text(
                                '${s.className(c.classId)} • ${c.lessons.length} contenus',
                                style: TextStyle(
                                    color: Neumo.of(context).textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                         Icon(Icons.chevron_right, color: Neumo.of(context).textMuted),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class TeacherCourseDetail extends StatelessWidget {
  final String courseId;
  const TeacherCourseDetail({super.key, required this.courseId});

  Future<void> _shareContent(BuildContext context, AppState s, Lesson l) async {
    final l10n = AppLocalizations.of(context)!;
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
          '${l10n.t('share.text')}\n${l.title}\n${l.url ?? l10n.t('student.payments.download.title')}',
          subject: l10n.t('share.subject'),
        );
      }
    } catch (e) {
      if (context.mounted) toast(context, l10n.t('error'));
    }
  }

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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () async {
          PlatformFile? picked;
          final r = await askForm(context, l10n.t('teacher.courses.add.content'), [
            Fld('title', l10n.t('teacher.courses.content.title')),
            Fld('type', l10n.t('teacher.courses.content.type'), options: {'video': l10n.t('teacher.courses.content.video'), 'pdf': l10n.t('teacher.courses.content.pdf'), 'photo': l10n.t('teacher.courses.content.photo')}),
            Fld('url', l10n.t('teacher.courses.content.url')),
            Fld('meeting', l10n.t('teacher.courses.content.meeting')),
          ], ok: l10n.t('add'));
          if (r == null || r['title']!.isEmpty) return;
          if (r['type'] == 'video') {
            final files = await FilePicker.pickFiles(
              type: FileType.video,
            );
            if (files.isNotEmpty) picked = files.first;
          } else if (r['type'] == 'photo') {
            final files = await FilePicker.pickFiles(
              type: FileType.image,
            );
            if (files.isNotEmpty) picked = files.first;
          } else {
            final files = await FilePicker.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf', 'doc', 'docx'],
            );
            if (files.isNotEmpty) picked = files.first;
          }
           final filePath = picked?.path;
           final url = r['url']!.isEmpty ? filePath : r['url'];
           if ((url == null || url.isEmpty) && r['type'] != 'photo') {
             if (context.mounted) toast(context, 'Ajoutez un lien URL (le fichier local n\'est pas disponible sur le web).');
             return;
           }
           s.addLesson(c, r['title']!, r['type'] == 'video',
              url: url!.isEmpty ? null : url,
              meetingLink: r['meeting']!.isEmpty ? null : r['meeting'],
              isPhoto: r['type'] == 'photo');
          if (context.mounted)
            toast(context, 'Contenu ajouté, notification envoyée.');
        },
        icon: const Icon(Icons.upload_file),
        label: Text(l10n.t('teacher.courses.add.content')),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          GradientHeader(
            c.title,
            '${s.className(c.classId)} • ${c.description}',
            icon: Icons.menu_book_rounded,
          ),
          SectionTitle(l10n.t('teacher.courses.detail')),
          if (c.lessons.isEmpty)
            const EmptyState(Icons.video_library_outlined, '', '')
          else
            for (final l in c.lessons)
              AppCardElevated(
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
                          ? Icons.play_circle_fill
                          : l.isPhoto
                              ? Icons.photo_camera_outlined
                              : Icons.picture_as_pdf,
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
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${l.isVideo ? l10n.t('teacher.courses.content.video') : l10n.t('teacher.courses.content.pdf')} • ${l.info}',
                            style:  TextStyle(
                                color: Neumo.of(context).textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.share, color: AppColors.primary),
                      onPressed: () => _shareContent(context, s, l),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

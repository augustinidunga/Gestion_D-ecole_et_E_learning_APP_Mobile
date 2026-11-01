import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class TeacherCourseUploadScreen extends StatefulWidget {
  final String courseId;
  const TeacherCourseUploadScreen({super.key, required this.courseId});

  @override
  State<TeacherCourseUploadScreen> createState() => _TeacherCourseUploadScreenState();
}

class _TeacherCourseUploadScreenState extends State<TeacherCourseUploadScreen> {
  late AppState s;
  late AppLocalizations l10n;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    s = context.read<AppState>();
    l10n = AppLocalizations.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(l10n.t('teacher.courses.new')),
        actions: [IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.t('teacher.courses.upload.disabled'),
              style: const TextStyle(fontSize: 18, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.t('teacher.courses.use.existing'),
              style: const TextStyle(fontSize: 16, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.t('common.close')),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
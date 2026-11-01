import 'package:flutter/material.dart';

import '../shared/chat_screen.dart';
import '../shared/more_tab.dart';
import '../shared/notifications_screen.dart';
import '../shared/role_shell.dart';
import '../shared/schedule_screen.dart';
import '../shared/settings_screen.dart';
import 'teacher_course_upload.dart';
import '../../l10n/app_localizations.dart';
import 'teacher_analytics.dart';
import 'teacher_assignments.dart';
import 'teacher_attendance.dart';
import 'teacher_assessments.dart';
import 'teacher_courses.dart';
import 'teacher_documents.dart';
import 'teacher_home.dart';
import 'teacher_students.dart';

class TeacherShell extends StatelessWidget {
  const TeacherShell({super.key});

  void _open(BuildContext c, Widget w) =>
      Navigator.push(c, MaterialPageRoute(builder: (_) => w));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RoleShell(tabs: [
      NavTab(l10n.t('home'), Icons.dashboard_outlined, Icons.dashboard_rounded, TeacherHome()),
      NavTab(l10n.t('teacher.courses.title'), Icons.menu_book_outlined, Icons.menu_book_rounded, TeacherCourses()),
      NavTab(l10n.t('teacher.documents.title'), Icons.cloud_outlined, Icons.cloud_rounded, TeacherDocuments()),
      NavTab(l10n.t('student.quiz.title'), Icons.quiz_outlined, Icons.quiz_rounded, TeacherAssessments()),
      NavTab(l10n.t('teacher.student.title'), Icons.groups_outlined, Icons.groups_rounded, TeacherStudents()),
      NavTab(l10n.t('more'), Icons.menu, Icons.menu, MoreTab(entries: [
        MoreEntry(Icons.notifications_outlined, l10n.t('shared.notifications'), l10n.t('shared.notifications'), () => _open(context, const NotificationsScreen())),
        MoreEntry(Icons.upload_file, l10n.t('teacher.courses.upload'), l10n.t('teacher.courses.upload'), () => _open(context, TeacherCourseUploadScreen(courseId: 'k1'))),
        MoreEntry(Icons.calendar_month, l10n.t('teacher.attendance.title'), l10n.t('teacher.attendance.title'), () => _open(context, const ScheduleScreen())),
        MoreEntry(Icons.assignment_outlined, l10n.t('teacher.assignment.title'), l10n.t('teacher.assignment.title'), () => _open(context, const TeacherAssignments())),
        MoreEntry(Icons.fact_check_outlined, l10n.t('teacher.attendance.title'), l10n.t('teacher.attendance.title'), () => _open(context, const TeacherAttendance())),
        MoreEntry(Icons.chat_bubble_outlined, l10n.t('student.payments.receipt'), l10n.t('student.payments.receipt'), () => _open(context, const ChatScreen())),
        MoreEntry(Icons.analytics_outlined, l10n.t('teacher.analytics.title'), l10n.t('teacher.analytics.title'), () => _open(context, const TeacherAnalytics())),
        MoreEntry(Icons.settings_outlined, l10n.t('settings'), l10n.t('settings'), () => _open(context, const SettingsScreen())),
      ])),
    ]);
  }
}

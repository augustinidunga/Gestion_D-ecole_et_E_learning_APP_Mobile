import 'package:flutter/material.dart';

import '../shared/chat_screen.dart';
import '../shared/more_tab.dart';
import '../shared/role_shell.dart';
import '../shared/schedule_screen.dart';
import '../shared/settings_screen.dart';
import 'teacher_analytics.dart';
import 'teacher_assignments.dart';
import 'teacher_attendance.dart';
import 'teacher_assessments.dart';
import 'teacher_courses.dart';
import 'teacher_home.dart';
import 'teacher_students.dart';

class TeacherShell extends StatelessWidget {
  const TeacherShell({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleShell(tabs: [
      const NavTab('Accueil', Icons.dashboard_outlined, Icons.dashboard_rounded, TeacherHome()),
      const NavTab('Cours', Icons.menu_book_outlined, Icons.menu_book_rounded, TeacherCourses()),
      const NavTab('Évaluations', Icons.quiz_outlined, Icons.quiz_rounded, TeacherAssessments()),
      const NavTab('Étudiants', Icons.groups_outlined, Icons.groups_rounded, TeacherStudents()),
      NavTab('Plus', Icons.menu, Icons.menu, MoreTab(entries: [
        MoreEntry(Icons.calendar_month, 'Emploi du temps', 'Vos séances de la semaine', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleScreen()))),
        MoreEntry(Icons.assignment_outlined, 'Devoirs', 'Créer et corriger', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherAssignments()))),
        MoreEntry(Icons.fact_check_outlined, 'Présences', 'Marquer les présences', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherAttendance()))),
        MoreEntry(Icons.chat_bubble_outline, 'Messagerie', 'Échanges avec les étudiants', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
        MoreEntry(Icons.analytics_outlined, 'Analytique', 'Statistiques et progression', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherAnalytics()))),
        MoreEntry(Icons.settings_outlined, 'Paramètres', 'Thème, accessibilité', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
      ])),
    ]);
  }
}

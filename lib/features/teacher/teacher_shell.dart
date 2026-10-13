import 'package:flutter/material.dart';

import '../shared/more_tab.dart';
import '../shared/role_shell.dart';
import '../shared/schedule_screen.dart';
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
        MoreEntry(Icons.calendar_month, 'Emploi du temps', 'Vos séances de la semaine',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleScreen()))),
      ])),
    ]);
  }
}

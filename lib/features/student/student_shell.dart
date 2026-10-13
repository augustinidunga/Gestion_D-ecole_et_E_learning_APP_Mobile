import 'package:flutter/material.dart';

import '../shared/more_tab.dart';
import '../shared/role_shell.dart';
import '../shared/schedule_screen.dart';
import '../shared/tutor_screen.dart';
import 'student_assessments.dart';
import 'student_courses.dart';
import 'student_home.dart';
import 'student_payments.dart';

class StudentShell extends StatelessWidget {
  const StudentShell({super.key});

  void _open(BuildContext c, Widget w) => Navigator.push(c, MaterialPageRoute(builder: (_) => w));

  @override
  Widget build(BuildContext context) {
    return RoleShell(tabs: [
      const NavTab('Accueil', Icons.home_outlined, Icons.home_rounded, StudentHome()),
      const NavTab('Cours', Icons.menu_book_outlined, Icons.menu_book_rounded, StudentCourses()),
      const NavTab('Évaluations', Icons.quiz_outlined, Icons.quiz_rounded, StudentAssessments()),
      const NavTab('Paiements', Icons.payments_outlined, Icons.payments_rounded, StudentPayments()),
      NavTab('Plus', Icons.menu, Icons.menu, MoreTab(showOfflineSwitch: true, entries: [
        MoreEntry(Icons.calendar_month, 'Emploi du temps', 'Vos cours de la semaine',
            () => _open(context, const ScheduleScreen())),
        MoreEntry(Icons.smart_toy_outlined, 'Tuteur IA', 'Explications et exercices personnalisés',
            () => _open(context, const TutorScreen())),
      ])),
    ]);
  }
}

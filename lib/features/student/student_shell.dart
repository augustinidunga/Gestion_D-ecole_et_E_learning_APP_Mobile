import 'package:flutter/material.dart';

import '../shared/chat_screen.dart';
import '../shared/more_tab.dart';
import '../shared/notifications_screen.dart';
import '../shared/role_shell.dart';
import '../shared/schedule_screen.dart';
import '../shared/settings_screen.dart';
import '../shared/tutor_screen.dart';
import 'student_assignments.dart';
import 'student_attendance.dart';
import 'student_assessments.dart';
import 'student_courses.dart';
import 'student_home.dart';
import 'student_payments.dart';
import 'student_report_card.dart';

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
        MoreEntry(Icons.notifications_outlined, 'Notifications', 'Alertes cours, quiz, notes, paiements', () => _open(context, const NotificationsScreen())),
        MoreEntry(Icons.calendar_month, 'Emploi du temps', 'Vos cours de la semaine', () => _open(context, const ScheduleScreen())),
        MoreEntry(Icons.assignment_outlined, 'Devoirs', 'Travaux à rendre et corrections', () => _open(context, const StudentAssignments())),
        MoreEntry(Icons.chat_bubble_outline, 'Messagerie', 'Échanges avec vos enseignants', () => _open(context, const ChatScreen())),
        MoreEntry(Icons.fact_check_outlined, 'Présences', 'Votre assiduité', () => _open(context, const StudentAttendance())),
        MoreEntry(Icons.description_outlined, 'Bulletin', 'Notes et moyenne', () => _open(context, const StudentReportCard())),
        MoreEntry(Icons.smart_toy_outlined, 'Tuteur IA', 'Explications et exercices personnalisés', () => _open(context, const TutorScreen())),
        MoreEntry(Icons.settings_outlined, 'Paramètres', 'Thème, accessibilité', () => _open(context, const SettingsScreen())),
      ])),
    ]);
  }
}

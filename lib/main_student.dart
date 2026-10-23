import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/app_state.dart';
import 'data/models.dart';
import 'features/auth/branded_login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudentApp());
}

/// Application dédiée aux étudiants.
class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const _StudentAppView(),
    );
  }
}

class _StudentAppView extends StatelessWidget {
  const _StudentAppView();

  @override
  Widget build(BuildContext context) {
    return EcoleApp(
      title: 'EduConnect Étudiant',
      lockedRole: Role.student,
      loginBuilder: (context, state) => const BrandedLoginScreen(
        role: Role.student,
        title: 'EduConnect Étudiant',
        subtitle: 'Votre campus dans votre poche',
        gradient: [Color(0xFF5B4BE1), Color(0xFF8B7CF6)],
        heroIcon: Icons.school_rounded,
        demoEmail: 'etudiant@ecole.edu',
        demoPassword: 'etud123',
      ),
    );
  }
}

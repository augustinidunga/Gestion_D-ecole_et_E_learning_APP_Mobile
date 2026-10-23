import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/app_state.dart';
import 'data/models.dart';
import 'features/auth/branded_login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TeacherApp());
}

/// Application dédiée aux enseignants.
class TeacherApp extends StatelessWidget {
  const TeacherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const _TeacherAppView(),
    );
  }
}

class _TeacherAppView extends StatelessWidget {
  const _TeacherAppView();

  @override
  Widget build(BuildContext context) {
    return EcoleApp(
      title: 'EduConnect Enseignant',
      lockedRole: Role.teacher,
      loginBuilder: (context, state) => const BrandedLoginScreen(
        role: Role.teacher,
        title: 'EduConnect Enseignant',
        subtitle: 'Gérez vos classes, vos cours et vos évaluations',
        gradient: [Color(0xFF0E9F7A), Color(0xFF3B82F6)],
        heroIcon: Icons.cast_for_education_rounded,
        demoEmail: 'prof@ecole.edu',
        demoPassword: 'prof123',
      ),
    );
  }
}

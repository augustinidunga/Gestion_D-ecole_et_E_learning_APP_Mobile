import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'data/app_state.dart';
import 'data/models.dart';
import 'features/admin/admin_shell.dart';
import 'features/auth/login_screen.dart';
import 'features/student/student_shell.dart';
import 'features/teacher/teacher_shell.dart';

/// Racine d'application : applique le thème (clair/sombre, contraste élevé),
/// l'échelle de texte et route vers l'espace correspondant au rôle.
class EcoleApp extends StatelessWidget {
  final String title;
  final Role? lockedRole;
  final Widget Function(BuildContext context, AppState state)? loginBuilder;
  const EcoleApp({
    super.key,
    this.title = 'EduConnect',
    this.lockedRole,
    this.loginBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;
    final allowed = user != null && (lockedRole == null || user.role == lockedRole);
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(highContrast: state.highContrast),
      darkTheme: AppTheme.dark(highContrast: state.highContrast),
      themeMode: state.darkMode ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(state.textScale),
            disableAnimations: state.reduceMotion,
          ),
          child: child!,
        );
      },
      home: !allowed
          ? (loginBuilder?.call(context, state) ?? const LoginScreen())
          : switch (user.role) {
              Role.student => const StudentShell(),
              Role.teacher => const TeacherShell(),
              Role.admin => const AdminShell(),
            },
    );
  }
}

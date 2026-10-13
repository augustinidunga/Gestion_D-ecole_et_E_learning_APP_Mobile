import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'data/app_state.dart';
import 'data/models.dart';
import 'features/admin/admin_shell.dart';
import 'features/auth/login_screen.dart';
import 'features/student/student_shell.dart';
import 'features/teacher/teacher_shell.dart';

class EcoleApp extends StatelessWidget {
  const EcoleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().user;
    return MaterialApp(
      title: 'Ecole App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: user == null
          ? const LoginScreen()
          : switch (user.role) {
              Role.student => const StudentShell(),
              Role.teacher => const TeacherShell(),
              Role.admin => const AdminShell(),
            },
    );
  }
}

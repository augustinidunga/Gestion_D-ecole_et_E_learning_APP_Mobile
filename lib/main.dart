import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/app_state.dart';
import 'features/auth/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EcoleAllApp());
}

/// Application complète : étudiants, enseignants et administration.
class EcoleAllApp extends StatelessWidget {
  const EcoleAllApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const _EcoleAllAppView(),
    );
  }
}

class _EcoleAllAppView extends StatelessWidget {
  const _EcoleAllAppView();

  @override
  Widget build(BuildContext context) {
    return EcoleApp(
      title: 'EduConnect',
      loginBuilder: (context, state) => const LoginScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pwd = TextEditingController();
 bool _hide = true;
 bool _loading = false;
  String? _error;

   Future<void> _submit() async {
    if (_loading || !_form.currentState!.validate()) return;
    setState(() {
      _error = null;
      _loading = true;
    });
    final err = await context.read<AppState>().login(_email.text, _pwd.text);
    if (!mounted) return; // connexion réussie : l'écran est déjà remplacé
    setState(() {
      _loading = false;
      _error = err;
    });
  }
  void _fill(String e, String p) => setState(() {
        _email.text = e;
        _pwd.text = p;
        _error = null;
      });

  @override
  void dispose() {
    _email.dispose();
    _pwd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF4F7FB), Color(0xFFEDF2F8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight - 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.dark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.dark.withValues(alpha: .16),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .14),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(Icons.school_rounded,
                                    color: Colors.white, size: 31),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppConfig.appName,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Gestion scolaire et apprentissage',
                                      style:
                                          TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppCard(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _form,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Connexion',
                                  style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'Accédez à votre espace sécurisé.',
                                  style: TextStyle(color: AppColors.muted),
                                ),
                                const SizedBox(height: 22),
                                TextFormField(
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.username],
                                  validator: (value) {
                                    final email = value?.trim() ?? '';
                                    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                            .hasMatch(email)
                                        ? null
                                        : 'Saisissez une adresse email valide.';
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Adresse email',
                                    prefixIcon: Icon(Icons.mail_outline_rounded),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _pwd,
                                  obscureText: _hide,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [AutofillHints.password],
                                  onFieldSubmitted: (_) => _submit(),
                                  validator: (value) => (value ?? '').isEmpty
                                      ? 'Saisissez votre mot de passe.'
                                      : null,
                                  decoration: InputDecoration(
                                    labelText: 'Mot de passe',
                                    prefixIcon:
                                        const Icon(Icons.lock_outline_rounded),
                                    suffixIcon: IconButton(
                                      tooltip: _hide
                                          ? 'Afficher le mot de passe'
                                          : 'Masquer le mot de passe',
                                      icon: Icon(_hide
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined),
                                      onPressed: () =>
                                          setState(() => _hide = !_hide),
                                    ),
                                  ),
                                ),
                                if (_error != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.danger
                                          .withValues(alpha: .08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline_rounded,
                                            color: AppColors.danger, size: 19),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _error!,
                                            style: const TextStyle(
                                                color: AppColors.danger),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 20),
                                              SizedBox(
                                                width: double.infinity,
                                                child: FilledButton.icon(
                                                  onPressed: _loading ? null : _submit,
                                                  icon: _loading
                                                      ? const SizedBox(
                                                          width: 18,
                                                          height: 18,
                                                          child: CircularProgressIndicator(
                                                              strokeWidth: 2))
                                                      : const Icon(Icons.login_rounded),
                                                  label: Text(
                                                      _loading ? 'Connexion…' : 'Se connecter'),
                                                ),
                                              ),
                                const SizedBox(height: 22),
                                const Divider(),
                                const SizedBox(height: 12),
                                const Text(
                                  'Accès de démonstration',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ActionChip(
                                      avatar: const Icon(
                                          Icons.person_outline_rounded,
                                          size: 18),
                                      label: const Text('Étudiant'),
                                      onPressed: () => _fill(
                                          'etudiant@ecole.edu', 'etud123'),
                                    ),
                                    ActionChip(
                                      avatar: const Icon(
                                          Icons.cast_for_education_rounded,
                                          size: 18),
                                      label: const Text('Enseignant'),
                                      onPressed: () =>
                                          _fill('prof@ecole.edu', 'prof123'),
                                    ),
                                    ActionChip(
                                      avatar: const Icon(
                                          Icons.admin_panel_settings_outlined,
                                          size: 18),
                                      label: const Text('Administrateur'),
                                      onPressed: () => _fill(
                                          'admin@ecole.edu', 'admin123'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

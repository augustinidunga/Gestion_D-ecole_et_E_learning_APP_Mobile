import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';

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
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = err;
    });
  }

  void _fill(String email, String pwd) {
    _email.text = email;
    _pwd.text = pwd;
  }

  @override
  void dispose() {
    _email.dispose();
    _pwd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Neumo.of(context).bg, Neumo.of(context).bg],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.35),
                                blurRadius: 32,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.school_rounded,
                              color: Colors.white, size: 44),
                        ),
                        const SizedBox(height: 20),
                        AppCard(
                          padding: const EdgeInsets.all(20),
                          elevation: 1,
                          child: Form(
                            key: _form,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.t('auth.login.title'),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Neumo.of(context).text,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l10n.t('auth.login.subtitle'),
                                  style: TextStyle(color: Neumo.of(context).textMuted),
                                ),
                                const SizedBox(height: 10),
                                AppTextFormField(
                                  controller: _email,
                                  label: l10n.t('auth.email'),
                                  icon: Icons.mail_outline_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    final email = value?.trim() ?? '';
                                    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                            .hasMatch(email)
                                        ? null
                                        : 'Saisissez une adresse email valide.';
                                  },
                                ),
                                AppTextFormField(
                                  controller: _pwd,
                                  label: l10n.t('auth.password'),
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: _hide,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _submit(),
                                  validator: (value) => (value ?? '').isEmpty
                                      ? 'Saisissez votre mot de passe.'
                                      : null,
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
                                if (_error != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.danger.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: AppColors.danger.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                              Icons.error_outline_rounded,
                                              color: AppColors.danger,
                                              size: 18),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            _error!,
                                            style: const TextStyle(
                                                color: AppColors.danger,
                                                fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: AppFormButton(
                                    onPressed: _submit,
                                    text: _loading ? '' : l10n.t('auth.login.button'),
                                    icon: Icons.login_rounded,
                                    loading: _loading,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Divider(),
                                const SizedBox(height: 6),
                                Text(
                                  l10n.t('auth.demo'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Neumo.of(context).text,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ActionButton(
                                        icon: Icons.person_outline_rounded,
                                        label: l10n.t('auth.student'),
                                        onPressed: () => _fill('etudiant@ecole.edu', 'etud123'),
                                        width: double.infinity,
                                        outlined: true,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ActionButton(
                                        icon: Icons.cast_for_education_rounded,
                                        label: l10n.t('auth.teacher'),
                                        onPressed: () => _fill('prof@ecole.edu', 'prof123'),
                                        width: double.infinity,
                                        outlined: true,
                                      ),
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

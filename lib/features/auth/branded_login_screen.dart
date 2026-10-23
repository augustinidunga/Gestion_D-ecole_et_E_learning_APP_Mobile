import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';

class BrandedLoginScreen extends StatefulWidget {
  final Role role;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData heroIcon;
  final String demoEmail;
  final String demoPassword;
  const BrandedLoginScreen({
    super.key,
    required this.role,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.heroIcon,
    required this.demoEmail,
    required this.demoPassword,
  });

  @override
  State<BrandedLoginScreen> createState() => _BrandedLoginScreenState();
}

class _BrandedLoginScreenState extends State<BrandedLoginScreen>
    with SingleTickerProviderStateMixin {
  final _email = TextEditingController();
  final _pwd = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscure = true;
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    _email.dispose();
    _pwd.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    final err = context.read<AppState>().login(_email.text, _pwd.text);
    if (!mounted) return;
    if (err != null) {
      setState(() => _loading = false);
      toast(context, err);
      return;
    }
    final u = context.read<AppState>().user!;
    if (u.role != widget.role) {
      context.read<AppState>().logout();
      setState(() => _loading = false);
      toast(context, 'Ce compte n\'est pas autorisé dans cette application.');
      return;
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // animated blobs
          AnimatedBuilder(
            animation: _anim,
            builder: (ctx, _) {
              final t = _anim.value;
              return Stack(children: [
                Positioned(
                  top: -60 + 40 * (0.5 + 0.5 * (t * 2 - 1).clamp(-1, 1)),
                  left: -40,
                  child: _blob(180, Colors.white.withOpacity(0.08)),
                ),
                Positioned(
                  bottom: -80 + 60 * (0.5 + 0.5 * (1 - t * 2).clamp(-1, 1)),
                  right: -60,
                  child: _blob(220, Colors.white.withOpacity(0.06)),
                ),
              ]);
            },
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Icon(widget.heroIcon, size: 46, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(widget.subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Neumo.of(context).surface,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: NeumoShadows.raised(
                            elevation: 10, dark: Neumo.of(context).isDark),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Connexion', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Neumo.of(context).text)),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(fontSize: 15, color: Neumo.of(context).text),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.alternate_email_rounded),
                                filled: true,
                                fillColor: Neumo.of(context).bg,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              ),
                              validator: (v) => (v == null || !v.contains('@')) ? 'Email invalide' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _pwd,
                              obscureText: _obscure,
                              style: TextStyle(fontSize: 15, color: Neumo.of(context).text),
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                prefixIcon: const Icon(Icons.lock_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                                filled: true,
                                fillColor: Neumo.of(context).bg,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              ),
                              validator: (v) => (v == null || v.length < 3) ? 'Mot de passe requis' : null,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 52,
                              child: FilledButton(
                                onPressed: _loading ? null : _submit,
                                style: FilledButton.styleFrom(
                                  backgroundColor: widget.gradient.first,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: _loading
                                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                    : const Text('Se connecter', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Neumo.of(context).bg,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Compte démo', style: TextStyle(fontSize: 11, color: Neumo.of(context).textMuted, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text('${widget.demoEmail} / ${widget.demoPassword}', style: TextStyle(fontSize: 12, color: Neumo.of(context).text, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      _email.text = widget.demoEmail;
                                      _pwd.text = widget.demoPassword;
                                    },
                                    icon: const Icon(Icons.auto_awesome, size: 16),
                                    label: const Text('Remplir automatiquement'),
                                    style: OutlinedButton.styleFrom(foregroundColor: widget.gradient.first),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('© EduConnect — ${widget.title}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

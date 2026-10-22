import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';

class TutorScreen extends StatefulWidget {
  const TutorScreen({super.key});
  @override
  State<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  final _ctrl = TextEditingController();
  final _msgs = <(bool, String)>[
    (false, "Bonjour ! Je suis votre tuteur pédagogique IA. Posez-moi une question sur vos cours."),
  ];

  void _send(String text) {
    if (text.trim().isEmpty) return;
    final s = context.read<AppState>();
    setState(() {
      _msgs.add((true, text.trim()));
      _msgs.add((false, s.tutorReply(text)));
      _ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final reco = s.recommendations(s.user!.id);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Tuteur IA'),
      ),
      body: Column(
        children: [
          if (reco.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warn.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_rounded, color: AppColors.warn, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'À réviser : ${reco.join(' ; ')}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final m in _msgs)
                  Align(
                    alignment: m.$1 ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: m.$1 ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: m.$1 ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        m.$2,
                        style: TextStyle(
                          color: m.$1 ? Colors.white : AppColors.text,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Les réponses de l\'IA doivent être vérifiées pour les contenus importants.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final q in [
                  'Explique la récursivité',
                  'Comment fonctionne une boucle ?',
                  "C'est quoi SQL ?"
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AppFormButton(
                      expanded: false,
                      text: q,
                      icon: Icons.lightbulb_rounded,
                      color: AppColors.bg,
                      onPressed: () => _send(q),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        onSubmitted: _send,
                        decoration: const InputDecoration(
                          hintText: 'Posez votre question…',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton.filled(
                      onPressed: () => _send(_ctrl.text),
                      icon: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
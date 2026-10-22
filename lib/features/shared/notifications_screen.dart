import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static (IconData, Color) _style(String t) => switch (t) {
        'cours' => (Icons.menu_book_rounded, AppColors.primary),
        'quiz' => (Icons.quiz_rounded, AppColors.warn),
        'note' => (Icons.grade_rounded, AppColors.accent),
        'paiement' => (Icons.payments_rounded, const Color(0xFF8B5CF6)),
        _ => (Icons.campaign_rounded, AppColors.dark),
      };

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.myNotifs;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: s.markAllRead,
            child: const Text('Tout lire', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: list.isEmpty
          ? const EmptyState(
              Icons.notifications_off_outlined,
              'Aucune notification',
              'Vous n\'avez aucune notification pour le moment.')
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                for (final n in list)
                  AppCardElevated(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconBadge(_style(n.type).$1, color: _style(n.type).$2),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title,
                                style: TextStyle(
                                  fontWeight:
                                      s.isRead(n) ? FontWeight.w600 : FontWeight.w800,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(n.body, style: const TextStyle(color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    fmtDate(n.date),
                                    style: const TextStyle(
                                        fontSize: 11, color: AppColors.textMuted),
                                  ),
                                  if (!s.isRead(n)) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
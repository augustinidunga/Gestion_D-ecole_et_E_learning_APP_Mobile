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
        'paiement' => (Icons.payments_rounded, Colors.purple),
        _ => (Icons.campaign_rounded, AppColors.dark),
      };

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.myNotifs;
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), actions: [
        TextButton(onPressed: s.markAllRead, child: const Text('Tout lire')),
      ]),
      body: list.isEmpty
          ? const EmptyState(Icons.notifications_off_outlined, 'Aucune notification')
          : ListView(padding: const EdgeInsets.all(16), children: [
              for (final n in list)
                AppCard(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    IconBadge(_style(n.type).$1, color: _style(n.type).$2),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(n.title,
                            style: TextStyle(
                                fontWeight: s.isRead(n) ? FontWeight.w600 : FontWeight.w800,
                                color: AppColors.text)),
                        const SizedBox(height: 2),
                        Text(n.body, style: const TextStyle(color: AppColors.muted)),
                        const SizedBox(height: 4),
                        Text(fmtDate(n.date), style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                      ]),
                    ),
                    if (!s.isRead(n))
                      const Icon(Icons.circle, size: 10, color: AppColors.primary),
                  ]),
                ),
            ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../data/app_state.dart';
import 'notifications_screen.dart';

class NavTab {
  final String label;
  final IconData icon, activeIcon;
  final Widget page;
  const NavTab(this.label, this.icon, this.activeIcon, this.page);
}

/// Coquille commune : barre du haut (notifications, mode hors connexion)
/// + navigation inférieure propre à chaque profil.
class RoleShell extends StatefulWidget {
  final List<NavTab> tabs;
  const RoleShell({super.key, required this.tabs});
  @override
  State<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends State<RoleShell> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'EduConnect',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(widget.tabs[_i].label),
              ],
            ),
          ),
        ]),
        actions: [
          if (s.offline)
            IconButton(
              tooltip: 'Mode hors connexion',
              onPressed: null,
              icon: const Icon(Icons.cloud_off_rounded, color: AppColors.warn),
            ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            icon: Badge(
              isLabelVisible: s.unreadCount > 0,
              label: Text('${s.unreadCount}'),
              child: const Icon(Icons.notifications_none_rounded),
            ),
          ),
          IconButton(
            tooltip: 'Profil et paramètres',
            onPressed: () => setState(() => _i = widget.tabs.length - 1),
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: .1),
              child: Text(
                s.user!.initials,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: _i, children: [for (final t in widget.tabs) t.page]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: [
          for (final t in widget.tabs)
            NavigationDestination(icon: Icon(t.icon), selectedIcon: Icon(t.activeIcon), label: t.label),
        ],
      ),
    );
  }
}

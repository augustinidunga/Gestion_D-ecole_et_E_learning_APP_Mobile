import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';

class MoreEntry {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const MoreEntry(this.icon, this.title, this.subtitle, this.onTap);
}

class MoreTab extends StatelessWidget {
  final List<MoreEntry> entries;
  final bool showOfflineSwitch;
  const MoreTab({super.key, this.entries = const [], this.showOfflineSwitch = false});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final u = s.user!;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        AppCardElevated(
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary,
                child: Text(
                  u.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      u.email,
                      style: TextStyle(color: Neumo.of(context).textMuted, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    StatusChip(
                      u.role == Role.student
                          ? '${u.role.label} • ${s.className(u.classId)}'
                          : u.role.label,
                      AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showOfflineSwitch)
          AppCardElevated(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: s.offline,
              onChanged: (v) {
                s.setOffline(v);
                toast(context, v
                    ? 'Mode hors connexion activé'
                    : 'Connexion rétablie, synchronisation effectuée');
              },
              title: const Text(
                'Mode hors connexion',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                s.pendingSyncCount > 0
                    ? '${s.pendingSyncCount} réponse(s) en attente de synchronisation'
                    : 'Simule la perte de connexion ; les quiz sont synchronisés au retour.',
                style: const TextStyle(fontSize: 12),
              ),
              activeColor: AppColors.primary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: AppColors.border,
            ),
          ),
        for (final e in entries)
          AppCardElevated(
            margin: const EdgeInsets.only(bottom: 10),
            onTap: e.onTap,
            child: Row(
              children: [
                IconBadge(e.icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.title,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Neumo.of(context).text),
                      ),
                      Text(
                        e.subtitle,
                        style:  TextStyle(fontSize: 12, color: Neumo.of(context).textMuted),
                      ),
                    ],
                  ),
                ),
                 Icon(Icons.chevron_right_rounded, color: Neumo.of(context).textMuted),
              ],
            ),
          ),
        const SizedBox(height: 16),
        AppFormButton(
          onPressed: s.logout,
          text: 'Se déconnecter',
          icon: Icons.logout_rounded,
          color: AppColors.danger,
        ),
      ],
    );
  }
}

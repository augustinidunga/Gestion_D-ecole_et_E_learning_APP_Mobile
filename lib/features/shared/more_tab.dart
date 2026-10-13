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

/// Onglet « Profil / Plus » partagé par les trois profils.
class MoreTab extends StatelessWidget {
  final List<MoreEntry> entries;
  final bool showOfflineSwitch;
  const MoreTab({super.key, this.entries = const [], this.showOfflineSwitch = false});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final u = s.user!;
    return ListView(padding: const EdgeInsets.all(16), children: [
      AppCard(
        child: Row(children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary,
            child: Text(u.initials,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(u.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              Text(u.email, style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 6),
              StatusChip(u.role == Role.student ? '${u.role.label} • ${s.className(u.classId)}' : u.role.label,
                  AppColors.primary),
            ]),
          ),
        ]),
      ),
      if (showOfflineSwitch)
        AppCard(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: s.offline,
            onChanged: (v) {
              s.setOffline(v);
              toast(context, v ? 'Mode hors connexion activé' : 'Connexion rétablie, synchronisation effectuée');
            },
            title: const Text('Mode hors connexion', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(s.pendingSyncCount > 0
                ? '${s.pendingSyncCount} réponse(s) en attente de synchronisation'
                : 'Simule la perte de connexion ; les quiz sont synchronisés au retour.'),
          ),
        ),
      for (final e in entries)
        AppCard(
          onTap: e.onTap,
          child: Row(children: [
            IconBadge(e.icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(e.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              ]),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ]),
        ),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: s.logout,
        icon: const Icon(Icons.logout),
        label: const Text('Se déconnecter'),
        style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 48), foregroundColor: AppColors.danger),
      ),
    ]);
  }
}

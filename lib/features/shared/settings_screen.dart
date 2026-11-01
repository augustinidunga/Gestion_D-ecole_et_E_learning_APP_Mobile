import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Map<String, String> _languages = {
    'fr': '🇫🇷 Français',
    'en': '🇬🇧 English',
  };

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    final palette = Neumo.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NeumoSurface(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.t('language'),
                  style: TextStyle(fontWeight: FontWeight.w700, color: palette.text)),
              const SizedBox(height: 4),
              Text('${l10n.t('connected.as')} ${s.locale.languageCode.toUpperCase()}',
                  style: TextStyle(fontSize: 12, color: palette.textMuted)),
              const SizedBox(height: 14),
              ..._languages.entries.map((entry) {
                final isSelected = s.locale.languageCode == entry.key;
                return ListTile(
                  leading: Text(entry.value.split(' ').first,
                      style: const TextStyle(fontSize: 24)),
                  title: Text(entry.value.split(' ').last,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isSelected ? AppColors.primary : palette.text)),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    s.setLocale(entry.key);
                  },
                );
              }).toList(),
            ]),
          ),
          const SizedBox(height: 12),
          NeumoSurface(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: s.darkMode,
              onChanged: (_) => s.toggleDarkMode(),
              title: Text(l10n.t('dark.mode'),
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: palette.text)),
              subtitle: Text('Thème sombre à contraste élevé',
                  style: TextStyle(fontSize: 12, color: palette.textMuted)),
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary,
            ),
          ),
          NeumoSurface(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.t('text.size'),
                  style:
                      TextStyle(fontWeight: FontWeight.w700, color: palette.text)),
              const SizedBox(height: 4),
              Text('Ajustez la lisibilité de toute l\'application',
                  style: TextStyle(fontSize: 12, color: palette.textMuted)),
              Slider(
                value: s.textScale,
                min: 0.8,
                max: 1.4,
                divisions: 6,
                label: s.textScale.toStringAsFixed(1),
                onChanged: s.setTextScale,
              ),
              Text('Aperçu : ${s.textScale.toStringAsFixed(1)}x',
                  style: TextStyle(color: palette.textMuted, fontSize: 12)),
            ]),
          ),
          NeumoSurface(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: s.highContrast,
              onChanged: (_) => s.toggleHighContrast(),
              title: Text(l10n.t('high.contrast'),
                  style:
                      TextStyle(fontWeight: FontWeight.w700, color: palette.text)),
              subtitle: Text('Noirs et blancs francs pour une lecture nette',
                  style: TextStyle(fontSize: 12, color: palette.textMuted)),
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary,
            ),
          ),
          NeumoSurface(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: s.reduceMotion,
              onChanged: (_) => s.toggleReduceMotion(),
              title: Text(l10n.t('reduce.motion'),
                  style:
                      TextStyle(fontWeight: FontWeight.w700, color: palette.text)),
              subtitle: Text('Limite les mouvements de l\'interface',
                  style: TextStyle(fontSize: 12, color: palette.textMuted)),
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary,
            ),
          ),
          NeumoSurface(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.t('account'),
                  style:
                      TextStyle(fontWeight: FontWeight.w700, color: palette.text)),
              const SizedBox(height: 10),
              Row(children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    s.user?.initials ?? '?',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.user?.name ?? '',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: palette.text)),
                    Text(s.user?.email ?? '',
                        style:
                            TextStyle(fontSize: 12, color: palette.textMuted)),
                  ]),
                ),
                StatusChip(s.user?.role.label ?? '', AppColors.primary),
              ]),
            ]),
          ),
          const SizedBox(height: 8),
          AppFormButton(
            onPressed: s.logout,
            text: l10n.t('logout'),
            icon: Icons.logout_rounded,
            color: AppColors.danger,
          ),
        ],
      ),
    );
  }
}

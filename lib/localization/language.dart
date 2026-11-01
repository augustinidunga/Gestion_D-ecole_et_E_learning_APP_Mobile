import 'package:flutter/material.dart';

/// Langues supportées par l'application (FR par défaut, ENG disponible).
enum AppLanguage { fr, en }

extension AppLanguageX on AppLanguage {
  String get code => switch (this) {
        AppLanguage.fr => 'fr',
        AppLanguage.en => 'en',
      };

  String get label => switch (this) {
        AppLanguage.fr => 'Français',
        AppLanguage.en => 'English',
      };

  /// Icône du drapeau (emoji) — sert de « logo » de la langue dans le sélecteur.
  String get flag => switch (this) {
        AppLanguage.fr => '🇫🇷',
        AppLanguage.en => '🇬🇧',
      };
}

/// Résout la langue à partir d'un code (ex: 'en', 'FR').
AppLanguage languageFromCode(String? code) {
  if (code == null) return AppLanguage.fr;
  final c = code.toLowerCase();
  return switch (c) {
    'en' || 'en-us' || 'en-gb' => AppLanguage.en,
    _ => AppLanguage.fr,
  };
}
import 'package:flutter/material.dart';

class AppConfig {
  static const appName = 'Gestion Ecole & E-Learning ';
  static const currency = 'USD';
}

/// Palette « Neumorphism » : fonds doux, ombres bidirectionnelles,
/// contrastes lisibles (texte foncé sur fond clair).
class AppColors {
  static const primary = Color(0xFF5B4BE1);
  static const primaryLight = Color(0xFF8B7CF6);
  static const dark = Color(0xFF2D3436);
  static const accent = Color(0xFF0FA37F);
  static const warn = Color(0xFFD98A2B);
  static const danger = Color(0xFFD05555);
  static const bg = Color(0xFFE6EAF0);
  static const surface = Color(0xFFE6EAF0);
  static const text = Color(0xFF2B3138);
  static const textMuted = Color(0xFF5F6B7A);
  static const border = Colors.transparent;
  static const success = Color(0xFF0FA37F);
  static const info = Color(0xFF2F80ED);

  static const lightShadow = Color(0xFFFFFFFF);
  static const darkShadow = Color(0xFFB9C2CE);

  // Variante sombre
  static const darkBg = Color(0xFF2B3138);
  static const darkSurface = Color(0xFF2B3138);
  static const darkText = Color(0xFFEDF1F7);
  static const darkTextMuted = Color(0xFFAEB8C4);
  static const darkLightShadow = Color(0xFF3A424C);
  static const darkDarkShadow = Color(0xFF20252B);
}

/// Ombres « neumorphiques » (une lumière, une ombre).
class NeumoShadows {
  static List<BoxShadow> raised({double elevation = 6, bool dark = false}) => [
        BoxShadow(
          color: (dark ? AppColors.darkLightShadow : AppColors.lightShadow)
              .withOpacity(dark ? 0.55 : 0.9),
          offset: Offset(-elevation * 0.6, -elevation * 0.6),
          blurRadius: elevation * 1.6,
        ),
        BoxShadow(
          color: (dark ? AppColors.darkDarkShadow : AppColors.darkShadow)
              .withOpacity(dark ? 0.9 : 0.55),
          offset: Offset(elevation * 0.6, elevation * 0.6),
          blurRadius: elevation * 1.6,
        ),
      ];

  static List<BoxShadow> inset({double elevation = 4, bool dark = false}) => [
        BoxShadow(
          color: (dark ? AppColors.darkDarkShadow : AppColors.darkShadow)
              .withOpacity(dark ? 0.9 : 0.5),
          offset: Offset(elevation * 0.5, elevation * 0.5),
          blurRadius: elevation * 1.4,
        ),
        BoxShadow(
          color: (dark ? AppColors.darkLightShadow : AppColors.lightShadow)
              .withOpacity(dark ? 0.5 : 0.85),
          offset: Offset(-elevation * 0.5, -elevation * 0.5),
          blurRadius: elevation * 1.4,
        ),
      ];
}

/// Palette sémantique dépendante du thème (lecture garantie).
@immutable
class NeumoPalette extends ThemeExtension<NeumoPalette> {
  final Color bg;
  final Color surface;
  final Color text;
  final Color textMuted;
  final Color shadowLight;
  final Color shadowDark;

  const NeumoPalette({
    required this.bg,
    required this.surface,
    required this.text,
    required this.textMuted,
    required this.shadowLight,
    required this.shadowDark,
  });

  static const light = NeumoPalette(
    bg: Color(0xFFE6EAF0),
    surface: Color(0xFFE6EAF0),
    text: Color(0xFF232A33),
    textMuted: Color(0xFF5B6675),
    shadowLight: Color(0xFFFFFFFF),
    shadowDark: Color(0xFFB9C2CE),
  );

  static const dark = NeumoPalette(
    bg: Color(0xFF272D35),
    surface: Color(0xFF272D35),
    text: Color(0xFFF1F5FA),
    textMuted: Color(0xFFAEB8C4),
    shadowLight: Color(0xFF39414C),
    shadowDark: Color(0xFF1B2027),
  );

  static const highContrastLight = NeumoPalette(
    bg: Color(0xFFF7F9FC),
    surface: Color(0xFFFFFFFF),
    text: Color(0xFF000000),
    textMuted: Color(0xFF2B3138),
    shadowLight: Color(0xFFFFFFFF),
    shadowDark: Color(0xFF8A94A3),
  );

  static const highContrastDark = NeumoPalette(
    bg: Color(0xFF101419),
    surface: Color(0xFF161B21),
    text: Color(0xFFFFFFFF),
    textMuted: Color(0xFFD6DEE8),
    shadowLight: Color(0xFF303945),
    shadowDark: Color(0xFF000000),
  );

  bool get isDark => shadowLight == dark.shadowLight;

  @override
  NeumoPalette copyWith({
    Color? bg,
    Color? surface,
    Color? text,
    Color? textMuted,
    Color? shadowLight,
    Color? shadowDark,
  }) =>
      NeumoPalette(
        bg: bg ?? this.bg,
        surface: surface ?? this.surface,
        text: text ?? this.text,
        textMuted: textMuted ?? this.textMuted,
        shadowLight: shadowLight ?? this.shadowLight,
        shadowDark: shadowDark ?? this.shadowDark,
      );

  @override
  NeumoPalette lerp(ThemeExtension<NeumoPalette>? other, double t) {
    if (other is! NeumoPalette) return this;
    return NeumoPalette(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      shadowLight: Color.lerp(shadowLight, other.shadowLight, t)!,
      shadowDark: Color.lerp(shadowDark, other.shadowDark, t)!,
    );
  }
}

/// Accès rapide à la palette du thème courant.
class Neumo {
  const Neumo._();
  static NeumoPalette of(BuildContext context) =>
      Theme.of(context).extension<NeumoPalette>() ?? NeumoPalette.light;

  static List<BoxShadow> raised(BuildContext context, {double elevation = 6}) =>
      NeumoShadows.raised(
        elevation: elevation,
        dark: of(context).isDark,
      );

  static List<BoxShadow> inset(BuildContext context, {double elevation = 4}) =>
      NeumoShadows.inset(
        elevation: elevation,
        dark: of(context).isDark,
      );
}

class AppTheme {
  static ThemeData light({bool highContrast = false}) {
    final palette = highContrast ? NeumoPalette.highContrastLight : NeumoPalette.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: palette.surface,
      error: AppColors.danger,
    ).copyWith(tertiary: AppColors.warn);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      extensions: [palette],
      scaffoldBackgroundColor: palette.bg,
      fontFamily: 'Poppins, Roboto, sans-serif',
      textTheme: TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.3, color: palette.text),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3, color: palette.text),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4, color: palette.text),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: palette.text),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: palette.text),
        bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: palette.text),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: palette.text),
        bodySmall: TextStyle(fontSize: 12, height: 1.4, color: palette.textMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: palette.text,
        centerTitle: false,
        titleTextStyle: TextStyle(color: palette.text, fontSize: 18, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.bg,
        elevation: 0,
        indicatorColor: AppColors.primary.withOpacity(0.12),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.textMuted,
        )),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w500),
        hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.7)),
        prefixIconColor: AppColors.primary,
        suffixIconColor: AppColors.primary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.4),
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primary,
          minimumSize: const Size(0, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.dark,
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: AppColors.accent,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFD3DAE3), thickness: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected)
            ? Colors.white
            : AppColors.textMuted),
        trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.bg),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bg,
        labelStyle: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.darkShadow.withOpacity(0.4),
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.12),
        trackHeight: 6,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(fontSize: 16, color: AppColors.text),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.bg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  static ThemeData dark({bool highContrast = false}) {
    final palette = highContrast ? NeumoPalette.highContrastDark : NeumoPalette.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      secondary: AppColors.accent,
      surface: palette.surface,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      extensions: [palette],
      scaffoldBackgroundColor: palette.bg,
      fontFamily: 'Poppins, Roboto, sans-serif',
      textTheme: TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.3, color: palette.text),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3, color: palette.text),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4, color: palette.text),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: palette.text),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: palette.text),
        bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: palette.text),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: palette.text),
        bodySmall: TextStyle(fontSize: 12, height: 1.4, color: palette.textMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: palette.text,
        centerTitle: false,
        titleTextStyle: TextStyle(color: palette.text, fontSize: 18, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.bg,
        elevation: 0,
        indicatorColor: AppColors.primary.withOpacity(0.2),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: palette.text),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.primaryLight
              : palette.textMuted,
        )),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.darkTextMuted, fontWeight: FontWeight.w500),
        hintStyle: TextStyle(color: palette.textMuted.withOpacity(0.7)),
        prefixIconColor: AppColors.primaryLight,
        suffixIconColor: AppColors.primaryLight,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: const Color(0xFF14181D),
          minimumSize: const Size(0, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primaryLight, width: 1.4),
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color(0xFF14181D),
          backgroundColor: AppColors.primaryLight,
          minimumSize: const Size(0, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: const Color(0xFF14181D),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.darkText,
        contentTextStyle: const TextStyle(color: AppColors.darkBg),
        actionTextColor: AppColors.accent,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF3A424C), thickness: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected)
            ? const Color(0xFF14181D)
            : AppColors.darkTextMuted),
        trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected)
            ? AppColors.primaryLight
            : AppColors.darkBg),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryLight,
        inactiveTrackColor: AppColors.darkDarkShadow,
        thumbColor: AppColors.primaryLight,
        overlayColor: AppColors.primaryLight.withOpacity(0.12),
        trackHeight: 6,
      ),
    );
  }
}


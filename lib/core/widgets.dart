import 'package:flutter/material.dart';

import 'theme.dart';

String fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
String fmtMoney(num v) => '${v.toStringAsFixed(0)} ${AppConfig.currency}';
const weekdays = ['', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];

void toast(BuildContext c, String msg) => ScaffoldMessenger.of(c)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));

/// Surface « neumorphique » : même couleur que le fond, ombre double.
class NeumoSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final double elevation;
  final bool inset;
  final bool pressed;
  final Color? color;
  final VoidCallback? onTap;
  final EdgeInsets margin;

  const NeumoSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
    this.elevation = 6,
    this.inset = false,
    this.pressed = false,
    this.color,
    this.onTap,
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  @override
  Widget build(BuildContext context) {
    final palette = Neumo.of(context);
    final base = color ?? palette.surface;
    final shadows = inset
        ? NeumoShadows.inset(elevation: elevation, dark: palette.isDark)
        : NeumoShadows.raised(elevation: elevation, dark: palette.isDark);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: pressed
            ? [
                BoxShadow(
                  color: (palette.isDark
                          ? AppColors.darkDarkShadow
                          : AppColors.darkShadow)
                      .withOpacity(palette.isDark ? 0.7 : 0.35),
                  offset: const Offset(2, 2),
                  blurRadius: 6,
                ),
              ]
            : shadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final Color color;
  final double elevation;
  final bool border;
  final EdgeInsets margin;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
    this.elevation = 5,
    this.border = true,
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  @override
  Widget build(BuildContext context) => NeumoSurface(
        child: child,
        padding: padding,
        elevation: elevation,
        color: color == Colors.white ? null : color,
        margin: margin,
        onTap: onTap,
      );
}

class AppCardElevated extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap;

  const AppCardElevated({
    super.key,
    required this.child,
    this.margin,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => NeumoSurface(
        child: child,
        padding: padding,
        elevation: 7,
        color: color == Colors.white ? null : color,
        margin: margin ?? const EdgeInsets.only(bottom: 12),
        onTap: onTap,
      );
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) {
    final palette = Neumo.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 10),
      child: Row(children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: palette.text,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ]),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  const StatusChip(this.text, this.color, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.14),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      );
}

class StatTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const StatTile(this.icon, this.label, this.value,
      {super.key, this.color = AppColors.primary});
  @override
  Widget build(BuildContext context) {
    final palette = Neumo.of(context);
    return Expanded(
      child: NeumoSurface(
        padding: const EdgeInsets.all(14),
        elevation: 6,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(height: 10),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: palette.text,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
                fontSize: 12,
                color: palette.textMuted,
                fontWeight: FontWeight.w600),
          ),
        ]),
      ),
    );
  }
}

class GradientHeader extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final List<Color>? gradientColors;
  const GradientHeader(this.title, this.subtitle,
      {super.key, this.icon = Icons.school_rounded, this.gradientColors});
  @override
  Widget build(BuildContext context) {
    final palette = Neumo.of(context);
    final colors = gradientColors ??
        const [Color(0xFF5B4BE1), Color(0xFF8B7CF6)];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: NeumoShadows.raised(elevation: 8, dark: palette.isDark),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              title,
              style: TextStyle(
                color: palette.text,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(color: palette.textMuted, fontSize: 13),
            ),
          ]),
        ),
        const SizedBox(width: 14),
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: colors.last.withOpacity(0.45),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, size: 28, color: Colors.white),
        ),
      ]),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? subtext;
  const EmptyState(this.icon, this.text, [this.subtext]);
  @override
  Widget build(BuildContext context) {
    final palette = Neumo.of(context);
    return Padding(
      padding: const EdgeInsets.all(36),
      child: Center(
        child: Column(children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: NeumoShadows.raised(
                  elevation: 5, dark: palette.isDark),
            ),
            child: Icon(icon, size: 32, color: palette.textMuted),
          ),
          const SizedBox(height: 14),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.text,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtext != null) ...[
            const SizedBox(height: 6),
            Text(
              subtext!,
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.textMuted, fontSize: 13),
            ),
          ],
        ]),
      ),
    );
  }
}

class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const IconBadge(this.icon, {super.key, this.color = AppColors.primary, this.size = 42});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.14),
          borderRadius: BorderRadius.circular(size * 0.33),
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      );
}

class AppInputDecoration {
  static InputDecoration formField({
    required String label,
    IconData? icon,
    String? hint,
    Widget? suffix,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon) : null,
      suffixIcon: suffix,
      errorText: errorText,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    );
  }
}

class FormSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  const FormSection({super.key, required this.title, this.subtitle, required this.children});

  @override
  Widget build(BuildContext context) {
    final palette = Neumo.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: palette.text,
        ),
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 4),
        Text(subtitle!, style: TextStyle(color: palette.textMuted, fontSize: 13)),
      ],
      const SizedBox(height: 14),
      ...children,
    ]);
  }
}

/// Bouton neumorphique (relief doux, texte coloré).
class AppFormButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool expanded;
  final Color? color;
  final bool loading;

  const AppFormButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.expanded = true,
    this.color,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Neumo.of(context);
    final accent = color ?? AppColors.primary;
    final enabled = onPressed != null && !loading;
    final btn = NeumoSurface(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      radius: 16,
      elevation: 5,
      pressed: !enabled,
      color: palette.surface,
      onTap: enabled ? onPressed : null,
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(color: accent, strokeWidth: 2.4),
            )
          else if (icon != null)
            Icon(icon, color: enabled ? accent : palette.textMuted, size: 20),
          if (icon != null || loading) const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: enabled ? accent : palette.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

class AppTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final IconData? icon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? hintText;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final ValueChanged<String>? onFieldSubmitted;

  const AppTextFormField({
    super.key,
    this.controller,
    required this.label,
    this.icon,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.hintText,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.maxLines,
    this.onChanged,
    this.errorText,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Neumo.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: NeumoShadows.inset(elevation: 3, dark: palette.isDark),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: validator,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines ?? 1,
        style: TextStyle(fontSize: 15, color: palette.text),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon:
              icon != null ? Icon(icon, color: AppColors.primary) : null,
          suffixIcon: suffixIcon,
          errorText: errorText,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          filled: true,
          fillColor: Colors.transparent,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class AppDropdownFormField<T> extends StatelessWidget {
  final T? value;
  final String label;
  final IconData? icon;
  final List<DropdownMenuEntry<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? errorText;
  final bool expanded;

  const AppDropdownFormField({
    super.key,
    this.value,
    required this.label,
    this.icon,
    required this.items,
    this.onChanged,
    this.errorText,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Neumo.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: NeumoShadows.inset(elevation: 3, dark: palette.isDark),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownMenu<T>(
        initialSelection: value,
        label: Text(label),
        leadingIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
        dropdownMenuEntries: items,
        onSelected: onChanged,
        errorText: errorText,
        expandedInsets: expanded ? null : EdgeInsets.zero,
        textStyle: TextStyle(fontSize: 15, color: palette.text),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(palette.surface),
          surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final bool outlined;
  final double? width;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    this.outlined = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Neumo.of(context);
    final effectiveColor = color ?? AppColors.primary;
    final btn = NeumoSurface(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      radius: 15,
      elevation: 5,
      onTap: onPressed,
      color: palette.surface,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: effectiveColor, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: effectiveColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14),
            ),
          ),
        ],
      ),
    );
    return width != null ? SizedBox(width: width, child: btn) : btn;
  }
}

/// Champ de formulaire générique pour [askForm].
class Fld {
  final String key, label;
  final Map<String, String>? options;
  final bool number, multiline, obscure;
  const Fld(this.key, this.label,
      {this.options, this.number = false, this.multiline = false, this.obscure = false});
}

Future<Map<String, String>?> askForm(
  BuildContext context,
  String title,
  List<Fld> fields, {
  String ok = 'Valider',
}) {
  final ctrls = {for (final f in fields) f.key: TextEditingController()};
  final sel = {
    for (final f in fields)
      if (f.options != null && f.options!.isNotEmpty) f.key: f.options!.keys.first
  };
  return showGeneralDialog<Map<String, String>>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, anim1, anim2) => StatefulBuilder(
      builder: (ctx, set) => Material(
        child: Center(
          child: Container(
            width: 440,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.82,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Neumo.of(context).surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: NeumoShadows.raised(elevation: 10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5B4BE1), Color(0xFF8B7CF6)],
                    ),
                  ),
                  child: Row(children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit_note_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ]),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(22),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      for (final f in fields)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: f.options != null
                              ? DropdownButtonFormField<String>(
                                  initialValue: sel[f.key],
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: f.label,
                                    prefixIcon:
                                        const Icon(Icons.arrow_drop_down, size: 20),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  items: [
                                    for (final e in f.options!.entries)
                                      DropdownMenuItem(
                                          value: e.key, child: Text(e.value))
                                  ],
                                  onChanged: (v) => set(() => sel[f.key] = v!),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: Neumo.of(context).surface,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: NeumoShadows.inset(elevation: 3),
                                  ),
                                  child: TextField(
                                    controller: ctrls[f.key],
                                    obscureText: f.obscure,
                                    keyboardType: f.number
                                        ? TextInputType.number
                                        : null,
                                    maxLines: f.multiline ? 3 : 1,
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Neumo.of(context).text),
                                    decoration: InputDecoration(
                                      labelText: f.label,
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.auto,
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                    ]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: NeumoSurface(
                        margin: EdgeInsets.zero,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        radius: 14,
                        elevation: 4,
                        onTap: () => Navigator.pop(ctx, {
                          for (final f in fields)
                            f.key: f.options != null
                                ? (sel[f.key] ?? '')
                                : ctrls[f.key]!.text.trim()
                        }),
                        child: Center(
                          child: Text(ok,
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

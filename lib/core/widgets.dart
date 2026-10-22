import 'package:flutter/material.dart';

import 'theme.dart';

String fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
String fmtMoney(num v) => '${v.toStringAsFixed(0)} ${AppConfig.currency}';
const weekdays = ['', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];

void toast(BuildContext c, String msg) => ScaffoldMessenger.of(c)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));

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
    this.elevation = 0,
    this.border = true,
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color == Colors.white ? AppColors.surface : color;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(20),
        border: border
            ? Border.all(color: AppColors.border.withOpacity(0.5), width: 0.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: elevation > 0
                ? AppColors.dark.withOpacity(0.06)
                : Colors.transparent,
            blurRadius: elevation > 0 ? 20 : 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
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
  Widget build(BuildContext context) => AppCard(
    child: child,
    padding: padding,
    color: color,
    elevation: 1,
    margin: margin ?? const EdgeInsets.only(bottom: 12),
    onTap: onTap,
  );
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 10),
    child: Row(children: [
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
      ),
      if (trailing != null) trailing!,
    ]),
  );
}

class StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  const StatusChip(this.text, this.color, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(50),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
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
  Widget build(BuildContext context) => Expanded(
    child: AppCard(
      padding: const EdgeInsets.all(16),
      elevation: 0.5,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 10),
        FittedBox(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
        ),
      ]),
    ),
  );
}

class GradientHeader extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final List<Color>? gradientColors;
  const GradientHeader(this.title, this.subtitle,
      {super.key, this.icon = Icons.school_rounded, this.gradientColors});
  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? [AppColors.primary, AppColors.primaryLight];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
            ),
          ]),
        ),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, size: 32, color: Colors.white),
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(40),
    child: Center(
      child: Column(children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.textMuted.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, size: 32, color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtext != null) ...[
          const SizedBox(height: 6),
          Text(
            subtext!,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ]),
    ),
  );
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
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Icon(icon, color: color, size: 22),
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 4),
        Text(subtitle!, style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
      ],
      const SizedBox(height: 14),
      ...children,
    ]);
  }
}

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
    final btn = FilledButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : (icon != null ? Icon(icon) : null),
      label: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      style: color != null
          ? FilledButton.styleFrom(
              backgroundColor: color!,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            )
          : null,
    );
    return expanded
        ? SizedBox(width: double.infinity, child: btn)
        : btn;
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: icon != null
              ? Icon(icon, color: AppColors.primary)
              : null,
          suffixIcon: suffixIcon,
          errorText: errorText,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          filled: true,
          fillColor: readOnly
              ? AppColors.bg.withOpacity(0.5)
              : AppColors.surface,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownMenu<T>(
        initialSelection: value,
        label: Text(label),
        leadingIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
        dropdownMenuEntries: items,
        onSelected: onChanged,
        errorText: errorText,
        expandedInsets: expanded ? null : EdgeInsets.zero,
        textStyle: const TextStyle(fontSize: 15),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.surface),
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
    final effectiveColor = color ?? AppColors.primary;
    Widget btn;
    if (outlined) {
      btn = OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: effectiveColor),
        label: Text(label, style: TextStyle(color: effectiveColor, fontWeight: FontWeight.w600)),
      );
    } else {
      btn = FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        style: FilledButton.styleFrom(backgroundColor: effectiveColor),
      );
    }
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
      builder: (ctx, set) => Center(
        child: Container(
          width: 440,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.dark.withOpacity(0.25),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
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
                  color: AppColors.primary,
                ),
                child: Row(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 20),
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
                                  prefixIcon: const Icon(Icons.arrow_downward, size: 18),
                                ),
                                items: [
                                  for (final e in f.options!.entries)
                                    DropdownMenuItem(value: e.key, child: Text(e.value))
                                ],
                                onChanged: (v) => set(() => sel[f.key] = v!),
                              )
                            : TextField(
                                controller: ctrls[f.key],
                                obscureText: f.obscure,
                                keyboardType: f.number ? TextInputType.number : null,
                                maxLines: f.multiline ? 3 : 1,
                                style: const TextStyle(fontSize: 15),
                                decoration: InputDecoration(
                                  labelText: f.label,
                                  floatingLabelBehavior: FloatingLabelBehavior.auto,
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
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx, {
                        for (final f in fields)
                          f.key: f.options != null
                              ? (sel[f.key] ?? '')
                              : ctrls[f.key]!.text.trim()
                      }),
                      child: Text(ok, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

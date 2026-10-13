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
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.dark.withValues(alpha: .035),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      );
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        child: Row(children: [
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text))),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style:
                TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
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
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(height: 8),
            FittedBox(
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text))),
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ]),
        ),
      );
}

class GradientHeader extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  const GradientHeader(this.title, this.subtitle,
      {super.key, this.icon = Icons.school_rounded});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.dark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(color: Colors.white70)),
            ]),
          ),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(icon, size: 29, color: Colors.white),
          ),
        ]),
      );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  const EmptyState(this.icon, this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(children: [
            Icon(icon, size: 44, color: AppColors.muted.withValues(alpha: .5)),
            const SizedBox(height: 8),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted)),
          ]),
        ),
      );
}

class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const IconBadge(this.icon, {super.key, this.color = AppColors.primary});
  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
            color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color),
      );
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
    BuildContext context, String title, List<Fld> fields,
    {String ok = 'Valider'}) {
  final ctrls = {for (final f in fields) f.key: TextEditingController()};
  final sel = {
    for (final f in fields)
      if (f.options != null && f.options!.isNotEmpty) f.key: f.options!.keys.first
  };
  return showDialog<Map<String, String>>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, set) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            for (final f in fields)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: f.options != null
                    ? DropdownButtonFormField<String>(
                        initialValue: sel[f.key],
                        isExpanded: true,
                        decoration: InputDecoration(labelText: f.label),
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
                        decoration: InputDecoration(labelText: f.label),
                      ),
              ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, {
              for (final f in fields)
                f.key: f.options != null ? (sel[f.key] ?? '') : ctrls[f.key]!.text.trim()
            }),
            child: Text(ok),
          ),
        ],
      ),
    ),
  );
}

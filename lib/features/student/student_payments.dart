import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';

class StudentPayments extends StatelessWidget {
  const StudentPayments({super.key});

  Future<void> _pay(BuildContext context, Invoice inv) async {
    final s = context.read<AppState>();
    final l10n = AppLocalizations.of(context)!;
    if (s.offline) {
      toast(context, l10n.t('student.payments.impossible.offline'));
      return;
    }
    final r = await askForm(context, l10n.t('student.payments.pay.button') + ' ${fmtMoney(inv.amount)}', [
      Fld('op', l10n.t('student.payments.operator'),
          options: {'Airtel Money': 'Airtel Money', 'Orange Money': 'Orange Money', 'M-Pesa': 'M-Pesa', 'MTN MoMo': 'MTN MoMo', 'Limicash': 'Limicash', 'Ecocash': 'Ecocash'}),
      Fld('phone', l10n.t('student.payments.phone'), number: true),
    ], ok: l10n.t('student.payments.pay.button'));
    if (r == null || !context.mounted) return;
    toast(context, l10n.t('student.payments.verifying'));
    final ok = await s.payInvoice(inv, r['op']!, r['phone']!);
    if (!context.mounted) return;
    if (ok) {
      await _showConfirmation(context, s, inv);
    } else {
      toast(context, l10n.t('student.payments.rejected'));
    }
  }

  Future<void> _showConfirmation(BuildContext context, AppState s, Invoice inv) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.accent),
            SizedBox(width: 8),
            Text(l10n.t('student.payments.confirm.title')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.t('student.payments.confirm.body') + ' ${fmtMoney(inv.amount)} ' + l10n.t('student.payments.confirm.title').toLowerCase() + '.'),
            const SizedBox(height: 8),
            Text(l10n.t('student.payments.confirm.receipt') + ' : ${inv.receipt}', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(l10n.t('student.payments.download.title'),
                style: TextStyle(color: Neumo.of(context).textMuted, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.t('no'))),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _downloadReceipt(context, s, inv);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.download, size: 18),
                SizedBox(width: 8),
                Text(l10n.t('student.payments.download.receipt')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadReceipt(BuildContext context, AppState s, Invoice inv) async {
    final l10n = AppLocalizations.of(context)!;
    if (kIsWeb) {
      final text = s.receiptText(inv);
      if (text.isEmpty) {
        toast(context, l10n.t('student.payments.download.failure'));
        return;
      }
      await Share.share(text, subject: 'Reçu ${inv.receipt}');
      toast(context, l10n.t('student.payments.download.success'));
      return;
    }
    toast(context, l10n.t('student.payments.download.title'));
    final path = await s.downloadReceipt(inv);
    if (!context.mounted) return;
    if (path != null) {
      toast(context, l10n.t('student.payments.download.success') + ' : $path');
    } else {
      toast(context, l10n.t('student.payments.download.failure'));
    }
  }

  Future<void> _receipt(BuildContext context, Invoice i) async {
    final l10n = AppLocalizations.of(context)!;
    final s = context.read<AppState>();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.receipt_long, color: AppColors.primary),
              SizedBox(width: 8),
              Text(l10n.t('student.payments.receipt')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.t('student.payments.confirm.receipt') + ' ${i.receipt}', style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(i.label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(l10n.t('student.payments.amount') + ' : ${fmtMoney(i.amount)}'),
              Text(l10n.t('student.payments.method') + ' : ${i.method}'),
              Text(l10n.t('student.payments.date') + ' : ${fmtDate(i.paidOn!)}'),
               const SizedBox(height: 8),
               const Divider(),
               const SizedBox(height: 8),
               Center(
                 child: QrImageView(
                   data: 'Reçu: ${i.receipt}\nÉlève: ${s.userById(i.studentId)?.name ?? i.studentId}\nFilière: ${s.classes.where((c) => c.id == s.userById(i.studentId)?.classId).firstOrNull?.name ?? '-'}\nLibellé: ${i.label}\nMontant: ${fmtMoney(i.amount)}\nMode: ${i.method}\nDate: ${fmtDate(i.paidOn!)} ${i.paidOn!.hour.toString().padLeft(2, '0')}:${i.paidOn!.minute.toString().padLeft(2, '0')}',
                   version: QrVersions.auto,
                   size: 160,
                 ),
               ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.t('close'))),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                final s = context.read<AppState>();
                unawaited(_downloadReceipt(context, s, i));
              },
              child: Text(l10n.t('student.payments.download.receipt')),
            ),
          ],
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    final list = s.invoicesOf(s.user!.id);
    final paid = list.where((i) => i.paid).fold(0, (a, i) => a + i.amount);
    final due = s.effectiveDue(s.user!.id);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Row(
          children: [
            StatTile(Icons.check_circle_rounded, l10n.t('student.payments.paid'), fmtMoney(paid), color: AppColors.accent),
            StatTile(Icons.pending_actions_rounded, l10n.t('student.payments.due'), fmtMoney(due),
                color: AppColors.danger),
          ],
        ),
        const SizedBox(height: 16),
        if (s.invoicesOf(s.user!.id).where((i) => !i.paid).isNotEmpty) ...[
          SectionTitle('Factures à payer'),
          for (final i in list.where((i) => !i.paid))
            AppCardElevated(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconBadge(Icons.payments_rounded, color: AppColors.warn),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(i.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text('Échéance : ${fmtDate(i.due)}', style: TextStyle(color: Neumo.of(context).textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text(fmtMoney(i.amount), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _pay(context, i),
                      icon: const Icon(Icons.payments_rounded),
                      label: Text(l10n.t('student.payments.pay.button')),
                    ),
                  ),
                ],
              ),
            ),
        ],
        if (s.invoicesOf(s.user!.id).where((i) => i.paid).isNotEmpty) ...[
          SectionTitle('Factures payées'),
          for (final i in list.where((i) => i.paid))
            AppCardElevated(
              margin: const EdgeInsets.only(bottom: 12),
              onTap: () => _receipt(context, i),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconBadge(Icons.receipt_long, color: AppColors.accent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(i.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text('Payé le ${fmtDate(i.paidOn!)} • ${i.receipt}', style: TextStyle(color: Neumo.of(context).textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ActionButton(
                          icon: Icons.visibility,
                          label: 'Voir le reçu',
                          onPressed: () => _receipt(context, i),
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ActionButton(
                          icon: Icons.file_download,
                          label: l10n.t('student.payments.receipt'),
                          onPressed: () => _downloadReceipt(context, s, i),
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ActionButton(
                          icon: Icons.restart_alt,
                          label: 'Réinitialiser',
                          onPressed: () => s.resetInvoice(i),
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
        if (list.isEmpty) const EmptyState(Icons.receipt_long, '', ''),
      ],
    );
  }
}

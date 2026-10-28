import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';

class StudentPayments extends StatelessWidget {
  const StudentPayments({super.key});

  Future<void> _pay(BuildContext context, Invoice inv) async {
    final s = context.read<AppState>();
    if (s.offline) {
      toast(context, 'Paiement impossible hors connexion.');
      return;
    }
    final r = await askForm(context, 'Payer ${fmtMoney(inv.amount)}', const [
      Fld('op', 'Opérateur Mobile Money',
          options: {'Lumicash': 'Lumicash', 'EcoCash': 'EcoCash'}),
      Fld('phone', 'Numéro de téléphone (8 chiffres)', number: true),
    ], ok: 'Payer');
    if (r == null || !context.mounted) return;
    final err = await s.payInvoice(inv, r['op']!, r['phone']!);
    if (!context.mounted) return;
    toast(context,
        err ?? 'Demande envoyée. Validez le paiement sur votre téléphone.');
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.invoicesOf(s.user!.id);
    final paid = list.where((i) => i.paid).fold(0, (a, i) => a + i.amount);
    final due = s.dueOf(s.user!.id);
    return RefreshIndicator(
      onRefresh: () async {
        try {
          await s.loadInvoices();
        } on ApiException {}
      },
      child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [
              StatTile(Icons.check_circle, 'Payé', fmtMoney(paid), color: AppColors.accent),
              StatTile(Icons.pending_actions, 'Reste à payer', fmtMoney(due), color: AppColors.danger),
            ]),
            const SizedBox(height: 12),
            const SectionTitle('Frais scolaires et modules'),
            if (list.isEmpty) const EmptyState(Icons.receipt_long, 'Aucune facture.'),
            for (final i in list)
              Builder(builder: (_) {
                final (label, color) = switch (i.status) {
                  'paid' => ('Payé', AppColors.accent),
                  'pending' => ('En attente', AppColors.warn),
                  'overdue' => ('En retard', AppColors.danger),
                  _ => ('À payer', AppColors.primary),
                };
                final canPay = i.status == 'unpaid' || i.status == 'overdue';
                final sub = switch (i.status) {
                  'paid' => 'Paiement confirmé',
                  'pending' => 'Confirmation en cours',
                  _ => i.id.startsWith('course:')
                      ? 'Module payant'
                      : 'Échéance : ${fmtDate(i.due)}',
                };
                return AppCard(
                  child: Row(children: [
                    IconBadge(i.paid ? Icons.receipt_long : Icons.payments_rounded, color: color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(i.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(sub, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                      ]),
                    ),
                    if (canPay)
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(fmtMoney(i.amount), style: const TextStyle(fontWeight: FontWeight.w800)),
                        TextButton(onPressed: () => _pay(context, i), child: const Text('Payer')),
                      ])
                    else
                      StatusChip(label, color),
                  ]),
                );
              }),
          ]),
    );
  }
}
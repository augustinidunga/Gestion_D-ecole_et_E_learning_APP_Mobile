import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final r = await askForm(context, 'Payer ${fmtMoney(inv.amount)}', [
      Fld('op', 'Opérateur Mobile Money',
          options: {'Airtel Money': 'Airtel Money', 'Orange Money': 'Orange Money', 'M-Pesa': 'M-Pesa', 'MTN MoMo': 'MTN MoMo'}),
      Fld('phone', 'Numéro de téléphone', number: true),
    ], ok: 'Payer');
    if (r == null || !context.mounted) return;
    toast(context, 'Vérification du paiement en cours…');
    final ok = await s.payInvoice(inv, r['op']!, r['phone']!);
    if (!context.mounted) return;
    toast(context, ok ? 'Paiement confirmé, reçu disponible.' : 'Paiement refusé : numéro invalide.');
  }

  void _receipt(BuildContext context, Invoice i) => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.receipt_long, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Reçu de paiement'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('N° ${i.receipt}', style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(i.label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Montant : ${fmtMoney(i.amount)}'),
              Text('Mode : ${i.method}'),
              Text('Date : ${fmtDate(i.paidOn!)}'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer')),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.invoicesOf(s.user!.id);
    final paid = list.where((i) => i.paid).fold(0, (a, i) => a + i.amount);
    final due = s.dueOf(s.user!.id);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Row(
          children: [
            StatTile(Icons.check_circle_rounded, 'Payé', fmtMoney(paid), color: AppColors.accent),
            StatTile(Icons.pending_actions_rounded, 'Reste à payer', fmtMoney(due),
                color: AppColors.danger),
          ],
        ),
        const SizedBox(height: 16),
        const SectionTitle('Frais scolaires (tranches)'),
        if (list.isEmpty)
          const EmptyState(Icons.receipt_long, 'Aucune facture.', 'Aucune facture n\'est disponible pour le moment.')
        else
          for (final i in list)
            AppCardElevated(
              margin: const EdgeInsets.only(bottom: 12),
              onTap: i.paid ? () => _receipt(context, i) : null,
              child: Row(
                children: [
                  IconBadge(
                    i.paid ? Icons.receipt_long : Icons.payments_rounded,
                    color: i.paid ? AppColors.accent : AppColors.warn,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          i.label,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          i.paid
                              ? 'Payé le ${fmtDate(i.paidOn!)} • ${i.receipt}'
                              : 'Échéance : ${fmtDate(i.due)}',
                          style: TextStyle(color: Neumo.of(context).textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  i.paid
                      ? const StatusChip('Payé', AppColors.accent)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              fmtMoney(i.amount),
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            TextButton(
                              onPressed: () => _pay(context, i),
                              child: const Text('Payer'),
                            ),
                          ],
                        ),
                ],
              ),
            ),
      ],
    );
  }
}

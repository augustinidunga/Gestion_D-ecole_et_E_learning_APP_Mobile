import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';

class AdminFinance extends StatelessWidget {
  const AdminFinance({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () async {
          final r = await askForm(context, 'Nouvelle facture', [
            Fld('student', 'Étudiant', options: {for (final u in s.students) u.id: u.name}),
            const Fld('label', 'Libellé (ex. Tranche 2)'),
            const Fld('amount', 'Montant', number: true),
            const Fld('days', 'Échéance (jours)', number: true),
          ], ok: 'Émettre');
          if (r == null) return;
          final amount = int.tryParse(r['amount']!);
          if (amount == null || amount <= 0 || r['label']!.isEmpty) {
            if (context.mounted)
              toast(context, 'Libellé et montant valides requis.');
            return;
          }
          s.createInvoice(r['student']!, r['label']!, amount, int.tryParse(r['days']!) ?? 30);
          if (context.mounted)
            toast(context, 'Facture émise, l\'étudiant est notifié.');
        },
        icon: const Icon(Icons.add),
        label: const Text('Facture'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Row(
            children: [
              StatTile(Icons.check_circle_rounded, 'Encaissé', fmtMoney(s.totalCollected),
                  color: AppColors.accent),
              StatTile(Icons.pending_actions_rounded, 'En attente', fmtMoney(s.totalPending),
                  color: AppColors.warn),
            ],
          ),
          const SizedBox(height: 12),
          AppFormButton(
            text: 'Accorder une bourse',
            icon: Icons.card_giftcard_rounded,
            color: AppColors.accent,
            onPressed: () async {
              final r = await askForm(context, 'Bourse', [
                Fld('student', 'Étudiant', options: {for (final u in s.students) u.id: u.name}),
                const Fld('label', 'Libellé'),
                const Fld('discount', 'Réduction %', number: true),
              ], ok: 'Accorder');
              if (r == null) return;
              final d = int.tryParse(r['discount']!);
              if (d == null || r['label']!.isEmpty) {
                toast(context, 'Données invalides');
                return;
              }
              s.grantScholarship(r['student']!, r['label']!, d);
              toast(context, 'Bourse accordée');
            },
          ),
          const SizedBox(height: 16),
          const SectionTitle('Bourses accordées'),
          if (s.scholarships.isEmpty)
            AppCard(child: Text('Aucune bourse', style: TextStyle(color: Neumo.of(context).textMuted)))
          else
            for (final sc in s.scholarships)
              AppCardElevated(
                child: Row(children: [
                  IconBadge(Icons.card_giftcard_rounded, color: AppColors.accent),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.userById(sc.studentId)?.name ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text('${sc.label} (-${sc.discount}%)', style:  TextStyle(fontSize: 12, color: Neumo.of(context).textMuted)),
                  ])),
                ]),
              ),
          const SizedBox(height: 16),
          const SectionTitle('Factures et transactions'),
          for (final i in (s.invoices.toList()
                ..sort((a, b) => a.paid == b.paid
                    ? a.due.compareTo(b.due)
                    : (a.paid ? 1 : -1))))
            AppCardElevated(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  IconBadge(
                    i.paid ? Icons.receipt_long : Icons.hourglass_bottom,
                    color: i.paid ? AppColors.accent : AppColors.warn,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.userById(i.studentId)?.name ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${i.label} • ${fmtMoney(i.amount)} • Solde effectif ${fmtMoney(s.effectiveDue(i.studentId))}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          i.paid
                              ? '${i.receipt} • ${i.method} • ${fmtDate(i.paidOn!)}'
                              : 'Échéance ${fmtDate(i.due)}',
                          style:  TextStyle(color: Neumo.of(context).textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(i.paid ? 'Payé' : 'Impayé',
                      i.paid ? AppColors.accent : AppColors.warn),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

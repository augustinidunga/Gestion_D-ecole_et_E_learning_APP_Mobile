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
            if (context.mounted) toast(context, 'Libellé et montant valides requis.');
            return;
          }
          s.createInvoice(r['student']!, r['label']!, amount, int.tryParse(r['days']!) ?? 30);
          if (context.mounted) toast(context, 'Facture émise, l\'étudiant est notifié.');
        },
        icon: const Icon(Icons.add),
        label: const Text('Facture'),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 90), children: [
        Row(children: [
          StatTile(Icons.check_circle, 'Encaissé', fmtMoney(s.totalCollected), color: AppColors.accent),
          StatTile(Icons.pending_actions, 'En attente', fmtMoney(s.totalPending), color: AppColors.warn),
        ]),
        const SectionTitle('Factures et transactions'),
        for (final i in (s.invoices.toList()..sort((a, b) => a.paid == b.paid ? a.due.compareTo(b.due) : (a.paid ? 1 : -1))))
          AppCard(
            child: Row(children: [
              IconBadge(i.paid ? Icons.receipt_long : Icons.hourglass_bottom,
                  color: i.paid ? AppColors.accent : AppColors.warn),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.userById(i.studentId)?.name ?? '', style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text('${i.label} • ${fmtMoney(i.amount)}', style: const TextStyle(fontSize: 12)),
                  Text(i.paid ? '${i.receipt} • ${i.method} • ${fmtDate(i.paidOn!)}' : 'Échéance ${fmtDate(i.due)}',
                      style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                ]),
              ),
              StatusChip(i.paid ? 'Payé' : 'Impayé', i.paid ? AppColors.accent : AppColors.warn),
            ]),
          ),
      ]),
    );
  }
}

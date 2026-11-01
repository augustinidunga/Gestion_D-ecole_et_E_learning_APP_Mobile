import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';

class AdminFinance extends StatelessWidget {
  const AdminFinance({super.key});

  int _n(dynamic v) => double.tryParse('$v')?.round() ?? 0;

  DataRow _row(BuildContext context, AppState s, Map a) {
    final status =
        '${a['status'] ?? (_n(a['balance']) <= 0 ? 'paid' : 'unpaid')}';
    final label = {'paid': 'Soldé', 'partial': 'Partiel'}[status] ?? 'Impayé';
    final color = status == 'paid'
        ? AppColors.accent
        : status == 'partial'
            ? Colors.orange
            : AppColors.warn;
    final name = s.userById('${a['student']['id']}')?.name ??
        '${a['student']['name'] ?? a['student']['full_name'] ?? ''}';
    return DataRow(cells: [
      DataCell(Text(name,
          style: const TextStyle(fontWeight: FontWeight.w700))),
      DataCell(Text(fmtMoney(_n(a['total_due'])))),
      DataCell(Text(fmtMoney(_n(a['total_paid'])))),
      DataCell(Text(fmtMoney(_n(a['balance'])))),
      DataCell(StatusChip(label, color)),
      DataCell(_actions(context, s, a, name)),
    ]);
  }

  Widget _actions(BuildContext context, AppState s, Map a, String name) {
    Widget btn(IconData i, String tip, VoidCallback f, {Color? c}) =>
        IconButton(
          icon: Icon(i, size: 18, color: c),
          tooltip: tip,
          visualDensity: VisualDensity.compact,
          onPressed: f,
        );

    return Row(mainAxisSize: MainAxisSize.min, children: [
      btn(Icons.visibility_outlined, 'Voir', () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total dû : ${fmtMoney(_n(a['total_due']))}'),
                Text('Payé : ${fmtMoney(_n(a['total_paid']))}'),
                Text('Reste : ${fmtMoney(_n(a['balance']))}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      }),
      btn(Icons.payments_outlined, 'Paiement', () {
        // TODO: enregistrer un paiement manuel (backend à ajouter)
        toast(context, 'Paiement : à brancher.');
      }, c: AppColors.accent),
      btn(Icons.edit_outlined, 'Modifier', () {
        // TODO: modifier le compte / les frais de l'étudiant
        toast(context, 'Modifier : à brancher.');
      }),
      btn(Icons.delete_outline, 'Supprimer', () async {
        final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Supprimer ?'),
            content: Text('Confirmer la suppression pour $name.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        );
        if (ok == true && context.mounted) {
          // TODO: appel de suppression
          toast(context, 'Suppression : à brancher.');
        }
      }, c: Colors.red),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () async {
          final r = await askForm(context, 'Nouvelle tranche', [
            const Fld('fee', 'Frais (ex. Scolarité 2026-2027)'),
            const Fld('label', 'Libellé (ex. Tranche 2)'),
            const Fld('amount', 'Montant', number: true),
            const Fld('days', 'Échéance (jours)', number: true),
          ], ok: 'Créer');
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
        label: const Text('Tranche'),
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
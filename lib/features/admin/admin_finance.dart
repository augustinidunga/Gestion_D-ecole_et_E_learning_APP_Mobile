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
        heroTag: null,
        onPressed: () async {
          final r = await askForm(context, 'Nouvelle tranche', [
            const Fld('fee', 'Frais (ex. Scolarité 2026-2027)'),
            const Fld('label', 'Libellé (ex. Tranche 2)'),
            const Fld('amount', 'Montant', number: true),
            const Fld('days', 'Échéance (jours)', number: true),
          ], ok: 'Créer');
          if (r == null) return;
          final amount = int.tryParse(r['amount']!);
          if (amount == null ||
              amount <= 0 ||
              r['label']!.trim().isEmpty ||
              r['fee']!.trim().isEmpty) {
            if (context.mounted) {
              toast(context, 'Frais, libellé et montant valides requis.');
            }
            return;
          }
          final err = await s.createInstallment(
            r['fee']!,
            r['label']!,
            amount,
            int.tryParse(r['days']!) ?? 30,
          );
          if (context.mounted) {
            toast(context, err ?? 'Tranche créée.');
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tranche'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        children: [
          Row(children: [
            StatTile(Icons.check_circle, 'Encaissé', fmtMoney(s.totalCollected),
                color: AppColors.accent),
            StatTile(Icons.pending_actions, 'En attente',
                fmtMoney(s.totalPending),
                color: AppColors.warn),
          ]),
          const SectionTitle('Suivi des comptes étudiants'),
          AppCard(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 64,
                ),
                child: DataTable(
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 12),
                  columns: const [
                    DataColumn(label: Text('Étudiant')),
                    DataColumn(label: Text('Total dû'), numeric: true),
                    DataColumn(label: Text('Payé'), numeric: true),
                    DataColumn(label: Text('Reste'), numeric: true),
                    DataColumn(label: Text('Statut')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: [
                    for (final a in s.accounts) _row(context, s, a),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';

class AdminAnnouncements extends StatefulWidget {
  const AdminAnnouncements({super.key});
  @override
  State<AdminAnnouncements> createState() => _AdminAnnouncementsState();
}

class _AdminAnnouncementsState extends State<AdminAnnouncements> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  Role? _target;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final history = s.notifs.where((n) => n.type == 'annonce').toList()..sort((a, b) => b.date.compareTo(a.date));
    return Scaffold(
      appBar: AppBar(title: const Text('Annonces')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        AppCard(
          child: Column(children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: 'Titre')),
            const SizedBox(height: 12),
            TextField(controller: _body, maxLines: 3, decoration: const InputDecoration(labelText: 'Message')),
            const SizedBox(height: 12),
            DropdownButtonFormField<Role?>(
              initialValue: _target,
              decoration: const InputDecoration(labelText: 'Destinataires'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Tout le monde')),
                DropdownMenuItem(value: Role.student, child: Text('Étudiants')),
                DropdownMenuItem(value: Role.teacher, child: Text('Enseignants')),
              ],
              onChanged: (v) => setState(() => _target = v),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () {
                if (_title.text.trim().isEmpty || _body.text.trim().isEmpty) {
                  toast(context, 'Titre et message requis.');
                  return;
                }
                s.announce(_title.text.trim(), _body.text.trim(), _target);
                _title.clear();
                _body.clear();
                toast(context, 'Annonce diffusée.');
              },
              icon: const Icon(Icons.send),
              label: const Text('Diffuser'),
            ),
          ]),
        ),
        const SectionTitle('Historique'),
        for (final n in history)
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(n.title, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(n.body, style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 4),
              Text('${fmtDate(n.date)} • ${n.role?.label ?? 'Tous'}',
                  style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            ]),
          ),
      ]),
    );
  }
}

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
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final history = s.notifs.where((n) => n.type == 'annonce').toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Annonces'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          AppCardElevated(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nouvelle annonce',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                AppTextFormField(
                  controller: _title,
                  label: 'Titre',
                  icon: Icons.title,
                  hintText: 'Titre de l\'annonce',
                ),
                AppTextFormField(
                  controller: _body,
                  label: 'Message',
                  icon: Icons.message_rounded,
                  maxLines: 3,
                  hintText: 'Contenu du message...',
                ),
                const SizedBox(height: 8),
                AppDropdownFormField<Role?>(
                  value: _target,
                  label: 'Destinataires',
                  icon: Icons.group_rounded,
                  items: const [
                    DropdownMenuEntry(value: null, label: 'Tout le monde', leadingIcon: Icon(Icons.public_rounded)),
                    DropdownMenuEntry(value: Role.student, label: 'Étudiants', leadingIcon: Icon(Icons.person_rounded)),
                    DropdownMenuEntry(value: Role.teacher, label: 'Enseignants', leadingIcon: Icon(Icons.school_rounded)),
                  ],
                  onChanged: (v) => setState(() => _target = v),
                ),
                const SizedBox(height: 20),
                AppFormButton(
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
                  text: 'Diffuser',
                  icon: Icons.send_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle('Historique'),
          if (history.isEmpty)
            const EmptyState(Icons.history_rounded, 'Aucune annonce diffusée.')
          else
            for (final n in history)
              AppCardElevated(
                margin: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(n.body, style: TextStyle(color: Neumo.of(context).textMuted)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: Neumo.of(context).textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${fmtDate(n.date)} • ${n.role?.label ?? 'Tous'}',
                          style:  TextStyle(fontSize: 11, color: Neumo.of(context).textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
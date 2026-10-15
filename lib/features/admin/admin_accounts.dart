import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';

class AdminAccounts extends StatefulWidget {
  const AdminAccounts({super.key});
  @override
  State<AdminAccounts> createState() => _AdminAccountsState();
}

class _AdminAccountsState extends State<AdminAccounts> {
  Role? _filter;
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }
Future<void> _create() async {
  final s = context.read<AppState>();
  final r = await askForm(context, 'Créer un compte', [
    const Fld('name', 'Nom complet'),
    const Fld('email', 'Email'),
    const Fld('pwd', 'Mot de passe initial', obscure: true),
    const Fld('role', 'Rôle', options: {
      'student': 'Étudiant',
      'teacher': 'Enseignant',
      'admin': 'Administrateur'
    }),
    Fld('class', 'Classe (étudiants)',
        options: {for (final c in s.classes) c.id: c.name}),
  ], ok: 'Créer');
  if (r == null) return;
  if (r['name']!.trim().isEmpty ||
      !r['email']!.contains('@') ||
      r['pwd']!.length < 6) {
    if (mounted) {
      toast(context,
          'Nom, email valide et mot de passe (6 caractères min.) requis.');
    }
    return;
  }
  final err = await s.createAccount(
    r['name']!,
    r['email']!,
    r['pwd']!,
    Role.values.byName(r['role']!),
    r['class'],
  );
  if (!mounted) return;
  toast(context, err ?? 'Compte créé.');
}
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final query = _search.text.trim().toLowerCase();
    final list = s.users.where((u) {
      final matchesRole = _filter == null || u.role == _filter;
      final matchesSearch = query.isEmpty ||
          u.name.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query) ||
          s.className(u.classId).toLowerCase().contains(query);
      return matchesRole && matchesSearch;
    }).toList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: _create, icon: const Icon(Icons.person_add), label: const Text('Nouveau compte')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Rechercher un nom, un email ou une classe',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Effacer la recherche',
                      onPressed: () {
                        _search.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
        ),
        SizedBox(
          height: 54,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(label: const Text('Tous'), selected: _filter == null, onSelected: (_) => setState(() => _filter = null))),
            for (final r in Role.values)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(label: Text(r.label), selected: _filter == r, onSelected: (_) => setState(() => _filter = r)),
              ),
          ]),
        ),
        Expanded(
          child: list.isEmpty
              ? const EmptyState(Icons.person_search_rounded, 'Aucun compte ne correspond à la recherche.')
              : ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 90), children: [
                  for (final u in list)
                    AppCard(
                      child: Row(children: [
                        CircleAvatar(
                          backgroundColor:
                              (u.active ? AppColors.primary : AppColors.muted)
                                  .withValues(alpha: .12),
                          child: Text(
                            u.initials,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u.name,
                                  style: const TextStyle(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 2),
                              Text(u.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: AppColors.muted, fontSize: 12)),
                              Text(
                                '${u.role.label}${u.classId != null ? ' • ${s.className(u.classId)}' : ''}',
                                style: const TextStyle(
                                    color: AppColors.muted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        if (u.id != s.user!.id)
                          Switch(
                            value: u.active,
                            onChanged: (_) => s.toggleActive(u),
                          )
                        else
                          const Icon(Icons.verified_user_rounded,
                              color: AppColors.accent),
                      ]),
                    ),
                ]),
        ),
      ]),
    );
  }
}

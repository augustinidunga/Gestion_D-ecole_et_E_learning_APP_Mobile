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
    final r = await askForm(context, 'CrÃ©er un compte', [
      const Fld('name', 'Nom complet'),
      const Fld('email', 'Email'),
      const Fld('pwd', 'Mot de passe initial', obscure: true),
      const Fld('role', 'RÃ´le', options: {
        'student': 'Ã‰tudiant',
        'teacher': 'Enseignant',
        'admin': 'Administrateur',
      }),
      Fld('class', 'Classe (Ã©tudiants)', options: {for (final c in s.classes) c.id: c.name}),
    ], ok: 'CrÃ©er');
    if (r == null) return;
    if (r['name']!.isEmpty || !r['email']!.contains('@') || r['pwd']!.length < 6) {
      if (mounted) toast(context, 'Nom, email valide et mot de passe (6 caractÃ¨res min.) requis.');
      return;
    }
    if (s.users.any((u) => u.email == r['email']!.toLowerCase())) {
      if (mounted) toast(context, 'Cet email existe dÃ©jÃ .');
      return;
    }
    s.createAccount(
        r['name']!, r['email']!, r['pwd']!, Role.values.byName(r['role']!), r['class']);
    if (mounted) toast(context, 'Compte crÃ©Ã©.');
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final query = _search.text.trim().toLowerCase();
    final list = s.users.where((u) {
      final matchesRole = _filter == null || u.role == _filter;
      final matchesSearch = query.isEmpty ||
          u.name.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query);
      return matchesRole && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _create,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Nouveau compte'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Neumo.of(context).surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Rechercher un nom, un email ou une classe',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  prefixIconColor: AppColors.primary,
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Effacer la recherche',
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _search.clear();
                            setState(() {});
                          },
                        ),
                  filled: true,
                  fillColor: Neumo.of(context).surface,
                  hintStyle: TextStyle(color: Neumo.of(context).textMuted.withOpacity(0.7)),
                ),
              ),
            ),
          ),
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: const Text('Tous'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                    selectedColor: AppColors.primary.withOpacity(0.15),
                    labelStyle: TextStyle(
                      color: _filter == null ? AppColors.primary : Neumo.of(context).textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                for (final r in Role.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(r.label),
                      selected: _filter == r,
                      onSelected: (_) => setState(() => _filter = r),
                      selectedColor: AppColors.primary.withOpacity(0.15),
                      labelStyle: TextStyle(
                        color: _filter == r ? AppColors.primary : Neumo.of(context).textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const EmptyState(
                    Icons.person_search_rounded,
                    'Aucun compte ne correspond Ã  la recherche.',
                    'Essayez une recherche diffÃ©rente.')
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    children: [
                      for (final u in list)
                        AppCardElevated(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    (u.active ? AppColors.primary : Neumo.of(context).textMuted)
                                        .withOpacity(0.12),
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
                                    Text(
                                      u.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      u.email,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:  TextStyle(
                                          color: Neumo.of(context).textMuted, fontSize: 13),
                                    ),
                                    Text(
                                      '${u.role.label}${u.classId != null ? ' â€¢ ${s.className(u.classId)}' : ''}',
                                      style:  TextStyle(
                                          color: Neumo.of(context).textMuted, fontSize: 12),
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
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
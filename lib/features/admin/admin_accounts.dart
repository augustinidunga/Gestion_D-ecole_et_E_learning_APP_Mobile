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
    final name = TextEditingController();
    final email = TextEditingController();
    final pwd = TextEditingController();
    final cls = TextEditingController();
    var role = Role.student;
    String? title;
    String? year = s.currentYear ?? (s.years.isNotEmpty ? s.years.first : null);
    const titles = ['Dr', 'Pr', 'MSc', 'PhD', 'Ing.', 'M.', 'Mme'];

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Créer un compte'),
          content: SizedBox(
            width: 380,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Nom complet')),
                const SizedBox(height: 12),
                TextField(
                    controller: email,
                    decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                TextField(
                    controller: pwd,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'Mot de passe initial')),
                const SizedBox(height: 12),
                DropdownButtonFormField<Role>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Rôle'),
                  items: [
                    for (final r in Role.values)
                      DropdownMenuItem(value: r, child: Text(r.label))
                  ],
                  onChanged: (v) => setD(() => role = v ?? role),
                ),
                const SizedBox(height: 12),
                if (role == Role.student) ...[
                  TextField(
                      controller: cls,
                      decoration: const InputDecoration(
                          labelText: 'Classe (ex. L2 Génie Logiciel)')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: s.years.contains(year) ? year : null,
                    decoration:
                        const InputDecoration(labelText: 'Année scolaire'),
                    items: [
                      for (final y in s.years)
                        DropdownMenuItem(value: y, child: Text(y))
                    ],
                    onChanged: (v) => setD(() => year = v),
                  ),
                ] else
                  DropdownButtonFormField<String>(
                    value: title,
                    decoration:
                        const InputDecoration(labelText: 'Titre (Dr, MSc, ...)'),
                    items: [
                      for (final t in titles)
                        DropdownMenuItem(value: t, child: Text(t))
                    ],
                    onChanged: (v) => setD(() => title = v),
                  ),
              ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Créer')),
          ],
        ),
      ),
    );

    final vName = name.text, vEmail = email.text, vPwd = pwd.text, vCls = cls.text;
    name.dispose();
    email.dispose();
    pwd.dispose();
    cls.dispose();
    if (ok != true) return;

    if (vName.trim().isEmpty || !vEmail.contains('@') || vPwd.length < 6) {
      if (mounted) {
        toast(context,
            'Nom, email valide et mot de passe (6 caractères min.) requis.');
      }
      return;
    }
    if (role == Role.student && (vCls.trim().isEmpty || year == null)) {
      if (mounted) toast(context, 'Classe et année scolaire requises.');
      return;
    }
    final err = await s.createAccount(vName, vEmail, vPwd, role,
        title: title ?? '', className: vCls.trim(), academicYear: year ?? '');
    if (!mounted) return;
    toast(context, err ?? 'Compte créé.');
  }

  Future<void> _showDetail(AppUser u) async {
    final s = context.read<AppState>();
    final meta = s.userMeta[u.id] ?? {};
    final courses = s.enrollments
        .where((e) => '${e['student']}' == u.id && e['status'] != 'dropped')
        .map((e) => '${e['course_title']}')
        .toList();
    Widget line(String k, String v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
                width: 90,
                child:
                    Text(k, style: const TextStyle(color: AppColors.muted))),
            Expanded(
                child: Text(v,
                    style: const TextStyle(fontWeight: FontWeight.w700))),
          ]),
        );
    String val(String k) => (meta[k] ?? '').isEmpty ? '-' : meta[k]!;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(u.name),
        content: SizedBox(
          width: 380,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            line('Identifiant', u.id),
            line('Email', u.email),
            line('Rôle', u.role.label),
            line('Statut', u.active ? 'Actif' : 'Désactivé'),
            if (u.role == Role.student) ...[
              line('Classe', val('class_name')),
              line('Année', val('academic_year')),
              line('Cours',
                  courses.isEmpty ? 'Aucune inscription' : courses.join(', ')),
            ] else
              line('Titre', val('title')),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Fermer')),
        ],
      ),
    );
  }

  Future<void> _edit(AppUser u) async {
    final s = context.read<AppState>();
    final name = TextEditingController(text: u.name);
    final email = TextEditingController(text: u.email);
    final pwd = TextEditingController();
    var role = u.role;
    final isMe = u.id == s.user!.id;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Modifier le compte'),
          content: SizedBox(
            width: 380,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Nom complet')),
                const SizedBox(height: 12),
                TextField(
                    controller: email,
                    decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                DropdownButtonFormField<Role>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Rôle'),
                  items: [
                    for (final r in Role.values)
                      DropdownMenuItem(value: r, child: Text(r.label))
                  ],
                  onChanged: isMe ? null : (v) => setD(() => role = v ?? role),
                ),
                const SizedBox(height: 12),
                TextField(
                    controller: pwd,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Nouveau mot de passe (facultatif)')),
              ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Enregistrer')),
          ],
        ),
      ),
    );

    final newName = name.text, newEmail = email.text, newPwd = pwd.text;
    name.dispose();
    email.dispose();
    pwd.dispose();
    if (ok != true) return;
    if (newName.trim().isEmpty ||
        !newEmail.contains('@') ||
        (newPwd.isNotEmpty && newPwd.length < 6)) {
      if (mounted) {
        toast(context,
            'Nom, email valide et mot de passe (6 caractères min.) requis.');
      }
      return;
    }
    final err = await s.updateUser(u,
        name: newName, email: newEmail, role: role, password: newPwd);
    if (!mounted) return;
    toast(context, err ?? 'Compte modifié.');
  }

  Future<void> _delete(AppUser u) async {
    final s = context.read<AppState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce compte ?'),
        content: Text(
            '${u.name} (${u.email}) sera supprimé définitivement. Cette action est irréversible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok != true) return;
    final err = await s.deleteUser(u);
    if (!mounted) return;
    toast(context, err ?? 'Compte supprimé.');
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
          onPressed: _create,
          icon: const Icon(Icons.person_add),
          label: const Text('Nouveau compte')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Rechercher un nom ou un email',
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
          child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                        label: const Text('Tous'),
                        selected: _filter == null,
                        onSelected: (_) => setState(() => _filter = null))),
                for (final r in Role.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                        label: Text(r.label),
                        selected: _filter == r,
                        onSelected: (_) => setState(() => _filter = r)),
                  ),
              ]),
        ),
        Expanded(
          child: list.isEmpty
              ? const EmptyState(Icons.person_search_rounded,
                  'Aucun compte ne correspond à la recherche.')
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                  children: [
                    AppCard(
                      child: LayoutBuilder(
                        builder: (context, c) => SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: c.maxWidth),
                            child: DataTable(
                              headingTextStyle:
                                  const TextStyle(fontWeight: FontWeight.w800),
                              columns: const [
                                DataColumn(label: Text('Nom')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Rôle')),
                                DataColumn(label: Text('Actif')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: [
                                for (final u in list)
                                  DataRow(cells: [
                                    DataCell(Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor: (u.active
                                                    ? AppColors.primary
                                                    : AppColors.muted)
                                                .withValues(alpha: .12),
                                            child: Text(
                                              u.initials,
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(u.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700)),
                                        ])),
                                    DataCell(Text(u.email)),
                                    DataCell(Text(u.role.label)),
                                    DataCell(u.id == s.user!.id
                                        ? const Icon(Icons.verified_user_rounded,
                                            color: AppColors.accent)
                                        : Switch(
                                            value: u.active,
                                            onChanged: (_) async {
                                              final err =
                                                  await s.toggleActive(u);
                                              if (err != null &&
                                                  context.mounted) {
                                                toast(context, err);
                                              }
                                            },
                                          )),
                                    DataCell(Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            tooltip: 'Voir le détail',
                                            icon: const Icon(
                                                Icons.visibility_outlined),
                                            onPressed: () => _showDetail(u),
                                          ),
                                          IconButton(
                                            tooltip: 'Modifier',
                                            icon: const Icon(
                                                Icons.edit_outlined),
                                            onPressed: () => _edit(u),
                                          ),
                                          IconButton(
                                            tooltip: u.id == s.user!.id
                                                ? 'Impossible de supprimer votre compte'
                                                : 'Supprimer',
                                            icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red),
                                            onPressed: u.id == s.user!.id
                                                ? null
                                                : () => _delete(u),
                                          ),
                                        ])),
                                  ]),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
        ),
      ]),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import 'admin_academic.dart';
import 'admin_accounts.dart';
import 'admin_announcements.dart';
import 'admin_finance.dart';

class WebColors {
  static const bg = Color(0xFFF3F9FE);
  static const ink = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const line = Color(0xFFDCEAF5);
  static const sky = Color(0xFF38BDF8);
  static const skyDark = Color(0xFF0EA5E9);
  static const skySoft = Color(0xFFE0F2FE);
}

class AdminWebLayout extends StatefulWidget {
  const AdminWebLayout({super.key});
  @override
  State<AdminWebLayout> createState() => _AdminWebLayoutState();
}

class _AdminWebLayoutState extends State<AdminWebLayout> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final base = Theme.of(context);
    final pages = <Widget>[
      _Home(onGo: (i) => setState(() => _i = i)),
      const AdminAccounts(),
      const AdminAcademic(),
      const AdminFinance(),
      const AdminAnnouncements(),
    ];
    return Theme(
      data: base.copyWith(
        scaffoldBackgroundColor: WebColors.bg,
        textTheme: GoogleFonts.interTextTheme(base.textTheme),
      ),
      child: Scaffold(
        backgroundColor: WebColors.bg,
        body: Row(children: [
          _sidebar(s),
          Expanded(
            child: Column(children: [
              _topBar(s),
              Expanded(child: IndexedStack(index: _i, children: pages)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _sidebar(AppState s) => Container(
        width: 260,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(right: BorderSide(color: WebColors.line)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [WebColors.sky, WebColors.skyDark]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EduConnect',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: WebColors.ink)),
                    Text('Admin Panel',
                        style:
                            TextStyle(fontSize: 11, color: WebColors.muted)),
                  ]),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _section('PRINCIPAL'),
                _nav(0, 'Tableau de bord', Icons.grid_view_rounded),
                _section('GESTION'),
                _nav(1, 'Comptes', Icons.people_alt_outlined),
                _nav(2, 'Académique', Icons.account_balance_outlined),
                _nav(3, 'Finances', Icons.payments_outlined),
                _nav(4, 'Annonces', Icons.campaign_outlined),
              ],
            ),
          ),
          const Divider(height: 1, color: WebColors.line),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: WebColors.skySoft,
                child: Text(s.user!.initials,
                    style: const TextStyle(
                        color: WebColors.skyDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 11)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(s.user!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              IconButton(
                tooltip: 'Déconnexion',
                onPressed: s.logout,
                icon: const Icon(Icons.logout, size: 18),
              ),
            ]),
          ),
        ]),
      );

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 18, 8, 8),
        child: Text(t,
            style: const TextStyle(
                fontSize: 10.5,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: WebColors.muted)),
      );

  Widget _nav(int i, String label, IconData icon) {
    final sel = _i == i;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: sel ? WebColors.ink : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _i = i),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Icon(icon,
                  size: 18, color: sel ? WebColors.sky : WebColors.muted),
              const SizedBox(width: 12),
              Text(label,
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      color: sel ? Colors.white : WebColors.ink)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _topBar(AppState s) => Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: WebColors.line)),
        ),
        child: Row(children: [
          Container(
            width: 300,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: WebColors.line),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(children: [
              Icon(Icons.search, size: 18, color: WebColors.muted),
              SizedBox(width: 8),
              Text('Rechercher…',
                  style: TextStyle(color: WebColors.muted, fontSize: 13)),
            ]),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => setState(() => _i = 1),
            style: FilledButton.styleFrom(
              backgroundColor: WebColors.ink,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add_circle, size: 18, color: WebColors.sky),
            label: const Text('Nouveau compte'),
          ),
        ]),
      );
}

// ───────────────────────── Accueil ─────────────────────────
class _Home extends StatelessWidget {
  final void Function(int) onGo;
  const _Home({required this.onGo});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final admins = s.users.where((u) => u.role == Role.admin).length;
    final recent = s.users.reversed.take(6).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Hero + résumé
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Vue d'ensemble de l'établissement",
                      style: TextStyle(
                          fontSize: 12,
                          color: WebColors.muted,
                          decoration: TextDecoration.underline)),
                  const SizedBox(height: 18),
                  const Text('Comptes actifs sur la plateforme',
                      style: TextStyle(fontSize: 15)),
                  Text('${s.users.length}',
                      style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                          height: 1.1)),
                  const Text('Étudiants, enseignants et administrateurs',
                      style: TextStyle(color: WebColors.muted)),
                ]),
          ),
          Container(
            width: 380,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: WebColors.line),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(children: [
              _sumRow('Étudiants', '${s.students.length}', false),
              _sumRow('Enseignants', '${s.teachers.length}', true),
              _sumRow('Administrateurs', '$admins', false),
            ]),
          ),
        ]),
        const SizedBox(height: 28),
        const Divider(color: WebColors.line),
        const SizedBox(height: 20),

        // KPIs
        Row(children: [
          _Kpi('COURS PUBLIÉS', '${s.courses.length}', 'depuis l\'API',
              Icons.menu_book_rounded, true),
          const SizedBox(width: 16),
          _Kpi('QUIZ CRÉÉS', '${s.quizzes.length}', 'démo',
              Icons.quiz_rounded, false),
          const SizedBox(width: 16),
          _Kpi('SOUMISSIONS', '${s.attempts.length}', 'démo',
              Icons.inbox_rounded, false),
          const SizedBox(width: 16),
          _Kpi('NOTES SAISIES', '${s.grades.length}', 'démo',
              Icons.grade_rounded, false),
        ]),
        const SizedBox(height: 28),

        // Tableau
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: WebColors.line),
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                const Text('Derniers comptes',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton(
                    onPressed: () => onGo(1), child: const Text('Voir tout')),
              ]),
            ),
            Container(
              color: WebColors.skySoft,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: const Row(children: [
                Expanded(flex: 3, child: _Th('NOM')),
                Expanded(flex: 3, child: _Th('EMAIL')),
                Expanded(flex: 2, child: _Th('RÔLE')),
                Expanded(flex: 2, child: _Th('STATUT')),
              ]),
            ),
            if (recent.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Aucun compte',
                    style: TextStyle(color: WebColors.muted)),
              ),
            for (final u in recent)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: WebColors.line)),
                ),
                child: Row(children: [
                  Expanded(
                      flex: 3,
                      child: Text(u.name,
                          style: const TextStyle(fontWeight: FontWeight.w600))),
                  Expanded(
                      flex: 3,
                      child: Text(u.email,
                          style: const TextStyle(color: WebColors.muted))),
                  Expanded(flex: 2, child: Text(u.role.name)),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: u.active
                              ? WebColors.skySoft
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(u.active ? 'Actif' : 'Inactif',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: u.active
                                    ? WebColors.skyDark
                                    : WebColors.muted)),
                      ),
                    ),
                  ),
                ]),
              ),
          ]),
        ),
      ]),
    );
  }

  Widget _sumRow(String l, String v, bool hl) => Container(
        color: hl ? WebColors.sky : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: hl ? Colors.white : WebColors.skyDark,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(l,
                  style: TextStyle(
                      fontSize: 13,
                      color: hl ? Colors.white : WebColors.ink))),
          Text(v,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: hl ? Colors.white : WebColors.ink)),
        ]),
      );
}

class _Th extends StatelessWidget {
  final String t;
  const _Th(this.t);
  @override
  Widget build(BuildContext context) => Text(t,
      style: const TextStyle(
          fontSize: 10.5,
          letterSpacing: 1,
          fontWeight: FontWeight.w700,
          color: WebColors.muted));
}

class _Kpi extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final bool highlight;
  const _Kpi(this.label, this.value, this.sub, this.icon, this.highlight);

  @override
  Widget build(BuildContext context) {
    final fg = highlight ? Colors.white : WebColors.ink;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: highlight
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [WebColors.sky, WebColors.skyDark])
              : null,
          color: highlight ? null : Colors.white,
          border: Border.all(color: highlight ? Colors.transparent : WebColors.line),
          borderRadius: BorderRadius.circular(16),
          boxShadow: highlight
              ? [
                  BoxShadow(
                      color: WebColors.sky.withValues(alpha: .35),
                      blurRadius: 24,
                      offset: const Offset(0, 10))
                ]
              : null,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 18, color: highlight ? Colors.white : WebColors.skyDark),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 10.5,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                    color: highlight ? Colors.white : WebColors.muted)),
          ]),
          const SizedBox(height: 14),
          Text(value,
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.w800, color: fg)),
          const SizedBox(height: 4),
          Text(sub,
              style: TextStyle(
                  fontSize: 12,
                  color: highlight ? Colors.white70 : WebColors.muted)),
        ]),
      ),
    );
  }
}
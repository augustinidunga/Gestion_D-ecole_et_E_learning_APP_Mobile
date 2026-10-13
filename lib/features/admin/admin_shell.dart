import 'package:flutter/material.dart';

import '../shared/more_tab.dart';
import '../shared/role_shell.dart';
import 'admin_academic.dart';
import 'admin_accounts.dart';
import 'admin_announcements.dart';
import 'admin_dashboard.dart';
import 'admin_finance.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleShell(tabs: [
      const NavTab('Tableau de bord', Icons.dashboard_outlined, Icons.dashboard_rounded, AdminDashboard()),
      const NavTab('Comptes', Icons.manage_accounts_outlined, Icons.manage_accounts, AdminAccounts()),
      const NavTab('Académique', Icons.account_balance_outlined, Icons.account_balance, AdminAcademic()),
      const NavTab('Finances', Icons.payments_outlined, Icons.payments_rounded, AdminFinance()),
      NavTab('Plus', Icons.menu, Icons.menu, MoreTab(entries: [
        MoreEntry(Icons.campaign, 'Annonces', 'Diffuser un message ciblé par rôle',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAnnouncements()))),
      ])),
    ]);
  }
}

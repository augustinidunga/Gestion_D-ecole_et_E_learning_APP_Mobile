import re
p = r"C:\Project_gestion_ecole_Groupe04\lib\data\app_state.dart"
s = open(p, encoding="utf-8").read()
marker = "  // \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500 Notification-Service"
start = s.index("  /// G")
# find the doc comment before downloadReceipt
doc = "  /// G\u00cbn\u00dare et enregistre un fichier re\u00e7u t\u00e9l\u00e9chargeable sur l'appareil."
# fallback: search for downloadReceipt method
idx = s.index("  Future<String?> downloadReceipt(Invoice inv) async {")
# walk back to include preceding doc line
line_start = s.rfind("\n", 0, idx) + 1
# include the doc comment line before
while line_start > 0 and s[line_start-1:line_start] != "\n":
    pass
# find start of doc comment
doc_idx = s.rfind("  /// ", 0, idx)
start = doc_idx
end = s.index(marker, start)
new = '''  String receiptText(Invoice inv) {
    if (!inv.paid || inv.receipt == null || inv.paidOn == null) return '';
    final user = userById(inv.studentId);
    final className = classes.where((c) => c.id == user?.classId).firstOrNull?.name ?? '-';
    return \'\'\'RE\u00c7U DE PAIEMENT
====================
\u00c9tablissement : ${AppConfig.appName}
N\u00b0 re\u00e7u : ${inv.receipt}
\u00c9l\u00e8ve : ${user?.name ?? inv.studentId}
Fili\u00e8re : $className
Libell\u00e9 : ${inv.label}
Montant : ${fmtMoney(inv.amount)}
Mode de paiement : ${inv.method ?? '-'}
Date de paiement : ${fmtDate(inv.paidOn!)}
Heure de paiement : ${inv.paidOn!.hour.toString().padLeft(2, '0')}:${inv.paidOn!.minute.toString().padLeft(2, '0')}:${inv.paidOn!.second.toString().padLeft(2, '0')}
Statut : Pay\u00e9
====================
Merci pour votre confiance.
\'\'\';
  }

  /// G\u00e9n\u00e8re et enregistre un fichier re\u00e7u t\u00e9l\u00e9chargeable sur l'appareil.
  Future<String?> downloadReceipt(Invoice inv) async {
    final content = receiptText(inv);
    if (content.isEmpty) return null;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/recu_${inv.receipt}.txt');
      await file.writeAsString(content);
      return file.path;
    } catch (_) {
      return null;
    }
  }

'''
s = s[:start] + new + s[end:]
open(p, "w", encoding="utf-8").write(s)
print("done")
PY
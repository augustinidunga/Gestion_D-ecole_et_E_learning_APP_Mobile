import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecole_elearning/core/theme.dart';
import 'package:ecole_elearning/main_student.dart';

void main() {
  testWidgets('Application étudiant : connexion, navigation et paramètres',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StudentApp());
    await tester.pump();

    // Écran de connexion dédié aux étudiants.
    expect(find.text('EduConnect Étudiant'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'etudiant@ecole.edu');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Mot de passe'), 'etud123');
    await tester.pump();

    await tester.tap(find.text('Se connecter'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    // Accueil étudiant affiché.
    expect(find.textContaining('Bonjour'), findsOneWidget);

    // Accès à l'onglet « Plus » puis aux paramètres.
    await tester.tap(find.text('Plus'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.scrollUntilVisible(
      find.text('Paramètres'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Paramètres'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Mode sombre'), findsOneWidget);
    expect(find.text('Contraste élevé'), findsOneWidget);

    // Le mode sombre change réellement le thème appliqué.
    final before = Theme.of(tester.element(find.text('Mode sombre')))
        .extension<NeumoPalette>()!
        .bg;
    await tester.tap(find.text('Mode sombre'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final after = Theme.of(tester.element(find.text('Mode sombre')))
        .extension<NeumoPalette>()!
        .bg;
    expect(after, isNot(before));
  });
}

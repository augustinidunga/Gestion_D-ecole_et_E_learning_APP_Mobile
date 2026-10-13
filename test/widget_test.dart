import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ecole_elearning/app.dart';
import 'package:ecole_elearning/data/app_state.dart';

void main() {
  testWidgets('Connexion étudiant puis affichage de l\'accueil', (WidgetTester tester) async {
    // Lance l'app en mode démonstration (données locales).
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>(
        create: (_) => AppState(),
        child: const EcoleApp(),
      ),
    );

    // L'écran de connexion est affiché.
    expect(find.text('Connexion'), findsOneWidget);

    // Remplit le compte de démonstration « Étudiant » puis se connecte.
    await tester.tap(find.text('Étudiant'));
    await tester.pump();
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    // L'accueil de l'étudiant est affiché.
    expect(find.textContaining('Bonjour, Aline'), findsOneWidget);
  });
}
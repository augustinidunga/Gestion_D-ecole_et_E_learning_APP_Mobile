import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ecole_elearning/app.dart';
import 'package:ecole_elearning/core/theme.dart';
import 'package:ecole_elearning/data/app_state.dart';

void main() {
  testWidgets('Les paramètres d\'affichage pilotent réellement le thème',
      (WidgetTester tester) async {
    final state = AppState();
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>(
        create: (_) => state,
        child: const EcoleApp(),
      ),
    );
    await tester.pumpAndSettle();

    final lightBg = Theme.of(tester.element(find.byType(Scaffold).first))
        .extension<NeumoPalette>()!
        .bg;

    state.toggleDarkMode();
    await tester.pumpAndSettle();

    final darkBg = Theme.of(tester.element(find.byType(Scaffold).first))
        .extension<NeumoPalette>()!
        .bg;
    expect(darkBg, isNot(lightBg));

    state.setTextScale(1.3);
    await tester.pumpAndSettle();
    final scale = MediaQuery.of(tester.element(find.byType(Scaffold).first))
        .textScaler
        .scale(10);
    expect(scale, closeTo(13, 0.1));

    state.toggleHighContrast();
    await tester.pumpAndSettle();
    final palette = Theme.of(tester.element(find.byType(Scaffold).first))
        .extension<NeumoPalette>()!;
    expect(palette.text, NeumoPalette.highContrastDark.text);
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:ecole_elearning/data/app_state.dart';

void main() {
  group('Administration académique', () {
    late AppState state;

    setUp(() {
      state = AppState();
      state.login('admin@ecole.edu', 'admin123');
    });

    test('crée une classe et refuse les doublons sans tenir compte de la casse',
        () {
      expect(state.createClass('L1 Informatique'), isTrue);
      expect(state.createClass('  l1 informatique '), isFalse);
      expect(state.classes.map((schoolClass) => schoolClass.name),
          contains('L1 Informatique'));
    });

    test('createAcademicCourse valide titre/code non vides et teacherId entier', () async {
      // Titre vide -> erreur
      expect(await state.createAcademicCourse('', 'Réseaux', 'c1', '1', 'desc'),
          'Titre et code obligatoires.');

      // TeacherId non entier -> erreur
      expect(await state.createAcademicCourse('Cours', 'Matière', 'c1', 't1', ''),
          'Choisissez un enseignant.');

      // Admin requis -> testé dans test suivant
    });

    test('réserve la création des classes et cours à l\'admin', () async {
      state.login('prof@ecole.edu', 'prof123');

      expect(state.createClass('L1 Informatique'), isFalse);
      final result = await state.createAcademicCourse(
        'Sécurité réseau',
        'Réseaux',
        'c1',
        '1',
        '',
      );
      // Prof non admin -> erreur de permission
      expect(result, 'Action réservée à l\'administrateur.');
    });
  });
}
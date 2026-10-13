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

    test('crée un cours lié à une classe et à un enseignant actif', () {
      final previousCourseCount = state.courses.length;

      expect(
        state.createAcademicCourse(
          'Sécurité réseau',
          'Réseaux',
          'c1',
          't1',
          'Notions fondamentales de sécurité.',
        ),
        isTrue,
      );
      expect(state.courses, hasLength(previousCourseCount + 1));
      expect(state.courses.last.teacherId, 't1');
      expect(state.courses.last.classId, 'c1');
    });

    test('refuse un cours avec une classe ou un enseignant inconnus', () {
      expect(
        state.createAcademicCourse('Cours', 'Matière', 'missing', 't1', ''),
        isFalse,
      );
      expect(
        state.createAcademicCourse('Cours', 'Matière', 'c1', 'missing', ''),
        isFalse,
      );
    });

    test('réserve la création des classes et cours à l’administration', () {
      state.login('prof@ecole.edu', 'prof123');

      expect(state.createClass('L1 Informatique'), isFalse);
      expect(
        state.createAcademicCourse(
          'Sécurité réseau',
          'Réseaux',
          'c1',
          't1',
          '',
        ),
        isFalse,
      );
    });
  });
}

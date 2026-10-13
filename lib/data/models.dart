enum Role { student, teacher, admin }

extension RoleX on Role {
  String get label => switch (this) {
        Role.student => 'Étudiant',
        Role.teacher => 'Enseignant',
        Role.admin => 'Administrateur',
      };
}

class SchoolClass {
  final String id, name;
  const SchoolClass(this.id, this.name);
}

class AppUser {
  final String id;
  String name, email, password;
  final Role role;
  String? classId;
  bool active;
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.classId,
    this.active = true,
  });

  String get initials {
    final p = name.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (p.isEmpty) return '?';
    return (p.first[0] + (p.length > 1 ? p.last[0] : '')).toUpperCase();
  }
}

class Lesson {
  final String id, title;
  final bool isVideo;
  final String info; // durée ou taille
  const Lesson(this.id, this.title, this.isVideo, this.info);
}

class Course {
  final String id, title, subject, teacherId, classId;
  final String description;
  final List<Lesson> lessons;
  Course({
    required this.id,
    required this.title,
    required this.subject,
    required this.teacherId,
    required this.classId,
    this.description = '',
    List<Lesson>? lessons,
  }) : lessons = lessons != null ? List<Lesson>.of(lessons) : <Lesson>[];
}

class Question {
  final String text;
  final List<String> options;
  final int correct;
  const Question(this.text, this.options, this.correct);
}

class Quiz {
  final String id, courseId, title;
  final DateTime due;
  final List<Question> questions;
  const Quiz(this.id, this.courseId, this.title, this.due, this.questions);
}

class Attempt {
  final String id, quizId, studentId;
  final List<int> answers;
  final double score; // sur 20
  final DateTime date;
  final int warnings; // alertes proctoring
  bool synced;
  Attempt(this.id, this.quizId, this.studentId, this.answers, this.score,
      this.date, this.warnings,
      {this.synced = true});
}

/// Note saisie manuellement par l'enseignant (devoir, examen...).
class ManualGrade {
  final String id, studentId, courseId, label, teacherId;
  final double value;
  final DateTime date;
  const ManualGrade(this.id, this.studentId, this.courseId, this.label,
      this.value, this.date, this.teacherId);
}

/// Ligne unifiée pour le relevé de notes.
class GradeEntry {
  final String label, courseTitle;
  final double value;
  final DateTime date;
  final bool isQuiz;
  const GradeEntry(this.label, this.courseTitle, this.value, this.date, this.isQuiz);
}

class Invoice {
  final String id, studentId, label;
  final int amount;
  final DateTime due;
  bool paid;
  DateTime? paidOn;
  String? receipt, method;
  Invoice(this.id, this.studentId, this.label, this.amount, this.due,
      {this.paid = false, this.paidOn, this.receipt, this.method});
}

class AppNotif {
  final String id, title, body, type; // cours, quiz, note, paiement, annonce
  final DateTime date;
  final Role? role;
  final String? userId, classId;
  const AppNotif(this.id, this.title, this.body, this.type, this.date,
      {this.role, this.userId, this.classId});
}

class Slot {
  final String classId, start, end, subject, room, teacher;
  final int weekday; // 1 = lundi
  const Slot(this.classId, this.weekday, this.start, this.end, this.subject,
      this.room, this.teacher);
}

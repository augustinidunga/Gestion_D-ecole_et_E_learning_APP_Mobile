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
  final bool isPhoto;
  final String info; // durée ou taille
  final String? url; // URL vidéo ou document
  final String? localPath; // chemin local si téléchargé
  final String? meetingLink; // lien visio (Zoom/Meet/Teams)
  final int size; // taille en octets
  final DateTime uploadedAt;
  Lesson(this.id, this.title, this.isVideo, this.info,
      {this.url, this.localPath, this.meetingLink, this.isPhoto = false, this.size = 0, DateTime? uploadedAt})
      : uploadedAt = uploadedAt ?? DateTime.now();
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
  final String? userId, classId, refId; // refId = id de l'entité liée (ex. quiz)
  const AppNotif(this.id, this.title, this.body, this.type, this.date,
      {this.role, this.userId, this.classId, this.refId});
}

class Slot {
  final String classId, start, end, subject, room, teacher;
  final int weekday; // 1 = lundi
  final String? meetingLink;
  const Slot(this.classId, this.weekday, this.start, this.end, this.subject,
      this.room, this.teacher, {this.meetingLink});
}

/// Message échangé entre utilisateurs (chat direct ou classe).
class ChatMessage {
  final String id, senderId;
  final String? receiverId, classId;
  final String text;
  final DateTime date;
  bool read;
  ChatMessage(this.id, this.senderId, this.text, this.date,
      {this.receiverId, this.classId, this.read = false});
}

/// Devoir / travail à rendre.
class Assignment {
  final String id, courseId, title, description, teacherId;
  final DateTime due;
  final bool isGroup;
  final List<String> groupMembers;
  final Map<String, String> groupRoles;
  final List<RubricCriterion> rubric;
  final String submissionType;
  final int maxSizeMb;
  final double latePenaltyPerDay;
  const Assignment(this.id, this.courseId, this.title, this.description,
      this.due, this.teacherId,
      {this.isGroup = false,
      this.groupMembers = const [],
      this.groupRoles = const {},
      this.rubric = const [],
      this.submissionType = 'text',
      this.maxSizeMb = 10,
      this.latePenaltyPerDay = 0});
}

/// Critère de rubrique de correction.
class RubricCriterion {
  final String label;
  final double weight; // pondération (somme = 1)
  final double? score; // note obtenue (sur 20)
  const RubricCriterion(this.label, this.weight, {this.score});
  RubricCriterion copyWith({double? score}) => RubricCriterion(label, weight, score: score ?? this.score);
}

class SubmissionVersion {
  final String content;
  final List<String> attachments;
  final DateTime date;
  const SubmissionVersion(this.content, this.attachments, this.date);
}
class Submission {
  final String id, assignmentId, studentId;
  String content;
  DateTime date;
  double? grade;
  String? feedback;
  List<String> attachments;
  List<SubmissionVersion> versions;
  List<RubricCriterion> rubricScores;
  List<String> contributors;
  Map<String, double> memberGrades;
  Map<String, String> memberFeedback;
  bool synced;
  Submission(this.id, this.assignmentId, this.studentId, this.content, this.date,
      {this.grade, this.feedback, this.attachments = const [], this.versions = const [], this.rubricScores = const [], this.contributors = const [], this.memberGrades = const {}, this.memberFeedback = const {}, this.synced = true});
}

/// Enregistrement de présence.
class AttendanceRecord {
  final String id, classId, studentId;
  final DateTime date;
  bool present;
  final String? note;
  AttendanceRecord(this.id, this.classId, this.studentId, this.date, this.present,
      {this.note});
}

/// Bourse / réduction sur les frais.
class Scholarship {
  final String id, studentId, label;
  final int discount; // pourcentage
  final DateTime grantedOn;
  const Scholarship(this.id, this.studentId, this.label, this.discount,
      this.grantedOn);
}

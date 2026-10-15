import 'package:flutter/foundation.dart';

import 'models.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/api_client.dart';

/// État global de l'application.
///
/// Il joue le rôle de la couche « services » décrite dans le cahier de cadrage.
/// Chaque section correspond à un module métier ; pour passer à un vrai
/// back-end (Spring Boot + Keycloak), il suffit de remplacer le corps des
/// méthodes par des appels REST via la gateway.
class AppState extends ChangeNotifier {
  AppUser? user;
  bool offline = false;
  int _seq = 100;
  String _id(String p) => '$p${_seq++}';
  DateTime get _now => DateTime.now();

  // ───────────────────────── Données (seed de démonstration) ─────────────────
  final classes = <SchoolClass>[
    const SchoolClass('c1', 'L2 Génie Logiciel'),
    const SchoolClass('c2', 'L3 Réseaux'),
  ];

  final users = <AppUser>[
    AppUser(
        id: 'a1',
        name: 'Admin Principal',
        email: 'admin@ecole.edu',
        password: 'admin123',
        role: Role.admin),
    AppUser(
        id: 't1',
        name: 'Dr Claire Ndayi',
        email: 'prof@ecole.edu',
        password: 'prof123',
        role: Role.teacher),
    AppUser(
        id: 's1',
        name: 'Aline Niyonzima',
        email: 'etudiant@ecole.edu',
        password: 'etud123',
        role: Role.student,
        classId: 'c1'),
    AppUser(
        id: 's2',
        name: 'Jean Habonimana',
        email: 'jean@ecole.edu',
        password: 'etud123',
        role: Role.student,
        classId: 'c1'),
    AppUser(
        id: 's3',
        name: 'Grace Uwimana',
        email: 'grace@ecole.edu',
        password: 'etud123',
        role: Role.student,
        classId: 'c2'),
  ];

  late final courses = <Course>[
    Course(
        id: 'k1',
        title: 'Algorithmique',
        subject: 'Informatique',
        teacherId: 't1',
        classId: 'c1',
        description:
            'Structures de contrôle, tableaux, complexité et récursivité.',
        lessons: const [
          Lesson('l1', 'Introduction aux algorithmes', true, '12 min'),
          Lesson('l2', 'Boucles et conditions', true, '18 min'),
          Lesson('l3', 'Support de cours - Chapitre 1', false, '1,2 Mo'),
        ]),
    Course(
        id: 'k2',
        title: 'Bases de données',
        subject: 'Informatique',
        teacherId: 't1',
        classId: 'c1',
        description: 'Modèle relationnel, SQL et normalisation.',
        lessons: const [
          Lesson('l4', 'Modèle relationnel', true, '20 min'),
          Lesson('l5', 'Requêtes SQL', false, '2,4 Mo'),
        ]),
    Course(
        id: 'k3',
        title: 'Administration réseaux',
        subject: 'Réseaux',
        teacherId: 't1',
        classId: 'c2',
        description: 'Adressage IP, routage et services réseau.',
        lessons: const [Lesson('l6', 'Adressage IPv4', true, '15 min')]),
  ];

  late final quizzes = <Quiz>[
    Quiz('q1', 'k1', 'Quiz 1 - Bases algorithmiques',
        _now.add(const Duration(days: 5)), const [
      Question(
          'Quelle structure répète un bloc tant qu\'une condition est vraie ?',
          ['if', 'while', 'switch'],
          1),
      Question('Quelle est la complexité d\'une recherche linéaire ?',
          ['O(1)', 'O(n)', 'O(n²)'], 1),
      Question('Une fonction qui s\'appelle elle-même est dite…',
          ['itérative', 'statique', 'récursive'], 2),
    ]),
  ];

  late final attempts = <Attempt>[
    Attempt('at1', 'q1', 's2', [1, 0, 2], 13.33,
        _now.subtract(const Duration(days: 1)), 0),
  ];

  late final grades = <ManualGrade>[
    ManualGrade('g1', 's1', 'k1', 'Devoir 1', 14,
        _now.subtract(const Duration(days: 6)), 't1'),
  ];

  late final invoices = <Invoice>[
    Invoice('f1', 's1', 'Frais scolaires - Tranche 1', 150,
        _now.subtract(const Duration(days: 40)),
        paid: true,
        paidOn: _now.subtract(const Duration(days: 38)),
        receipt: 'REC-0001',
        method: 'Mobile Money'),
    Invoice('f2', 's1', 'Frais scolaires - Tranche 2', 150,
        _now.add(const Duration(days: 10))),
    Invoice('f3', 's1', 'Frais scolaires - Tranche 3', 150,
        _now.add(const Duration(days: 60))),
    Invoice('f4', 's2', 'Frais scolaires - Tranche 1', 150,
        _now.add(const Duration(days: 3))),
    Invoice('f5', 's3', 'Frais scolaires - Tranche 1', 150,
        _now.add(const Duration(days: 8))),
  ];

  late final schedule = <Slot>[
    const Slot('c1', 1, '08:00', '10:00', 'Algorithmique', 'Salle A1',
        'Dr Claire Ndayi'),
    const Slot('c1', 2, '10:00', '12:00', 'Bases de données', 'Labo 2',
        'Dr Claire Ndayi'),
    const Slot('c1', 3, '08:00', '10:00', 'Algorithmique', 'Salle A1',
        'Dr Claire Ndayi'),
    const Slot('c1', 4, '14:00', '16:00', 'Bases de données', 'Labo 2',
        'Dr Claire Ndayi'),
    const Slot('c2', 1, '10:00', '12:00', 'Administration réseaux', 'Salle B3',
        'Dr Claire Ndayi'),
    const Slot('c2', 5, '08:00', '10:00', 'Administration réseaux', 'Salle B3',
        'Dr Claire Ndayi'),
  ];

  late final notifs = <AppNotif>[
    AppNotif(
        'n1',
        'Bienvenue sur EduConnect',
        'Retrouvez vos cours, quiz et paiements au même endroit.',
        'annonce',
        _now.subtract(const Duration(days: 2))),
    AppNotif('n2', 'Nouveau quiz disponible', 'Quiz 1 - Bases algorithmiques',
        'quiz', _now.subtract(const Duration(hours: 5)),
        role: Role.student, classId: 'c1'),
  ];

  final Set<String> downloaded = {};
  final Set<String> doneLessons = {};
  final Set<String> _read = {};

  // ───────────────────────── Auth-Service ────────────────────────────────────
    Future<String?> login(String email, String password) async {
    try {
      final json = await ApiClient.instance.login(email, password);
      user = _userFromApi(json);
      try {
        await loadUsers();
      } on ApiException {}
      try {
        await loadCourses();
      } on ApiException {}
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      if (e.status == 401) return 'Email ou mot de passe incorrect.';
      return e.message;
    }
  }

  AppUser _userFromApi(Map<String, dynamic> j) => AppUser(
        id: '${j['id']}',
        name: (j['full_name'] as String?)?.trim().isNotEmpty == true
            ? j['full_name'] as String
            : '${j['first_name'] ?? ''} ${j['last_name'] ?? ''}'.trim(),
        email: j['email'] as String,
        password: '',
        role: switch (j['role']) {
          'admin' => Role.admin,
          'teacher' => Role.teacher,
          _ => Role.student,
        },
      );

  void logout() {
    unawaited(ApiClient.instance.logout());
    user = null;
    offline = false;
    notifyListeners();
  }

  AppUser? userById(String id) => users.where((u) => u.id == id).firstOrNull;
  String className(String? id) =>
      classes.where((c) => c.id == id).firstOrNull?.name ?? '-';
  List<AppUser> get students =>
      users.where((u) => u.role == Role.student).toList();
  List<AppUser> get teachers =>
      users.where((u) => u.role == Role.teacher).toList();

  bool createClass(String name) {
    final cleanName = name.trim();
    if (user?.role != Role.admin ||
        cleanName.isEmpty ||
        classes.any((c) => c.name.toLowerCase() == cleanName.toLowerCase())) {
      return false;
    }
    classes.add(SchoolClass(_id('c'), cleanName));
    notifyListeners();
    return true;
  }

  Future<String?> createAccount(
      String name, String email, String pwd, Role role, String? classId) async {
    final parts = name.trim().split(RegExp(r'\s+'));
    final mail = email.trim().toLowerCase();
    try {
      await ApiClient.instance.post('/users/', {
        'username': mail, // le login envoie l'email comme username
        'email': mail,
        'first_name': parts.first,
        'last_name': parts.length > 1 ? parts.sublist(1).join(' ') : '',
        'password': pwd,
        'role': role.name, // 'student' | 'teacher' | 'admin'
      });
      await loadUsers();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<void> loadUsers() async {
    final data = await ApiClient.instance.get('/users/');
    final list = data is Map ? data['results'] as List : data as List;
    users
      ..clear()
      ..addAll(list.map((j) => _userFromApi(j as Map<String, dynamic>)));
    notifyListeners();
  }

  void toggleActive(AppUser u) {
    u.active = !u.active;
    notifyListeners();
  }

  // ───────────────────────── Academic-Service ────────────────────────────────
  Course? courseById(String id) => courses.where((c) => c.id == id).firstOrNull;

  List<Course> get myCourses => courses;

  Course _courseFromApi(Map<String, dynamic> j) => Course(
        id: '${j['id']}',
        title: j['title'] as String? ?? '',
        subject: j['code'] as String? ?? '',
        teacherId: '${j['teacher']}',
        classId: '',
        description: j['description'] as String? ?? '',
      );

 
  Future<void> loadCourses() async {
    final path = user?.role == Role.admin
        ? '/academic/courses/'
        : '/academic/courses/mine/';
    final data = await ApiClient.instance.get(path);
    final list = data is Map ? data['results'] as List : data as List;
    courses
      ..clear()
      ..addAll(list.map((j) => _courseFromApi(j as Map<String, dynamic>)));
    notifyListeners();
  }

  List<AppUser> studentsOfTeacher(String teacherId) {
    final cls = courses
        .where((c) => c.teacherId == teacherId)
        .map((c) => c.classId)
        .toSet();
    return students.where((s) => cls.contains(s.classId)).toList();
  }

  void publishCourse(
      String title, String subject, String classId, String desc) {
    if (user?.role != Role.teacher) return;
    _addCourse(title, subject, classId, user!.id, desc);
  }
  Future<String?> createAcademicCourse(String title, String subject,
      String classId, String teacherId, String desc) async {
    if (user?.role != Role.admin) return 'Action réservée à l\'administrateur.';
    final cleanTitle = title.trim();
    final code = subject.trim().toUpperCase().replaceAll(' ', '');
    if (cleanTitle.isEmpty || code.isEmpty) return 'Titre et code obligatoires.';
    final teacher = int.tryParse(teacherId);
    if (teacher == null) return 'Choisissez un enseignant.';
    try {
      final years =
          await ApiClient.instance.get('/academic/years/?is_current=true');
      final yl = years is Map ? years['results'] as List : years as List;
      await ApiClient.instance.post('/academic/courses/', {
        'code': code,
        'title': cleanTitle,
        'description': desc.trim(),
        'teacher': teacher,
        if (yl.isNotEmpty) 'academic_year': yl.first['id'],
        'is_published': true,
      });
      await loadCourses();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }   

  void _addCourse(String title, String subject, String classId,
      String teacherId, String desc) {
    courses.add(Course(
        id: _id('k'),
        title: title,
        subject: subject,
        teacherId: teacherId,
        classId: classId,
        description: desc));
    final teacherName = userById(teacherId)?.name ?? 'l’établissement';
    _push('Nouveau cours : $title', 'Publié par $teacherName.', 'cours',
        role: Role.student, classId: classId);
    notifyListeners();
  }

  void addLesson(Course c, String title, bool video) {
    c.lessons.add(Lesson(_id('l'), title, video, video ? '10 min' : '1 Mo'));
    _push('Nouveau contenu : ${c.title}', title, 'cours',
        role: Role.student, classId: c.classId);
    notifyListeners();
  }

  void addSlot(Slot s) {
    schedule.add(s);
    _push('Emploi du temps mis à jour',
        '${weekdays[s.weekday]} ${s.start} - ${s.subject}', 'annonce',
        classId: s.classId);
    notifyListeners();
  }

  static const weekdays = [
    '',
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi'
  ];

  List<Slot> slotsFor(String? classId, int weekday) => (schedule
      .where((s) => s.classId == classId && s.weekday == weekday)
      .toList()
    ..sort((a, b) => a.start.compareTo(b.start)));

  /// Prochain cours : (créneau, jours d'avance).
  (Slot, int)? nextSlot(String? classId) {
    final now = _now;
    for (var d = 0; d < 7; d++) {
      final day = now.add(Duration(days: d));
      final hhmm =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      for (final s in slotsFor(classId, day.weekday)) {
        if (d > 0 || s.end.compareTo(hhmm) > 0) return (s, d);
      }
    }
    return null;
  }

  // Notes
  void enterGrade(
      String studentId, String courseId, String label, double value) {
    grades.add(ManualGrade(
        _id('g'), studentId, courseId, label, value, _now, user!.id));
    _push('Note publiée', '$label : ${value.toStringAsFixed(1)}/20', 'note',
        userId: studentId);
    notifyListeners();
  }

  List<GradeEntry> gradesOf(String studentId) {
    final list = <GradeEntry>[];
    for (final a
        in attempts.where((a) => a.studentId == studentId && a.synced)) {
      final q = quizzes.firstWhere((q) => q.id == a.quizId);
      list.add(GradeEntry(
          q.title, courseById(q.courseId)?.title ?? '', a.score, a.date, true));
    }
    for (final g in grades.where((g) => g.studentId == studentId)) {
      list.add(GradeEntry(g.label, courseById(g.courseId)?.title ?? '', g.value,
          g.date, false));
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  double? averageOf(String studentId) {
    final g = gradesOf(studentId);
    if (g.isEmpty) return null;
    return g.map((e) => e.value).reduce((a, b) => a + b) / g.length;
  }

  // ───────────────────────── Media-Service ───────────────────────────────────
  void toggleDownload(Lesson l) {
    downloaded.contains(l.id) ? downloaded.remove(l.id) : downloaded.add(l.id);
    notifyListeners();
  }

  bool canOpen(Lesson l) => !offline || downloaded.contains(l.id);

  void markDone(Lesson l) {
    if (doneLessons.add(l.id)) notifyListeners();
  }

  double progressOf(Course c) => c.lessons.isEmpty
      ? 0
      : c.lessons.where((l) => doneLessons.contains(l.id)).length /
          c.lessons.length;

  // ───────────────────────── Assessment-Service ──────────────────────────────
  List<Quiz> get myQuizzes {
    final u = user!;
    return quizzes.where((q) {
      final c = courseById(q.courseId);
      if (c == null) return false;
      return switch (u.role) {
        Role.student => c.classId == u.classId,
        Role.teacher => c.teacherId == u.id,
        Role.admin => true,
      };
    }).toList();
  }

  Attempt? attemptOf(String quizId, String studentId) => attempts
      .where((a) => a.quizId == quizId && a.studentId == studentId)
      .firstOrNull;

  int get pendingQuizCount => myQuizzes
      .where((q) => attemptOf(q.id, user!.id) == null && q.due.isAfter(_now))
      .length;

  void createQuiz(String courseId, String title, int days, List<Question> qs) {
    final c = courseById(courseId)!;
    quizzes.add(
        Quiz(_id('q'), courseId, title, _now.add(Duration(days: days)), qs));
    _push(
        'Nouveau quiz : $title',
        '${c.title} - à rendre avant ${_fmt(_now.add(Duration(days: days)))}',
        'quiz',
        role: Role.student,
        classId: c.classId);
    notifyListeners();
  }

  /// Correction automatique. Hors connexion, la soumission est mise en file.
  Attempt submitQuiz(Quiz q, List<int> answers, int warnings) {
    var ok = 0;
    for (var i = 0; i < q.questions.length; i++) {
      if (answers[i] == q.questions[i].correct) ok++;
    }
    final a = Attempt(_id('at'), q.id, user!.id, answers,
        ok / q.questions.length * 20, _now, warnings,
        synced: !offline);
    attempts.add(a);
    if (a.synced) _notifyResult(a);
    notifyListeners();
    return a;
  }

  int get pendingSyncCount =>
      attempts.where((a) => !a.synced && a.studentId == user?.id).length;

  void setOffline(bool v) {
    offline = v;
    if (!v) sync();
    notifyListeners();
  }

  /// Synchronisation au retour de la connexion.
  void sync() {
    for (final a in attempts.where((a) => !a.synced)) {
      a.synced = true;
      _notifyResult(a);
    }
    notifyListeners();
  }

  void _notifyResult(Attempt a) {
    final q = quizzes.firstWhere((q) => q.id == a.quizId);
    _push('Résultat disponible',
        '${q.title} : ${a.score.toStringAsFixed(1)}/20', 'note',
        userId: a.studentId);
  }

  /// Statistiques agrégées par question (% de mauvaises réponses).
  List<double> difficultyOf(Quiz q) {
    final done = attempts.where((a) => a.quizId == q.id && a.synced).toList();
    return [
      for (var i = 0; i < q.questions.length; i++)
        done.isEmpty
            ? 0
            : done.where((a) => a.answers[i] != q.questions[i].correct).length /
                done.length
    ];
  }

  // ───────────────────────── Billing-Service ─────────────────────────────────
  List<Invoice> invoicesOf(String studentId) =>
      invoices.where((i) => i.studentId == studentId).toList();
  int dueOf(String studentId) => invoicesOf(studentId)
      .where((i) => !i.paid)
      .fold(0, (s, i) => s + i.amount);
  int get totalCollected =>
      invoices.where((i) => i.paid).fold(0, (s, i) => s + i.amount);
  int get totalPending =>
      invoices.where((i) => !i.paid).fold(0, (s, i) => s + i.amount);

  void createInvoice(String studentId, String label, int amount, int days) {
    invoices.add(Invoice(
        _id('f'), studentId, label, amount, _now.add(Duration(days: days))));
    _push('Nouvelle facture', '$label : $amount', 'paiement',
        userId: studentId);
    notifyListeners();
  }

  /// Paiement Mobile Money : confirmé seulement après vérification « serveur ».
  Future<bool> payInvoice(Invoice inv, String operator, String phone) async {
    await Future.delayed(
        const Duration(seconds: 2)); // vérification fournisseur
    if (phone.replaceAll(RegExp(r'\D'), '').length < 8) return false;
    inv.paid = true;
    inv.paidOn = _now;
    inv.method = operator;
    inv.receipt =
        'REC-${(1000 + invoices.where((i) => i.paid).length).toString()}';
    _push('Paiement confirmé', '${inv.label} - reçu ${inv.receipt}', 'paiement',
        userId: inv.studentId);
    notifyListeners();
    return true;
  }

  // ───────────────────────── Notification-Service ────────────────────────────
  void _push(String title, String body, String type,
      {Role? role, String? userId, String? classId}) {
    notifs.add(AppNotif(_id('n'), title, body, type, _now,
        role: role, userId: userId, classId: classId));
  }

  void announce(String title, String body, Role? role) {
    _push(title, body, 'annonce', role: role);
    notifyListeners();
  }

  List<AppNotif> get myNotifs {
    final u = user!;
    return (notifs.where((n) {
      if (n.role != null && n.role != u.role) return false;
      if (n.userId != null && n.userId != u.id) return false;
      if (n.classId != null && u.role == Role.student && n.classId != u.classId)
        return false;
      if (n.classId != null &&
          u.role == Role.teacher &&
          !courses.any((c) => c.teacherId == u.id && c.classId == n.classId))
        return false;
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date)));
  }

  int get unreadCount =>
      myNotifs.where((n) => !_read.contains('${user!.id}:${n.id}')).length;
  bool isRead(AppNotif n) => _read.contains('${user!.id}:${n.id}');

  void markAllRead() {
    for (final n in myNotifs) {
      _read.add('${user!.id}:${n.id}');
    }
    notifyListeners();
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  // ───────────────────────── Tuteur IA (simulation) ──────────────────────────
  String tutorReply(String question) {
    final q = question.toLowerCase();
    if (q.contains('récurs')) {
      return 'Une fonction récursive s\'appelle elle-même jusqu\'à un cas d\'arrêt. Exemple : factorielle(n) = n × factorielle(n-1), avec factorielle(0) = 1.';
    }
    if (q.contains('boucle') || q.contains('while')) {
      return 'Une boucle répète un bloc d\'instructions. « while » teste la condition avant chaque tour, « for » est pratique quand le nombre de tours est connu.';
    }
    if (q.contains('sql') || q.contains('requête')) {
      return 'SQL sert à interroger une base relationnelle. Base : SELECT colonnes FROM table WHERE condition ; pensez aussi à JOIN pour relier deux tables.';
    }
    if (q.contains('complex')) {
      return 'La complexité mesure l\'évolution du temps d\'exécution selon la taille n : O(1) constant, O(n) linéaire, O(n²) quadratique.';
    }
    return 'Bonne question ! Reformulez avec un mot-clé du cours (boucle, récursivité, SQL, complexité) et je vous l\'explique simplement.';
  }

  /// Chapitres à réviser : cours dont la moyenne des quiz est < 12.
  List<String> recommendations(String studentId) {
    final out = <String>[];
    for (final a in attempts
        .where((a) => a.studentId == studentId && a.synced && a.score < 12)) {
      final q = quizzes.firstWhere((q) => q.id == a.quizId);
      final c = courseById(q.courseId);
      if (c != null && c.lessons.isNotEmpty)
        out.add('${c.title} - ${c.lessons.first.title}');
    }
    return out;
  }
  Future<String?> enrollStudent(String studentId, String courseId) async {
  if (user?.role != Role.admin) return 'Action réservée à l\'administrateur.';
  try {
    await ApiClient.instance.post('/academic/enrollments/', {
      'student': int.parse(studentId),
      'course': int.parse(courseId),
    });
    return null;
  } on ApiException catch (e) {
    return e.message;
  }
}

}


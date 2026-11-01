import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'local_storage.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../l10n/app_localizations.dart';

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
  DownloadedLessonsManager? _downloadsManager;
  
  DownloadedLessonsManager get _downloads {
    _downloadsManager ??= DownloadedLessonsManager(SharedPreferences.getInstance());
    return _downloadsManager!;
  }

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
          lessons: [
            Lesson('l1', 'Introduction aux algorithmes', true, '12 min',
                url: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', size: 12000000),
            Lesson('l2', 'Boucles et conditions', true, '18 min',
                url: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
                meetingLink: 'https://meet.google.com/abc-defg-hij', size: 18000000),
            Lesson('l3', 'Support de cours - Chapitre 1', false, '1,2 Mo', size: 1200000),
          ]),
Course(
        id: 'k2',
        title: 'Bases de données',
        subject: 'Informatique',
        teacherId: 't1',
        classId: 'c1',
        description: 'Modèle relationnel, SQL et normalisation.',
        lessons: [
          Lesson('l4', 'Modèle relationnel', true, '20 min', size: 20000000),
          Lesson('l5', 'Requêtes SQL', false, '2,4 Mo', size: 2400000),
        ]),
Course(
        id: 'k3',
        title: 'Administration réseaux',
        subject: 'Réseaux',
        teacherId: 't1',
        classId: 'c2',
        description: 'Adressage IP, routage et services réseau.',
        lessons: [Lesson('l6', 'Adressage IPv4', true, '15 min', size: 15000000)]),
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
        _now.subtract(const Duration(days: 30)),
        paid: true,
        paidOn: _now.subtract(const Duration(days: 28)),
        receipt: 'REC-0002',
        method: 'Mobile Money'),
    Invoice('f3', 's1', 'Frais scolaires - Tranche 3', 150,
        _now.subtract(const Duration(days: 20)),
        paid: true,
        paidOn: _now.subtract(const Duration(days: 18)),
        receipt: 'REC-0003',
        method: 'Mobile Money'),
    Invoice('f4', 's2', 'Frais scolaires - Tranche 1', 150,
        _now.add(const Duration(days: 3)),
        paid: true,
        paidOn: _now,
        receipt: 'REC-0004',
        method: 'Carte Bancaire'),
    Invoice('f5', 's3', 'Frais scolaires - Tranche 1', 150,
        _now.add(const Duration(days: 8)),
        paid: false),
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

  final Set<String> doneLessons = {};
  final Set<String> _read = {};

  Future<bool> isDownloaded(String lessonId) async {
    return await _downloads.isDownloaded(lessonId);
  }

  Future<String?> getLocalPath(String lessonId) async {
    return await _downloads.getLocalPath(lessonId);
  }

  // \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500 Pr\u00e9f\u00e9rences d'affichage \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  bool darkMode = false;
  bool highContrast = false;
  bool reduceMotion = false;
  double textScale = 1.0;
  void toggleDarkMode() {
    darkMode = !darkMode;
    notifyListeners();
  }

  void toggleHighContrast() {
    highContrast = !highContrast;
    notifyListeners();
  }

  void toggleReduceMotion() {
    reduceMotion = !reduceMotion;
    notifyListeners();
  }

  Locale locale = const Locale('fr');
  void setLocale(String langCode) {
    locale = Locale(langCode);
    notifyListeners();
  }

  void setTextScale(double v) {
    textScale = v.clamp(0.8, 1.4);
    notifyListeners();
  }

  // ───────────────────────── Données étendues (v2) ───────────────────────────
  late final messages = <ChatMessage>[];
  late final assignments = <Assignment>[];
  late final submissions = <Submission>[];
  final Set<String> _remindedAssignments = {};
  late final attendance = <AttendanceRecord>[];
  late final scholarships = <Scholarship>[];

  // ───────────────────────── Auth-Service ────────────────────────────────────
    Future<String?> login(String email, String password) async {
    final mail = email.trim().toLowerCase();
    // Comptes de démo locaux (fonctionnent sans API)
    final demoUser = users.where((u) => u.email.toLowerCase() == mail && u.password == password).firstOrNull;
    if (demoUser != null) {
      user = demoUser;
      notifyListeners();
      pushDueReminders();
      return null;
    }
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
       pushDueReminders();
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
        classId: (j['class'] ?? j['class_id'] ?? j['classroom'] ?? '').toString(),
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
    // Tentative via l'API ; repli local si le serveur est injoignable (mode démo).
    try {
      final years =
          await ApiClient.instance.get('/academic/years/?is_current=true');
      final yl = years is Map ? years['results'] as List : years as List;
      await ApiClient.instance.post('/academic/courses/', {
        'code': code,
        'title': cleanTitle,
        'description': desc.trim(),
        'teacher': teacher,
        if (int.tryParse(classId) != null) 'class': int.parse(classId),
        if (yl.isNotEmpty) 'academic_year': yl.first['id'],
        'is_published': true,
      });
      await loadCourses();
      return null;
    } on ApiException catch (_) {
      // repli local
    } catch (_) {
      // repli local
    }
    final c = Course(
        id: _id('k'),
        title: cleanTitle,
        subject: subject.trim(),
        teacherId: teacherId,
        classId: classId,
        description: desc.trim());
    courses.add(c);
    final teacherName = userById(teacherId)?.name ?? 'l’établissement';
    _push('Nouveau cours : $cleanTitle', 'Publié par $teacherName.', 'cours',
        role: Role.student, classId: classId);
    notifyListeners();
    return null;
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
        role: Role.student, classId: classId.isEmpty ? null : classId);
    notifyListeners();
  }

  void addLesson(Course c, String title, bool video,
      {String? url, String? meetingLink, bool isPhoto = false, int size = 0}) {
    c.lessons.add(Lesson(_id('l'), title, video, video ? '10 min' : '1 Mo',
        url: url, meetingLink: meetingLink, isPhoto: isPhoto, size: size));
    _push('Nouveau contenu : ${c.title}', title, 'cours',
        role: Role.student, classId: c.classId.isEmpty ? null : c.classId);
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
  /// Télécharge ou supprime un fichier localement (persistant SharedPreferences)
  Future<void> toggleDownload(Lesson l) async {
    final isDownloaded = await _downloads.isDownloaded(l.id);
    if (isDownloaded) {
      // Supprimer le fichier local
      final localPath = await _downloads.getLocalPath(l.id);
      if (localPath != null) {
        try {
          await File(localPath).delete();
        } catch (_) {}
      }
      await _downloads.deleteDownload(l.id);
    } else {
      // Télécharger le fichier depuis l'URL
      if (l.url == null || l.url!.isEmpty) return;
      try {
        final dir = await getApplicationDocumentsDirectory();
        final fileName = '${l.id}_${l.title.replaceAll(RegExp(r'[^\w\.]'), '_')}';
        final file = File('${dir.path}/$fileName');
        
        final client = http.Client();
        final response = await client.get(Uri.parse(l.url!));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          await _downloads.saveDownload(l.id, file.path, response.bodyBytes.length, l.url);
        }
        client.close();
      } catch (e) {
        // Erreur de téléchargement, ignorer silencieusement
      }
    }
    notifyListeners();
  }

  /// Vérifie si le fichier est accessible (en ligne ou téléchargé)
  Future<bool> canOpen(Lesson l) async {
    if (!offline) return true;
    return await isDownloaded(l.id);
  }

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
    final quizId = _id('q');
    quizzes.add(
        Quiz(quizId, courseId, title, _now.add(Duration(days: days)), qs));
    _push(
        'Nouveau quiz : $title',
        '${c.title} - à rendre avant ${_fmt(_now.add(Duration(days: days)))}',
        'quiz',
        role: Role.student,
        classId: c.classId.isEmpty ? null : c.classId,
        refId: quizId);
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
    for (final sub in submissions.where((s) => !s.synced)) {
      sub.synced = true;
      _push('Devoir synchronisé', sub.content, 'cours', userId: sub.studentId);
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

  void resetInvoice(Invoice inv) {
    inv.paid = false;
    inv.paidOn = null;
    inv.receipt = null;
    inv.method = null;
    notifyListeners();
  }

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
    _push('Paiement reçu', '${userById(inv.studentId)?.name ?? inv.studentId} - ${inv.label} (${inv.receipt})',
        'paiement', role: Role.admin);
    notifyListeners();
    return true;
  }

  String receiptText(Invoice inv) {
    if (!inv.paid || inv.receipt == null || inv.paidOn == null) return '';
    final user = userById(inv.studentId);
    final className = classes.where((c) => c.id == user?.classId).firstOrNull?.name ?? '-';
    return """RECU DE PAIEMENT
====================
Etablissement : ${AppConfig.appName}
No recu : ${inv.receipt}
Eleve : ${user?.name ?? inv.studentId}
Filiere : $className
Libelle : ${inv.label}
Montant : ${fmtMoney(inv.amount)}
Mode de paiement : ${inv.method ?? '-'}
Date de paiement : ${fmtDate(inv.paidOn!)}
Heure de paiement : ${inv.paidOn!.hour.toString().padLeft(2, '0')}:${inv.paidOn!.minute.toString().padLeft(2, '0')}:${inv.paidOn!.second.toString().padLeft(2, '0')}
Statut : Paye
====================
Merci pour votre confiance.
""";
  }

  /// Genere et enregistre un fichier recu telechargeable sur l'appareil.
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
  // ─── Notification-Service ───
  void _push(String title, String body, String type,
      {Role? role, String? userId, String? classId, String? refId}) {
    notifs.add(AppNotif(_id('n'), title, body, type, _now,
        role: role, userId: userId, classId: classId, refId: refId));
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

  // ───────────────────────── Tuteur IA (recommandations) ─────────────────────
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

  // ───────────────────────── Messagerie ──────────────────────────────────────
  List<ChatMessage> messagesFor(String userId) => messages
      .where((m) =>
          m.senderId == userId ||
          m.receiverId == userId ||
          (m.classId != null &&
              users.any((u) => u.id == userId && u.classId == m.classId)))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  List<ChatMessage> conversation(String a, String b) => messages
      .where((m) =>
          (m.senderId == a && m.receiverId == b) ||
          (m.senderId == b && m.receiverId == a))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  void sendMessage(String text, {String? receiverId, String? classId}) {
    if (user == null || text.trim().isEmpty) return;
    messages.add(ChatMessage(_id('m'), user!.id, text.trim(), _now,
        receiverId: receiverId, classId: classId));
    if (receiverId != null) {
      _push('Nouveau message', text.trim(), 'message', userId: receiverId);
    } else if (classId != null) {
      _push('Message de classe', text.trim(), 'message', classId: classId);
    }
    notifyListeners();
  }

  int unreadMessages(String userId) => messages
      .where((m) => m.receiverId == userId && !m.read && m.senderId != userId)
      .length;

  void markMessagesRead(String userId) {
    for (final m in messages) {
      if (m.receiverId == userId) m.read = true;
    }
    notifyListeners();
  }

  // ───────────────────────── Devoirs / Assignments ───────────────────────────
  List<Assignment> assignmentsForTeacher(String teacherId) =>
      assignments.where((a) => a.teacherId == teacherId).toList()
        ..sort((a, b) => a.due.compareTo(b.due));

  List<Assignment> assignmentsForStudent(String studentId) {
    final u = userById(studentId);
    final courseIds = courses
        .where((c) => c.classId == u?.classId)
        .map((c) => c.id)
        .toSet();
    return assignments.where((a) {
      if (!courseIds.contains(a.courseId)) return false;
      if (a.isGroup && a.groupMembers.isNotEmpty) {
        return a.groupMembers.contains(studentId);
      }
      return true;
    }).toList()
      ..sort((a, b) => a.due.compareTo(b.due));
  }

  void createAssignment(String courseId, String title, String desc, DateTime due,
      {bool isGroup = false,
      List<String> groupMembers = const [],
      Map<String, String> groupRoles = const {},
      List<RubricCriterion> rubric = const [],
      String submissionType = 'text',
      int maxSizeMb = 10,
      double latePenaltyPerDay = 0}) {
    if (user?.role != Role.teacher) return;
    final a = Assignment(_id('as'), courseId, title.trim(), desc.trim(),
        due, user!.id,
        isGroup: isGroup,
        groupMembers: groupMembers,
        groupRoles: groupRoles,
        rubric: rubric,
        submissionType: submissionType,
        maxSizeMb: maxSizeMb,
        latePenaltyPerDay: latePenaltyPerDay);
    assignments.add(a);
    final c = courseById(courseId);
    _push('Nouveau devoir : ${a.title}', c?.title ?? '', 'cours',
        role: Role.student, classId: c?.classId);
    notifyListeners();
  }

  Submission? submissionOf(String assignmentId, String studentId) =>
      submissions
          .where((s) => s.assignmentId == assignmentId && s.studentId == studentId)
          .firstOrNull;

  List<Submission> submissionsForAssignment(String assignmentId) =>
      submissions.where((s) => s.assignmentId == assignmentId).toList();

  void submitAssignment(String assignmentId, String content,
      {List<String> attachments = const []}) {
    if (user?.role != Role.student) return;
    final a = assignments.where((x) => x.id == assignmentId).firstOrNull;
    if (a != null && a.due.isBefore(_now)) return; // échéance dépassée
    final uid = user!.id;
    // Groupe : dépôt partagé
    if (a != null && a.isGroup && a.groupMembers.isNotEmpty) {
      final members = a.groupMembers;
      Submission? existing;
      for (final sub in submissions) {
        if (sub.assignmentId == assignmentId && members.contains(sub.studentId)) {
          existing = sub;
          break;
        }
      }
      final version = SubmissionVersion(content.trim(), attachments, _now);
      if (existing != null) {
        existing.content = content.trim();
        existing.attachments = attachments;
        existing.date = _now;
        existing.versions.add(version);
        if (!existing.contributors.contains(uid)) existing.contributors.add(uid);
        existing.synced = !offline;
      } else {
        final leader = members.first;
        submissions.add(Submission(
            _id('sub'), assignmentId, leader, content.trim(), _now,
            attachments: attachments, versions: [version], contributors: [uid], synced: !offline));
      }
    } else {
      final existing = submissionOf(assignmentId, uid);
      final version = SubmissionVersion(content.trim(), attachments, _now);
      if (existing != null) {
        existing.content = content.trim();
        existing.attachments = attachments;
        existing.date = _now;
        existing.versions.add(version);
        existing.synced = !offline;
      } else {
        submissions.add(Submission(
            _id('sub'), assignmentId, uid, content.trim(), _now,
            attachments: attachments, versions: [version], synced: !offline));
      }
    }
    if (!offline) {
      _push('Devoir rendu', content.trim(), 'cours', userId: uid);
    }
    notifyListeners();
  }

  void gradeSubmission(String submissionId, double grade, String feedback,
      {List<RubricCriterion> rubricScores = const []}) {
    final s = submissions.firstWhere((e) => e.id == submissionId);
    final a = assignments.where((x) => x.id == s.assignmentId).firstOrNull;
    var finalGrade = grade;
    if (a != null && a.latePenaltyPerDay > 0 && s.date.isAfter(a.due)) {
      final daysLate = s.date.difference(a.due).inDays + 1;
      finalGrade = (grade - a.latePenaltyPerDay * daysLate).clamp(0, 20);
    }
    s.grade = finalGrade;
    s.feedback = feedback;
    s.rubricScores = rubricScores;
    _push('Devoir corrigé', '${finalGrade.toStringAsFixed(1)}/20', 'note',
        userId: s.studentId);
    notifyListeners();
  }

  // ───────────────────────── Devoirs - statistiques / plagiat / IA ─────────────
  Map<String, dynamic> assignmentStats(String assignmentId) {
    final subs = submissionsForAssignment(assignmentId);
    final graded = subs.where((s) => s.grade != null).toList();
    final avg = graded.isEmpty ? null : graded.map((s) => s.grade!).reduce((a, b) => a + b) / graded.length;
    return {
      'total': subs.length,
      'graded': graded.length,
      'pending': subs.length - graded.length,
      'average': avg,
      'late': subs.where((s) {
        final a = assignments.firstWhere((x) => x.id == assignmentId);
        return s.date.isAfter(a.due);
      }).length,
    };
  }

  String exportAssignmentCsv(String assignmentId) {
    final a = assignments.firstWhere((x) => x.id == assignmentId);
    final subs = submissionsForAssignment(assignmentId);
    final buf = StringBuffer();
    buf.writeln('Devoir;${a.title}');
    buf.writeln('Etudiant;Note;Date;En retard;Feedback');
    for (final s in subs) {
      final st = userById(s.studentId);
      final late = s.date.isAfter(a.due) ? 'Oui' : 'Non';
      buf.writeln('${st?.name ?? s.studentId};${s.grade?.toStringAsFixed(2) ?? ''};${fmtDate(s.date)};$late;${s.feedback ?? ''}');
    }
    return buf.toString();
  }

  double similarity(String a, String b) {
    final wa = a.toLowerCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toSet();
    final wb = b.toLowerCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toSet();
    if (wa.isEmpty || wb.isEmpty) return 0;
    final inter = wa.intersection(wb).length;
    return inter / (wa.length + wb.length - inter);
  }

  Map<String, double> plagiarismReport(String assignmentId) {
    final subs = submissionsForAssignment(assignmentId);
    final out = <String, double>{};
    for (var i = 0; i < subs.length; i++) {
      for (var j = i + 1; j < subs.length; j++) {
        final sim = similarity(subs[i].content, subs[j].content);
        if (sim >= 0.6) {
          out['${subs[i].studentId}-${subs[j].studentId}'] = sim;
        }
      }
    }
    return out;
  }

  String suggestFeedback(String content, double grade) {
    if (grade >= 16) return 'Excellent travail, très bien structuré. Continuez ainsi.';
    if (grade >= 12) return 'Bon travail, quelques points à améliorer (clarté, exemples).';
    if (grade >= 8) return 'Travail acceptable mais incomplet ; approfondir les notions.';
    return 'Travail insuffisant ; revoir les bases et resoumettre.';
  }
  void gradeGroupMember(String submissionId, String studentId, double grade, String feedback) {
    final sub = submissions.firstWhere((e) => e.id == submissionId);
    sub.memberGrades[studentId] = grade;
    sub.memberFeedback[studentId] = feedback;
    _push('Devoir corrigé', '${grade.toStringAsFixed(1)}/20', 'note', userId: studentId);
    notifyListeners();
  }

  List<Assignment> dueSoonAssignments(String studentId, {int withinDays = 2}) {
    final now = DateTime.now();
    final limit = now.add(Duration(days: withinDays));
    return assignmentsForStudent(studentId).where((a) => a.due.isAfter(now) && a.due.isBefore(limit)).toList();
  }

  void pushDueReminders() {
    if (user?.role != Role.student) return;
    final uid = user!.id;
    for (final a in dueSoonAssignments(uid)) {
      if (_remindedAssignments.contains(a.id)) continue;
      final sub = submissionOf(a.id, uid);
      if (sub != null) continue;
      _remindedAssignments.add(a.id);
      _push('Rappel devoir', '${a.title} à rendre avant le ${fmtDate(a.due)}', 'cours', userId: uid);
    }
    for (final a in assignmentsForStudent(uid)) {
      if (a.due.isBefore(DateTime.now())) {
        final sub = submissionOf(a.id, uid);
        if (sub == null && !_remindedAssignments.contains('late_${a.id}')) {
          _remindedAssignments.add('late_${a.id}');
          _push('Devoir en retard', '${a.title} (échéance dépassée)', 'cours', userId: uid);
        }
      }
    }
    notifyListeners();
  }

  void markAttendance(String classId, String studentId, DateTime date, bool present,
      {String? note}) {
    final day = DateTime(date.year, date.month, date.day);
    final existing = attendance.firstWhere(
        (a) =>
            a.classId == classId &&
            a.studentId == studentId &&
            a.date.year == day.year &&
            a.date.month == day.month &&
            a.date.day == day.day,
        orElse: () => AttendanceRecord('', '', '', day, true));
    if (existing.id.isEmpty) {
      attendance.add(AttendanceRecord(_id('att'), classId, studentId, day, present,
          note: note));
    } else {
      existing.present = present;
    }
    notifyListeners();
  }

  List<AttendanceRecord> attendanceForClass(String classId, DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return attendance
        .where((a) =>
            a.classId == classId &&
            a.date.year == day.year &&
            a.date.month == day.month &&
            a.date.day == day.day)
        .toList();
  }

  double attendanceRate(String studentId) {
    final recs = attendance.where((a) => a.studentId == studentId).toList();
    if (recs.isEmpty) return 1.0;
    return recs.where((a) => a.present).length / recs.length;
  }

  // ───────────────────────── Bourses ──────────────────────────────────────────
  void grantScholarship(String studentId, String label, int discount) {
    if (user?.role != Role.admin) return;
    scholarships.add(Scholarship(_id('sch'), studentId, label, discount, _now));
    _push('Bourse accordée', '$label (-$discount%)', 'paiement',
        userId: studentId);
    notifyListeners();
  }

  int effectiveDue(String studentId) {
    final due = dueOf(studentId);
    final disc = scholarships
        .where((s) => s.studentId == studentId)
        .fold<int>(0, (a, b) => a + b.discount);
    if (disc <= 0) return due;
    return (due * (100 - disc.clamp(0, 100)) / 100).round();
  }

  // ───────────────────────── Conflits d'emploi du temps ──────────────────────
  bool hasSlotConflict(Slot s) => schedule.any((o) =>
      o.classId == s.classId &&
      o.weekday == s.weekday &&
      o.start == s.start &&
      o.room == s.room &&
      o != s);

  // ───────────────────────── Tuteur IA avancé ────────────────────────────────
  String tutorReplyAdvanced(String question, {String? courseId}) {
    final base = tutorReply(question);
    final q = question.toLowerCase();
    if (q.contains('devoir') || q.contains('assignment')) {
      final as = assignmentsForStudent(user?.id ?? '');
      if (as.isNotEmpty) {
        return '$base\n\nVos devoirs en cours : ${as.map((a) => a.title).join(', ')}.';
      }
    }
    if (q.contains('note') || q.contains('moyenne')) {
      if (user != null && user!.role == Role.student) {
        final avg = averageOf(user!.id);
        return '$base\n\nVotre moyenne actuelle : ${avg == null ? '-' : avg.toStringAsFixed(1)}/20.';
      }
    }
    if (q.contains('emploi') || q.contains('cours')) {
      if (user != null) {
        final n = nextSlot(user!.classId);
        if (n != null) {
          return '$base\n\nProchain cours : ${n.$1.subject} ${n.$1.start}-${n.$1.end} (${n.$1.room}).';
        }
      }
    }
    return base;
  }

  // ───────────────────────── Rapport de présence / bulletin ──────────────────
  Map<String, dynamic> reportCard(String studentId) {
    final grades = gradesOf(studentId);
    final avg = averageOf(studentId);
    final att = attendanceRate(studentId);
    return {
      'grades': grades,
      'average': avg,
      'attendance': att,
      'scholarships': scholarships.where((s) => s.studentId == studentId).toList(),
    };
  }

  // ───────────────────────── Analytique enseignant ───────────────────────────
  Map<String, int> teacherStats(String teacherId) {
    final myCourseIds = courses.where((c) => c.teacherId == teacherId).map((c) => c.id).toSet();
    final myQuizzes = quizzes.where((q) => myCourseIds.contains(q.courseId)).toList();
    return {
      'courses': myCourseIds.length,
      'quizzes': myQuizzes.length,
      'submissions': submissions.length,
      'students': studentsOfTeacher(teacherId).length,
    };
  }

  // ------------------------- Inscriptions élèves -----------------------------
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



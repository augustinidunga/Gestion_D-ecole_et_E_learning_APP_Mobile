import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import 'models.dart';

/// État global de l'application, alimenté par l'API Django.
class AppState extends ChangeNotifier {
  AppUser? user;
  bool offline = false;
  int _seq = 100;
  String _id(String p) => '$p${_seq++}';
  DateTime get _now => DateTime.now();

  // ───────────────────────── Données (chargées depuis l'API) ─────────────────
  final classes = <SchoolClass>[];
  final users = <AppUser>[];
  final courses = <Course>[];
  final quizzes = <Quiz>[];
  final attempts = <Attempt>[];
  final grades = <ManualGrade>[];
  final invoices = <Invoice>[];
  final schedule = <Slot>[];
  final notifs = <AppNotif>[];
  final enrollments = <Map<String, dynamic>>[];

  /// Années scolaires (noms) et année courante.
  final years = <String>[];
  String? currentYear;

  /// Infos complémentaires par utilisateur : title, class_name, academic_year.
  final userMeta = <String, Map<String, String>>{};

  final Set<String> downloaded = {};
  final Set<String> doneLessons = {};
  final Set<String> _read = {};

  List _items(dynamic data) =>
      data is Map ? data['results'] as List : data as List;

  // ───────────────────────── Auth-Service ────────────────────────────────────
  Future<String?> login(String email, String password) async {
    try {
      final json = await ApiClient.instance.login(email, password);
      user = _userFromApi(json);
      for (final load in [
        loadUsers,
        loadYears,
        loadCourses,
        loadEnrollments,
        loadSchedule,
        loadGrades,
        loadQuizzes,
        loadAttempts,
        loadInvoices, 
      ]) {
        try {
          await load();
        } on ApiException {}
      }
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
      )..active = j['is_active'] != false;

  void logout() {
    unawaited(ApiClient.instance.logout());
    user = null;
    offline = false;
    for (final l in [users, courses, enrollments, schedule, grades, years, quizzes, attempts, invoices, accounts, pendingPayments]) {
      l.clear();
    }
    userMeta.clear();
    currentYear = null;
    balance = 0;
    notifyListeners();
  }


  AppUser? userById(String id) => users.where((u) => u.id == id).firstOrNull;
  String className(String? id) =>
      classes.where((c) => c.id == id).firstOrNull?.name ?? '-';
  List<AppUser> get students =>
      users.where((u) => u.role == Role.student).toList();
  List<AppUser> get teachers =>
      users.where((u) => u.role == Role.teacher).toList();

  Future<void> loadClasses() async {
    final data = await ApiClient.instance.get('/academic/classes/');
    classes
      ..clear()
      ..addAll(_items(data).map((e) {
        final j = e as Map<String, dynamic>;
        return SchoolClass('${j['id']}', '${j['name']}');
      }));
    notifyListeners();
  }

  Future<String?> createClass(String name) async {
    if (user?.role != Role.admin) return 'Action réservée à l\'administrateur.';
    final clean = name.trim();
    if (clean.isEmpty) return 'Nom obligatoire.';
    try {
      await ApiClient.instance.post('/academic/classes/', {'name': clean});
      await loadClasses();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  int studentsInClass(SchoolClass c) =>
      userMeta.values.where((m) => m['class_name'] == c.name).length;


      
  // ───────────────────────── Comptes ─────────────────────────────────────────
  Future<void> loadYears() async {
    final data = await ApiClient.instance.get('/academic/years/');
    years.clear();
    currentYear = null;
    for (final e in _items(data)) {
      final j = e as Map<String, dynamic>;
      years.add('${j['name']}');
      if (j['is_current'] == true) currentYear = '${j['name']}';
    }
    notifyListeners();
  }

  Future<String?> createAccount(
    String name,
    String email,
    String pwd,
    Role role, {
    String title = '',
    String className = '',
    String academicYear = '',
  }) async {
    final parts = name.trim().split(RegExp(r'\s+'));
    final mail = email.trim().toLowerCase();
    try {
      await ApiClient.instance.post('/users/', {
        'username': mail,
        'email': mail,
        'first_name': parts.first,
        'last_name': parts.length > 1 ? parts.sublist(1).join(' ') : '',
        'password': pwd,
        'role': role.name,
        if (role == Role.student) 'class_name': className,
        if (role == Role.student) 'academic_year': academicYear,
        if (role != Role.student) 'title': title,
      });
      await loadUsers();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<void> loadUsers() async {
    final data = await ApiClient.instance.get('/users/');
    final list = _items(data);
    users
      ..clear()
      ..addAll(list.map((j) => _userFromApi(j as Map<String, dynamic>)));
    userMeta.clear();
    for (final e in list) {
      final j = e as Map<String, dynamic>;
      userMeta['${j['id']}'] = {
        'title': '${j['title'] ?? ''}',
        'class_name': '${j['class_name'] ?? ''}',
        'academic_year': '${j['academic_year'] ?? ''}',
      };
    }
    notifyListeners();
  }

  Future<String?> toggleActive(AppUser u) async {
    try {
      await ApiClient.instance
          .patch('/users/${u.id}/', {'is_active': !u.active});
      u.active = !u.active;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> updateUser(AppUser u,
      {required String name,
      required String email,
      required Role role,
      String? password}) async {
    final parts = name.trim().split(RegExp(r'\s+'));
    final mail = email.trim().toLowerCase();
    try {
      await ApiClient.instance.patch('/users/${u.id}/', {
        'username': mail,
        'email': mail,
        'first_name': parts.first,
        'last_name': parts.length > 1 ? parts.sublist(1).join(' ') : '',
        'role': role.name,
        if (password != null && password.isNotEmpty) 'password': password,
      });
      await loadUsers();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> deleteUser(AppUser u) async {
    if (u.id == user?.id) {
      return 'Vous ne pouvez pas supprimer votre propre compte.';
    }
    try {
      await ApiClient.instance.delete('/users/${u.id}/');
      await loadUsers();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
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
    courses
      ..clear()
      ..addAll(
          _items(data).map((j) => _courseFromApi(j as Map<String, dynamic>)));
    notifyListeners();
  }

  Future<void> loadEnrollments() async {
    final data = await ApiClient.instance.get('/academic/enrollments/');
    enrollments
      ..clear()
      ..addAll(_items(data).cast<Map<String, dynamic>>());
    notifyListeners();
  }

  int enrolledCount(String courseId) => enrollments
      .where((e) => '${e['course']}' == courseId && e['status'] == 'active')
      .length;

  Future<String?> enrollStudent(String studentId, String courseId) async {
    if (user?.role != Role.admin) return 'Action réservée à l\'administrateur.';
    try {
      await ApiClient.instance.post('/academic/enrollments/', {
        'student': int.parse(studentId),
        'course': int.parse(courseId),
      });
      await loadEnrollments();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  /// Étudiants inscrits à au moins un cours de l'enseignant.
  List<AppUser> studentsOfTeacher(String teacherId) {
    final courseIds =
        courses.where((c) => c.teacherId == teacherId).map((c) => c.id).toSet();
    final studentIds = enrollments
        .where((e) =>
            courseIds.contains('${e['course']}') && e['status'] != 'dropped')
        .map((e) => '${e['student']}')
        .toSet();
    return students.where((s) => studentIds.contains(s.id)).toList();
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
    if (cleanTitle.isEmpty || code.isEmpty) {
      return 'Titre et code obligatoires.';
    }
    final teacher = int.tryParse(teacherId);
    if (teacher == null) return 'Choisissez un enseignant.';
    try {
      final yearsData =
          await ApiClient.instance.get('/academic/years/?is_current=true');
      final yl = _items(yearsData);
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

  // ───────────────────────── Emploi du temps ─────────────────────────────────
  static const weekdays = [
    '',
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi'
  ];

  String _hhmm(dynamic t) {
    final s = '$t';
    return s.length >= 5 ? s.substring(0, 5) : s;
  }

  Future<void> loadSchedule() async {
    final data = await ApiClient.instance.get('/academic/timetable/');
    schedule
      ..clear()
      ..addAll(_items(data).map((e) {
        final j = e as Map<String, dynamic>;
        final c = courseById('${j['course']}');
        return Slot(
          '',
          (j['weekday'] as num).toInt(),
          _hhmm(j['start_time']),
          _hhmm(j['end_time']),
          j['course_title'] as String? ?? '',
          j['room'] as String? ?? '',
          c == null ? '' : (userById(c.teacherId)?.name ?? ''),
        );
      }));
    notifyListeners();
  }

  Future<String?> createSlot({
    required String courseId,
    required int weekday,
    required String start,
    required String end,
    required String room,
  }) async {
    try {
      await ApiClient.instance.post('/academic/timetable/', {
        'course': int.parse(courseId),
        'weekday': weekday,
        'start_time': start,
        'end_time': end,
        'room': room,
      });
      await loadSchedule();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  /// Ajout local (conservé pour compatibilité avec d'anciens écrans).
  void addSlot(Slot s) {
    schedule.add(s);
    notifyListeners();
  }

  List<Slot> slotsFor(String? classId, int weekday) => (schedule
      .where((s) =>
          (s.classId.isEmpty || s.classId == classId) && s.weekday == weekday)
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

  // ───────────────────────── Notes ───────────────────────────────────────────
  Future<void> loadGrades() async {
    final data = await ApiClient.instance.get('/academic/grades/');
    grades
      ..clear()
      ..addAll(_items(data).map((e) {
        final j = e as Map<String, dynamic>;
        return ManualGrade(
          '${j['id']}',
          '${j['student']}',
          '${j['course']}',
          j['title'] as String? ?? '',
          (j['score_on_20'] as num?)?.toDouble() ?? 0,
          DateTime.tryParse('${j['created_at']}') ?? DateTime.now(),
          '${j['graded_by']}',
        );
      }));
    notifyListeners();
  }

  /// Saisie d'une note (sur 20) : retourne un message d'erreur ou null.
  Future<String?> enterGrade(
      String studentId, String courseId, String label, double value) async {
    final enrollment = enrollments
        .where((e) =>
            '${e['student']}' == studentId &&
            '${e['course']}' == courseId &&
            e['status'] != 'dropped')
        .firstOrNull;
    if (enrollment == null) {
      return 'Cet étudiant n\'est pas inscrit à ce cours.';
    }
    try {
      await ApiClient.instance.post('/academic/grades/', {
        'enrollment': enrollment['id'],
        'title': label,
        'score': value,
        'max_score': 20,
        'coefficient': 1,
      });
      await loadGrades();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  List<GradeEntry> gradesOf(String studentId) {
    final list = <GradeEntry>[];
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

  
  
    // Préfixe où quizzes.urls est monté : à vérifier dans le urls.py racine
  static const _quizBase = '/assessments';

  Quiz _quizFromApi(Map<String, dynamic> j) => Quiz(
        '${j['id']}',
        '${j['course']}',
        j['title'] as String? ?? '',
        DateTime.tryParse('${j['due_date']}') ?? DateTime(2100),
        const [],
        kind: '${j['kind']}',
        durationMinutes: j['duration_minutes'] as int?,
        maxAttempts: (j['max_attempts'] as num?)?.toInt() ?? 1,
        attemptsUsed: (j['attempts_used'] as num?)?.toInt() ?? 0,
        questionCount: (j['question_count'] as num?)?.toInt() ?? 0,
        showCorrections: j['show_corrections'] != false,
      );

  Attempt _attemptFromApi(Map<String, dynamic> j) {
    final max = double.tryParse('${j['max_score']}') ?? 0;
    final raw = double.tryParse('${j['score']}');
    return Attempt(
      '${j['id']}',
      '${j['quiz']}',
      '${j['student']}',
      const [],
      raw == null || max == 0 ? 0 : raw / max * 20,
      DateTime.tryParse('${j['submitted_at'] ?? j['started_at']}') ??
          DateTime.now(),
      0,
      status: '${j['status']}',
      maxScore: max,
    );
  }

  Future<void> loadQuizzes() async {
    final data = await ApiClient.instance.get('$_quizBase/quizzes/');
    quizzes
      ..clear()
      ..addAll(_items(data).map((j) => _quizFromApi(j as Map<String, dynamic>)));
    notifyListeners();
  }

  Future<void> loadAttempts() async {
    final data = await ApiClient.instance.get('$_quizBase/attempts/');
    attempts
      ..clear()
      ..addAll(
          _items(data).map((j) => _attemptFromApi(j as Map<String, dynamic>)));
    notifyListeners();
  }
  

    Future<({Attempt? attempt, List<Question> questions, String? error})>
      startAttempt(Quiz q) async {
    try {
      final j = await ApiClient.instance
          .post('$_quizBase/quizzes/${q.id}/start/', {}) as Map<String, dynamic>;
      final qs = (j['questions'] as List? ?? []).map((e) {
        final m = e as Map<String, dynamic>;
        final ch = (m['choices'] as List? ?? []).cast<Map<String, dynamic>>();
        return Question(
          m['text'] as String? ?? '',
          [for (final c in ch) '${c['text']}'],
          -1,
          id: '${m['id']}',
          type: '${m['type']}',
          choiceIds: [for (final c in ch) '${c['id']}'],
          points: double.tryParse('${m['points']}') ?? 1,
        );
      }).toList();
      return (attempt: _attemptFromApi(j), questions: qs, error: null);
    } on ApiException catch (e) {
      return (attempt: null, questions: <Question>[], error: e.message);
    }
  }

  Future<String?> submitAttempt(
      String attemptId, List<Map<String, dynamic>> answers) async {
    try {
      await ApiClient.instance
          .post('$_quizBase/attempts/$attemptId/submit/', {'answers': answers});
      await loadAttempts();
      await loadQuizzes();
      try {
        await loadGrades();
      } on ApiException {}
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
  // ───────────────────────── Assessment-Service ──────────────────────────────
  List<Quiz> get myQuizzes =>
      quizzes.where((q) => courseById(q.courseId) != null).toList();
  Attempt? attemptOf(String quizId, String studentId) => attempts
      .where((a) => a.quizId == quizId && a.studentId == studentId)
      .firstOrNull;

  int get pendingQuizCount => myQuizzes
      .where((q) => q.attemptsUsed < q.maxAttempts && q.due.isAfter(_now))
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



  int get pendingSyncCount =>
      attempts.where((a) => !a.synced && a.studentId == user?.id).length;

  void setOffline(bool v) {
    offline = v;
    if (!v) sync();
    notifyListeners();
  }

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
    // Préfixe où billing.urls est monté : à vérifier dans le urls.py racine
  static const _billBase = '/billing';
  String currency = 'BIF';
  int balance = 0; // solde de l'étudiant connecté
  final accounts = <Map<String, dynamic>>[]; // suivi admin/enseignant
   final pendingPayments = <Map<String, dynamic>>[];
  int _int(dynamic v) => (double.tryParse('$v') ?? 0).round();

    Future<void> loadInvoices() async {
    if (user?.role == Role.student) {
      final j = await ApiClient.instance.get('$_billBase/my-account/')
          as Map<String, dynamic>;
      currency = '${j['currency'] ?? currency}';
      balance = _int(j['balance']);
      invoices.clear();
      for (final f in (j['tuition'] as List? ?? [])) {
        for (final r in (f['installments'] as List)) {
          invoices.add(Invoice(
            'inst:${r['id']}',
            user!.id,
            '${f['title']} - ${r['label']}',
            _int(r['amount']),
            DateTime.tryParse('${r['due_date']}') ?? _now,
            paid: r['status'] == 'paid',
            status: '${r['status']}',
          ));
        }
      }
      for (final m in (j['modules'] as List? ?? [])) {
        invoices.add(Invoice(
          'course:${m['course_id']}',
          user!.id,
          'Module ${m['code']} - ${m['title']}',
          _int(m['price']),
          _now,
          paid: m['status'] == 'paid',
          status: '${m['status']}',
        ));
      }
    } else {
      final j = await ApiClient.instance.get('$_billBase/tracking/')
          as Map<String, dynamic>;
      currency = '${j['currency'] ?? currency}';
      accounts
        ..clear()
        ..addAll((j['results'] as List).cast<Map<String, dynamic>>());
      if (user?.role == Role.admin) {
        final p =
            await ApiClient.instance.get('$_billBase/payments/?status=pending');
        pendingPayments
          ..clear()
          ..addAll(_items(p).cast<Map<String, dynamic>>());
      }
    }
    notifyListeners();
  }

void createInvoice(String studentId, String label, int amount, int days) {
  invoices.add(Invoice(
    'local:${DateTime.now().millisecondsSinceEpoch}',
    studentId,
    label,
    amount,
    _now.add(Duration(days: days)),
    paid: false,
    status: 'pending',
  ));
  notifyListeners();
}
  List<Invoice> invoicesOf(String studentId) =>
      invoices.where((i) => i.studentId == studentId).toList();

  int dueOf(String studentId) {
    if (user?.role == Role.student && studentId == user!.id) return balance;
    final a = accounts
        .where((a) => '${a['student']['id']}' == studentId)
        .firstOrNull;
    return a == null ? 0 : _int(a['balance']);
  }

  int get totalCollected =>
      accounts.fold(0, (s, a) => s + _int(a['total_paid']));
  int get totalPending => accounts.fold(0, (s, a) => s + _int(a['balance']));

  /// Demande de paiement Mobile Money. Retourne un message d'erreur ou null.
  Future<String?> payInvoice(Invoice inv, String operator, String phone) async {
    final op = operator.toLowerCase();
    final provider = op.contains('lumi')
        ? 'lumicash'
        : op.contains('eco')
            ? 'ecocash'
            : 'other';
    final isInst = inv.id.startsWith('inst:');
    try {
      await ApiClient.instance.post('$_billBase/payments/', {
        if (isInst) 'installment': int.parse(inv.id.substring(5)),
        if (!isInst) 'course': int.parse(inv.id.substring(7)),
        'provider': provider,
        'phone_number': phone,
      });
      await loadInvoices();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
    Future<String?> createInstallment(
      String feeTitle, String label, int amount, int days) async {
    try {
      final fees = _items(
              await ApiClient.instance.get('$_billBase/fees/?is_active=true'))
          .cast<Map<String, dynamic>>();
      var fee = fees
          .where((f) =>
              '${f['title']}'.toLowerCase() == feeTitle.trim().toLowerCase())
          .firstOrNull;
      fee ??= await ApiClient.instance.post('$_billBase/fees/',
          {'title': feeTitle.trim(), 'is_active': true}) as Map<String, dynamic>;
      final order = ((fee['installments'] as List?)?.length ?? 0) + 1;
      final d = _now.add(Duration(days: days));
      await ApiClient.instance.post('$_billBase/installments/', {
        'fee': fee['id'],
        'label': label.trim(),
        'amount': amount,
        'due_date':
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
        'order': order,
      });
      await loadInvoices();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> confirmPayment(String id) async {
    try {
      await ApiClient.instance.post('$_billBase/payments/$id/confirm/');
      await loadInvoices();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
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
      if (n.classId != null &&
          u.role == Role.student &&
          n.classId != u.classId) {
        return false;
      }
      if (n.classId != null &&
          u.role == Role.teacher &&
          !courses.any((c) => c.teacherId == u.id && c.classId == n.classId)) {
        return false;
      }
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

  List<String> recommendations(String studentId) {
    final out = <String>[];
    for (final a in attempts
        .where((a) => a.studentId == studentId && a.synced && a.score < 12)) {
        final q = quizzes.where((q) => q.id == a.quizId).firstOrNull;
        final c = q == null ? null : courseById(q.courseId);
      if (c != null && c.lessons.isNotEmpty) {
        out.add('${c.title} - ${c.lessons.first.title}');
      }
    }
    return out;
  }
}
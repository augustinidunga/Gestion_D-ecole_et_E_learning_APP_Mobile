import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, [this.status]);
  @override
  String toString() => message;
}

/// Client HTTP vers l'API Django (JWT). Jetons gardés en mémoire.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  /// Émulateur Android : 10.0.2.2 ; autre cible : --dart-define=API_URL=...
  static const baseUrl = String.fromEnvironment('API_URL',
      defaultValue: 'http://10.0.2.2:8000/api/v1');
  static const _timeout = Duration(seconds: 15);

  String? _access;
  String? _refresh;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_access != null) 'Authorization': 'Bearer $_access',
      };

  Future<dynamic> get(String path) => _send('GET', path);
  Future<dynamic> post(String path, [Map<String, dynamic>? body]) =>
      _send('POST', path, body);
  Future<dynamic> patch(String path, Map<String, dynamic> body) =>
      _send('PATCH', path, body);

  Future<dynamic> _send(String method, String path,
      [Map<String, dynamic>? body, bool retry = true]) async {
    http.Response res;
    try {
      final req = http.Request(method, _uri(path))..headers.addAll(_headers);
      if (body != null) req.body = jsonEncode(body);
      res = await http.Response.fromStream(await req.send().timeout(_timeout));
    } on Exception {
      throw ApiException(
          'Serveur injoignable. Vérifiez la connexion et l\'adresse de l\'API.');
    }

    if (res.statusCode == 401 &&
        retry &&
        _refresh != null &&
        await _refreshAccess()) {
      return _send(method, path, body, false);
    }

    final data =
        res.body.isEmpty ? null : jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    throw ApiException(_errorMessage(data), res.statusCode);
  }

  String _errorMessage(dynamic data) {
    if (data is Map) {
      if (data['detail'] != null) return data['detail'].toString();
      if (data.isNotEmpty) {
        final v = data.values.first;
        return (v is List && v.isNotEmpty ? v.first : v).toString();
      }
    }
    return 'Erreur serveur.';
  }

  Future<bool> _refreshAccess() async {
    try {
      final res = await http
          .post(_uri('/auth/refresh/'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'refresh': _refresh}))
          .timeout(_timeout);
      if (res.statusCode != 200) {
        _access = _refresh = null;
        return false;
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      _access = data['access'] as String;
      if (data['refresh'] != null) _refresh = data['refresh'] as String;
      return true;
    } on Exception {
      return false;
    }
  }

  // ───────────── Auth-Service ─────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _send('POST', '/auth/login/', {
      'email': email.trim().toLowerCase(),
      'password': password,
    }) as Map<String, dynamic>;
    _access = data['access'] as String;
    _refresh = data['refresh'] as String;
    return data['user'] as Map<String, dynamic>;
  }

  Future<void> logout() async {
    final refresh = _refresh;
    try {
      if (refresh != null) {
        await _send('POST', '/auth/logout/', {'refresh': refresh});
      }
    } on ApiException {
      // déconnexion locale quoi qu'il arrive
    } finally {
      _access = _refresh = null;
    }
  }
}

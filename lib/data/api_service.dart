import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  // L'URL de ton backend Django
  final String baseUrl = 'http://127.0.0.1:8000/api/v1'; 
  
  // Le token JWT récupéré après le login
  final String token;

  UserService({required this.token});

  Future<List<dynamic>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/'), // Assure-toi que cette route existe bien dans Django
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // Très important pour Django
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Si Django renvoie une liste directe
        final dynamic data = jsonDecode(response.body);
        
        // Parfois Django pagine les résultats (ex: {"count": 10, "results": [...]})
        // Si c'est le cas, on prend la liste 'results', sinon on prend la liste directe
        if (data is Map<String, dynamic> && data.containsKey('results')) {
          return data['results'];
        }
        
        return data; 
      } else {
        throw Exception('Erreur serveur (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur de connexion au serveur : $e');
    }
  }
}
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  final SharedPreferences _prefs;

  AuthService._({required SharedPreferences prefs}) : _prefs = prefs;

  static Future<AuthService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthService._(prefs: prefs);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        await _prefs.setString('token', token);
        return {'success': true, 'message': 'Login successful'};
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  Future<void> logout() async {
    await _prefs.remove('token'); // Clear the token
    // Add any additional logout logic here if needed
  }

  Future<String?> getToken() async {
    return _prefs.getString('token');
  }
}

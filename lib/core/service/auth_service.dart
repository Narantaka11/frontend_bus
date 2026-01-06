import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(data['error'] ?? 'Login gagal');
    }

    if (!data.containsKey('token')) {
      throw Exception('Token tidak ditemukan');
    }

    return data;
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception(data['error'] ?? 'Register gagal');
    }

    if (!data.containsKey('token')) {
      throw Exception('Token tidak ditemukan');
    }

    return data;
  }
}

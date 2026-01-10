import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'session_manager.dart';

class AdminService {
  static Future<List<Map<String, dynamic>>> getBookings() async {
    final token = await SessionManager.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}admin/bookings');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data booking admin');
    }

    final data = jsonDecode(response.body);
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    } else if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getBuses() async {
    final token = await SessionManager.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}admin/buses');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) return [];
    final data = jsonDecode(response.body);
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getRoutes() async {
    final token = await SessionManager.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}admin/routes');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) return [];
    final data = jsonDecode(response.body);
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getTrips() async {
    final token = await SessionManager.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}admin/trips');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) return [];
    final data = jsonDecode(response.body);
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getUsers() async {
    final token = await SessionManager.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}admin/users');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) return [];
    final data = jsonDecode(response.body);
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}

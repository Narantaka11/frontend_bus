import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'session_manager.dart';

class AdminService {
  // ================== HEADER ==================
  static Future<Map<String, String>> _headers() async {
    final token = await SessionManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ================== BOOKINGS ==================
  static Future<List<Map<String, dynamic>>> getBookings() async {
    final url = Uri.parse('${ApiConfig.baseUrl}admin/bookings');
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data booking');
    }

    final data = jsonDecode(response.body);
    if (data is Map && data.containsKey('data')) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  static Future<void> confirmBooking(String bookingId) async {
    final url =
        Uri.parse('${ApiConfig.baseUrl}admin/bookings/$bookingId/confirm');

    final response = await http.put(url, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Gagal mengkonfirmasi booking');
    }
  }

  static Future<void> cancelBooking(String bookingId) async {
    final url =
        Uri.parse('${ApiConfig.baseUrl}admin/bookings/$bookingId/cancel');

    final response = await http.put(url, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Gagal membatalkan booking');
    }
  }

  // ================== BUSES ==================
  static Future<List<Map<String, dynamic>>> getBuses() async {
    final url = Uri.parse('${ApiConfig.baseUrl}admin/buses');
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data bus');
    }

    final data = jsonDecode(response.body);
    if (data is Map && data.containsKey('data')) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  static Future<void> createBus({
    required String name,
    required String plate,
    required int totalSeat,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}admin/buses');

    final response = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'plate': plate,
        'totalSeat': totalSeat,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Gagal menambah bus');
    }
  }

  static Future<void> updateBus(
    String id, {
    required String name,
    required String plate,
    required int totalSeat,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}admin/buses/$id');

    final response = await http.put(
      url,
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'plate': plate,
        'totalSeat': totalSeat,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengupdate bus');
    }
  }

  static Future<void> deleteBus(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}admin/buses/$id');
    final response = await http.delete(url, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus bus');
    }
  }

  // ================== ROUTES ==================
  static Future<List<Map<String, dynamic>>> getRoutes() async {
    final url = Uri.parse('${ApiConfig.baseUrl}admin/routes');
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data route');
    }

    final data = jsonDecode(response.body);
    if (data is Map && data.containsKey('data')) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }
  // ================= CREATE ROUTE =================
  static Future<void> createRoute(
    String origin,
    String destination,
    int distanceKm,
  ) async {
    final token = await SessionManager.getToken();

    final url = Uri.parse('${ApiConfig.baseUrl}admin/routes');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'origin': origin,
        'destination': destination,
        'distanceKm': distanceKm,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Gagal menambah route');
    }
  }

  // ================= UPDATE ROUTE =================
  static Future<void> updateRoute(
    String id,
    String origin,
    String destination,
    int distanceKm,
  ) async {
    final token = await SessionManager.getToken();

    final url = Uri.parse('${ApiConfig.baseUrl}admin/routes/$id');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'origin': origin,
        'destination': destination,
        'distanceKm': distanceKm,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal update route');
    }
  }

  // ================= DELETE ROUTE =================
  static Future<void> deleteRoute(String id) async {
    final token = await SessionManager.getToken();

    final url = Uri.parse('${ApiConfig.baseUrl}admin/routes/$id');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus route');
    }
  }

  // ================== TRIPS ==================
  static Future<List<Map<String, dynamic>>> getTrips() async {
    final url = Uri.parse('${ApiConfig.baseUrl}admin/trips');
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data trip');
    }

    final data = jsonDecode(response.body);
    if (data is Map && data.containsKey('data')) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getUsers() async {
    final token = await SessionManager.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}admin/users');

    final res = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal mengambil data user');
    }

    final decoded = jsonDecode(res.body);

    // ✅ SESUAI RESPONSE BACKEND
    if (decoded is Map && decoded.containsKey('users')) {
      return List<Map<String, dynamic>>.from(decoded['users']);
    }

    return [];
  }
}

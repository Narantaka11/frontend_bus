import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'session_manager.dart';

class BookingService {
  static Future<Map<String, dynamic>> createBooking({
    required String tripId,
    required List<String> seatCodes,
    required List<Map<String, dynamic>> passengers,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}booking');
    final token = await SessionManager.getToken();

    final body = jsonEncode({
      'tripId': tripId,
      'seatCodes': seatCodes,
      'passengers':
          passengers, // sending passenger info if API supports it, strictly per api.md it might just be seatIds but good to have
    });

    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to create booking: ${res.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> getUpcomingBookings() async {
    final token = await SessionManager.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Helper to fetch by status
    Future<List<Map<String, dynamic>>> fetchByStatus(String? status) async {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}booking/me',
      ).replace(queryParameters: status != null ? {'status': status} : null);

      try {
        final res = await http.get(uri, headers: headers);
        if (res.statusCode == 200) {
          final Map<String, dynamic> json = jsonDecode(res.body);
          final List<dynamic> data = json['data'] ?? [];
          return data.cast<Map<String, dynamic>>();
        }
      } catch (e) {
        debugPrint('Error fetching specific status $status: $e');
      }
      return [];
    }

    // If the backend defaults to only CONFIRMED, explicitly fetching others might be needed.
    // However, usually 'booking/me' without params returns all.
    // Given the user issue, we will try to fetch PENDING explicitly and merge.
    // Or fetch all relevant statuses.

    // Strategy: Fetch PENDING and CONFIRMED/PAID in parallel.
    final results = await Future.wait([
      fetchByStatus('PENDING'),
      fetchByStatus('PAID'),
      fetchByStatus('CONFIRMED'),
    ]);

    // Merge and deduplicate by ID
    final Map<String, Map<String, dynamic>> merged = {};
    for (var list in results) {
      for (var item in list) {
        merged[item['id']] = item;
      }
    }

    // Sort by createdAt desc if available, or just return list
    // Assuming the API returns sorted. We'll just list them.
    return merged.values.toList();
  }

  static Future<bool> cancelBooking(String bookingId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}booking/$bookingId/cancel');
    final token = await SessionManager.getToken();

    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to cancel booking: ${res.body}');
    }
  }

  static Future<Map<String, dynamic>> getBookingDetail(String bookingId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}booking/$bookingId');
    final token = await SessionManager.getToken();

    final res = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load booking detail: ${res.body}');
    }
  }

  static Future<bool> changeBookingSeat(
    String bookingId,
    List<String> newSeatCodes,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}booking/$bookingId/seat');
    final token = await SessionManager.getToken();

    final body = jsonEncode({'newSeatCodes': newSeatCodes});

    final res = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (res.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to change seats: ${res.body}');
    }
  }
}

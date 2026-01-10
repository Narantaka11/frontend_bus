import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class SeatService {
  static Future<List<Map<String, dynamic>>> getSeatsByTrip(
    String tripId,
  ) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}public/trips/$tripId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load seats');
    }

    final data = jsonDecode(response.body);

    // ⛔️ INI PENTING
    if (data == null || data['seats'] == null) {
      return [];
    }

    return List<Map<String, dynamic>>.from(
      data['seats'].map((e) => Map<String, dynamic>.from(e)),
    );
  }
}

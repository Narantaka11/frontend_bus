import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class TripService {
  static Future<List<Map<String, dynamic>>> getUpcomingTrips() async {
    final url = Uri.parse('${ApiConfig.baseUrl}public/trips');

    print('CALLING UPCOMING TRIPS: $url');

    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to load trips (${res.statusCode}): ${res.reasonPhrase}',
      );
    }

    final List data = jsonDecode(res.body);
    return data.cast<Map<String, dynamic>>();
  }
  /// Ambil trips berdasarkan route (dipakai di BusSelection)
  static Future<List<Map<String, dynamic>>> getTripsByRoute(
      String routeId, String date) async {
    final url =
        Uri.parse('${ApiConfig.baseUrl}public/trips?routeId=$routeId&date=$date');

    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception('Failed to load trips by route');
    }

    final List data = jsonDecode(res.body);
    return data.cast<Map<String, dynamic>>();
  }
}

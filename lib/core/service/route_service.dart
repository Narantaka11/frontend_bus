import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class RouteService {
  static Future<List<Map<String, dynamic>>> getPublicRoutes() async {
    final url = Uri.parse('${ApiConfig.baseUrl}public/routes');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil routes');
    }

    final List data = jsonDecode(response.body);

    return data.map<Map<String, dynamic>>((e) {
      return {
        'id': e['id'],
        'origin': e['origin'],
        'destination': e['destination'],
      };
    }).toList();
  }

  static Future<Map<String, dynamic>?> getRouteById(String id) async {
    try {
      final routes = await getPublicRoutes();
      return routes.firstWhere((r) => r['id'] == id);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getTerminals() async {
    final url = Uri.parse('${ApiConfig.baseUrl}terminals');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      return [];
    }

    final List data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'session_manager.dart';

class PaymentService {
  static Future<String?> createPayment(String bookingId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}payment/create');
    final token = await SessionManager.getToken();

    final body = jsonEncode({'bookingId': bookingId});

    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['redirect_url']; // returning redirect URL for webview or browser intent
    } else {
      throw Exception('Failed to initiate payment: ${res.body}');
    }
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _tokenKey = 'auth_token';
  static const _loginTimeKey = 'login_time';
  static const _userNameKey = 'user_name';

  static const int sessionDurationHours = 0;

  static Future<void> saveSession(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(
      _loginTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final loginTime = prefs.getInt(_loginTimeKey);

    if (token == null || loginTime == null) return null;

    final now = DateTime.now();
    final loginDate =
        DateTime.fromMillisecondsSinceEpoch(loginTime);
    final diff = now.difference(loginDate);

    if (diff.inHours >= sessionDurationHours) {
      await clearSession();
      return null;
    }

    return token;
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_loginTimeKey);
    await prefs.remove(_userNameKey);
  }
}

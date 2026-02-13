import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionStorage {
  AuthSessionStorage._();

  static const _tokenKey = 'auth.token';
  static const _userIdKey = 'auth.user_id';
  static const _nameKey = 'auth.name';
  static const _emailKey = 'auth.email';
  static const _phoneKey = 'auth.phone';

  static Future<void> save({
    required String token,
    required String userId,
    required String name,
    required String email,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_phoneKey, phone);
  }

  static Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_phoneKey);
  }
}

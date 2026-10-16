import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<bool> setString(String key, String value) async {
    await init();
    return await _prefs!.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<bool> setJson(String key, dynamic jsonVal) async {
    await init();
    return await _prefs!.setString(key, jsonEncode(jsonVal));
  }

  dynamic getJson(String key) {
    final str = getString(key);
    if (str == null || str.isEmpty) return null;
    try {
      return jsonDecode(str);
    } catch (_) {
      return null;
    }
  }

  Future<bool> remove(String key) async {
    await init();
    return await _prefs!.remove(key);
  }

  Future<bool> clear() async {
    await init();
    return await _prefs!.clear();
  }
}

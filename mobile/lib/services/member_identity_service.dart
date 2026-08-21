// lib/services/member_identity_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class MemberIdentityService {
  static const _key = 'member_display_name';

  static Future<String?> getDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> setDisplayName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, name);
  }
}
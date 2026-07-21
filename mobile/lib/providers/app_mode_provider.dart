import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppMode { unknown, pastor, member }

class AppModeNotifier extends AsyncNotifier<AppMode> {
  @override
  Future<AppMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('app_mode');
    if (saved == 'pastor') return AppMode.pastor;
    if (saved == 'member') return AppMode.member;
    return AppMode.unknown;
  }

  Future<void> setMode(AppMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_mode', mode.name);
    state = AsyncData(mode);
  }
}

final appModeProvider =
    AsyncNotifierProvider<AppModeNotifier, AppMode>(AppModeNotifier.new);
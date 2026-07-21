import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/record_setup_screen.dart';
import 'screens/sermons_preacher_list_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magombo App',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/record-setup': (context) => const RecordSetupScreen(),
        '/sermons': (context) => const SermonsPreacherListScreen(),
      },
    );
  }
}
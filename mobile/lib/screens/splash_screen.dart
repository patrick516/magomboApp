import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../providers/app_mode_provider.dart';
import '../providers/preacher_provider.dart';
import 'home_screen.dart';
import 'role_selection_screen.dart';
import 'setup_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _minTimeElapsed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _minTimeElapsed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appModeAsync = ref.watch(appModeProvider);

    if (!_minTimeElapsed || appModeAsync.isLoading) {
      return const _SplashVisual();
    }

    return appModeAsync.when(
      loading: () => const _SplashVisual(),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Something went wrong: $err')),
      ),
      data: (mode) {
        if (mode == AppMode.unknown) {
          return const RoleSelectionScreen();
        }
        if (mode == AppMode.member) {
          return const HomeScreen();
        }

        // Pastor mode — make sure a preacher profile exists on this device
        final preachersAsync = ref.watch(devicePreachersProvider);
        return preachersAsync.when(
          loading: () => const _SplashVisual(),
          error: (err, stack) => Scaffold(
            body: Center(child: Text('Something went wrong: $err')),
          ),
          data: (preachers) {
            if (preachers.isEmpty) {
              return const SetupScreen();
            }
            Future.microtask(() {
              ref.read(selectedPreacherProvider.notifier).select(preachers.first);
            });
            return const HomeScreen();
          },
        );
      },
    );
  }
}

class _SplashVisual extends StatelessWidget {
  const _SplashVisual();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.jpeg', width: 140, height: 140),
            const SizedBox(height: 24),
            const Text(
              'MAGOMBO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'NEW JERUSALEM TEMPLE',
              style: TextStyle(
                color: AppColors.accentLight,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
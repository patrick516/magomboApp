// lib/screens/coming_soon_screen.dart

import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;
  final String? message;

  const ComingSoonScreen({super.key, required this.title, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hourglass_top, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(
                message ?? '$title is coming soon.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
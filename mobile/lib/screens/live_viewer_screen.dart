// lib/screens/live_viewer_screen.dart

import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/live_session.dart';

class LiveViewerScreen extends StatelessWidget {
  final LiveSession session;

  const LiveViewerScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Service')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFF2B2B2B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_circle_outline, color: Colors.white54, size: 32),
                        SizedBox(height: 8),
                        Text(
                          'This will show the live broadcast\nonce Facebook streaming is connected.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              session.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              [session.preacherName, session.preacherPosition]
                  .where((s) => s != null && s.isNotEmpty)
                  .join(' · '),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
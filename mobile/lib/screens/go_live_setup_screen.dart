// lib/screens/go_live_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../providers/preacher_provider.dart';
import '../providers/live_session_provider.dart';
import 'live_broadcast_screen.dart';

class GoLiveSetupScreen extends ConsumerStatefulWidget {
  const GoLiveSetupScreen({super.key});

  @override
  ConsumerState<GoLiveSetupScreen> createState() => _GoLiveSetupScreenState();
}

class _GoLiveSetupScreenState extends ConsumerState<GoLiveSetupScreen> {
  final _titleController = TextEditingController();
  bool _starting = false;
  String? _error;

  Future<void> _startLive() async {
    final preacher = ref.read(selectedPreacherProvider);
    if (preacher == null) {
      setState(() => _error = 'Select a preacher profile first.');
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      setState(() => _error = 'Enter what you\'ll be preaching on.');
      return;
    }

    setState(() {
      _starting = true;
      _error = null;
    });

    try {
      await ref.read(pastorLiveProvider.notifier).goLive(
            preacherId: preacher.id,
            title: _titleController.text.trim(),
          );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LiveBroadcastScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Could not start live session. Check your connection.';
        _starting = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Go Live')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_error!, style: const TextStyle(color: AppColors.error)),
              ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'What are you preaching on today?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Members will see this appear as "Live Now" the moment you go live.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _starting ? null : _startLive,
              icon: _starting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.videocam),
              label: Text(_starting ? 'Starting...' : 'Go Live Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
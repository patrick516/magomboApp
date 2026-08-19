// lib/screens/live_broadcast_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../providers/live_session_provider.dart';

class LiveBroadcastScreen extends ConsumerStatefulWidget {
  const LiveBroadcastScreen({super.key});

  @override
  ConsumerState<LiveBroadcastScreen> createState() => _LiveBroadcastScreenState();
}

class _LiveBroadcastScreenState extends ConsumerState<LiveBroadcastScreen> {
  bool _ending = false;

  Future<void> _endLive() async {
    setState(() => _ending = true);
    try {
      await ref.read(pastorLiveProvider.notifier).endLive();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _ending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not end the live session. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(pastorLiveProvider);

    return PopScope(
      canPop: false, // avoid accidentally leaving a live session running
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
              ),
              const Text('LIVE'),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
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
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam_outlined, color: Colors.white54, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Camera preview will appear here\nonce Facebook streaming is connected',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                session?.title ?? 'Live session',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _ending ? null : _endLive,
                icon: _ending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.stop_circle_outlined),
                label: Text(_ending ? 'Ending...' : 'End Live'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
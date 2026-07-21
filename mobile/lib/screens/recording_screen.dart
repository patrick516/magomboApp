import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../config/app_colors.dart';
import '../models/preaching.dart';
import '../repositories/preaching_repository.dart';

final preachingRepositoryProvider = Provider((ref) => PreachingRepository());

class RecordingScreen extends ConsumerStatefulWidget {
  final String sermonId;
  final String sermonTheme;

  const RecordingScreen({
    super.key,
    required this.sermonId,
    required this.sermonTheme,
  });

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen> {
  final _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _saving = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required.')),
      );
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${const Uuid().v4()}.m4a';
    final filePath = '${dir.path}/$fileName';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: filePath,
    );

   setState(() {
      _isRecording = true;
      _elapsed = Duration.zero;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    _timer?.cancel();
    setState(() => _isRecording = false);

    if (path == null) return;

    setState(() => _saving = true);

    final repo = ref.read(preachingRepositoryProvider);
    final nextPart = await repo.getNextPartNumber(widget.sermonId);

    final preaching = Preaching(
      id: const Uuid().v4(),
      sermonId: widget.sermonId,
      partNumber: nextPart,
      dateRecorded: DateTime.now().toIso8601String(),
      durationSeconds: _elapsed.inSeconds,
      localFilePath: path,
      createdAt: DateTime.now().toIso8601String(),
    );

    await repo.insert(preaching);

    if (!mounted) return;

    setState(() => _saving = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Recording Saved'),
        content: Text(
          'Part $nextPart of "${widget.sermonTheme}" saved '
          '(${_formatDuration(_elapsed)}). It will sync automatically '
          'when internet is available.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context)
                ..pop() // close recording screen
                ..pop(); // close record-setup screen, back to home
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.sermonTheme)),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatDuration(_elapsed),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isRecording ? 'Recording...' : 'Ready to record',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),
              _saving
                  ? const CircularProgressIndicator(color: AppColors.accent)
                  : GestureDetector(
                      onTap: _isRecording ? _stopRecording : _startRecording,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording
                              ? AppColors.error
                              : AppColors.accent,
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
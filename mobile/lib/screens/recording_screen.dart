import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../config/app_colors.dart';
import '../models/preaching.dart';
import '../repositories/preaching_repository.dart';
import 'package:logger/logger.dart' show Level;

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
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _recorderReady = false;
  bool _isRecording = false;
  bool _saving = false;
  bool _starting = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  String? _currentFilePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

 Future<void> _initRecorder() async {
    await _recorder.openRecorder();
    _recorder.setLogLevel(Level.error); // quiet down verbose internal logs (no await needed)
    _recorderReady = true;
    debugPrint('>>> Recorder opened successfully <<<');
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_recorderReady) {
      _recorder.closeRecorder();
    }
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_starting) return;
    _starting = true;
    debugPrint('>>> _startRecording called <<<');

    try {
      var status = await Permission.microphone.status;
      debugPrint('Mic permission status: $status');

      if (status.isDenied) {
        status = await Permission.microphone.request();
      }

      if (status.isPermanentlyDenied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Microphone permission denied. Enable it in Settings.'),
            action: SnackBarAction(label: 'Open Settings', onPressed: openAppSettings),
          ),
        );
        return;
      }

      if (!status.isGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required.')),
        );
        return;
      }

      if (!_recorderReady) {
        await _initRecorder();
      }

      final dir = await getApplicationDocumentsDirectory();
      final fileName = '${const Uuid().v4()}.aac';
      final filePath = '${dir.path}/$fileName';
      _currentFilePath = filePath;
      debugPrint('Recording to: $filePath');

      await _recorder.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
      );
      debugPrint('>>> startRecorder returned successfully <<<');

      setState(() {
        _isRecording = true;
        _elapsed = Duration.zero;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsed += const Duration(seconds: 1));
      });
    } catch (e, stack) {
      debugPrint('Recording start failed: $e\n$stack');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start recording: $e')),
      );
    } finally {
      _starting = false;
    }
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    _timer?.cancel();
    setState(() => _isRecording = false);

    final path = _currentFilePath;
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
                ..pop()
                ..pop();
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
                  : Material(
                      color: _isRecording ? AppColors.error : AppColors.accent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          _isRecording ? _stopRecording() : _startRecording();
                        },
                        child: SizedBox(
                          width: 96,
                          height: 96,
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 40,
                          ),
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
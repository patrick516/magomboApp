import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../config/app_colors.dart';
import '../models/preaching.dart';
import '../services/api/preaching_api.dart';

class SermonPlayerScreen extends StatefulWidget {
  final String sermonId;
  final String sermonTheme;
  final List<Preaching> parts;
  final int initialIndex;

  const SermonPlayerScreen({
    super.key,
    required this.sermonId,
    required this.sermonTheme,
    required this.parts,
    required this.initialIndex,
  });

  @override
  State<SermonPlayerScreen> createState() => _SermonPlayerScreenState();
}

class _SermonPlayerScreenState extends State<SermonPlayerScreen> {
  final _player = AudioPlayer();
  final _api = PreachingApi();
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadAndPlay();
  }

  Preaching get _currentPart => widget.parts[_currentIndex];

 bool _loadError = false;

  Future<void> _loadAndPlay() async {
    setState(() => _loadError = false);
    try {
     final localPath = _currentPart.localFilePath;
      if (localPath != null && localPath.isNotEmpty) {
        // Prefer local file — plays instantly, works even offline/unsynced
        await _player.setFilePath(localPath);
      } else {
        final signedUrl = await _api.getSignedAudioUrl(_currentPart.id);
        await _player.setUrl(signedUrl);
      }
      await _player.play();
      // Only report play count to server if this part is actually synced
      if (_currentPart.synced) {
        _api.incrementPlayCount(_currentPart.id).catchError((_) {});
      }
    } catch (e) {
      // If the player is already actively playing despite this exception,
      // it was a non-fatal hiccup (e.g. duration probing) — don't show an
      // error for something that's actually working.
      final alreadyPlaying = _player.playing;
      if (!alreadyPlaying) {
        setState(() => _loadError = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not play audio: $e')),
          );
        }
      }
    }
  }

  void _playNext() {
    if (_currentIndex < widget.parts.length - 1) {
      setState(() => _currentIndex++);
      _loadAndPlay();
    }
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _loadAndPlay();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration? d) {
    if (d == null) return '00:00';
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.sermonTheme)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             Text(
                'Part ${_currentPart.partNumber} of ${widget.parts.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              if (!_currentPart.synced) ...[
                const SizedBox(height: 4),
                const Text(
                  'Playing local copy (not yet synced)',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
              StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final isActuallyPlaying = snapshot.data?.playing ?? false;

                  // If real playback is happening, the earlier error was
                  // stale/non-fatal — clear it so the UI reflects reality.
                  if (isActuallyPlaying && _loadError) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _loadError = false);
                    });
                  }

                  if (_loadError && !isActuallyPlaying) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Audio could not be loaded.',
                        style: TextStyle(fontSize: 13, color: AppColors.error),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 40),

              StreamBuilder<Duration?>(
                stream: _player.durationStream,
                builder: (context, durationSnapshot) {
                  final duration = durationSnapshot.data ?? Duration.zero;
                  return StreamBuilder<Duration>(
                    stream: _player.positionStream,
                    builder: (context, positionSnapshot) {
                      final position = positionSnapshot.data ?? Duration.zero;
                      return Column(
                        children: [
                          Slider(
                            value: position.inSeconds
                                .toDouble()
                                .clamp(0, duration.inSeconds.toDouble()),
                            max: duration.inSeconds.toDouble() > 0
                                ? duration.inSeconds.toDouble()
                                : 1,
                            activeColor: AppColors.accent,
                            onChanged: (value) {
                              _player.seek(Duration(seconds: value.toInt()));
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDuration(position)),
                                Text(_formatDuration(duration)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _currentIndex > 0 ? _playPrevious : null,
                    icon: const Icon(Icons.skip_previous, size: 32),
                  ),
                  IconButton(
                    onPressed: () {
                      final pos = _player.position - const Duration(seconds: 15);
                      _player.seek(pos < Duration.zero ? Duration.zero : pos);
                    },
                    icon: const Icon(Icons.replay_10, size: 28),
                  ),
                  const SizedBox(width: 8),
                  StreamBuilder<PlayerState>(
                    stream: _player.playerStateStream,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      return Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent,
                        ),
                        child: IconButton(
                          iconSize: 40,
                          color: Colors.white,
                          onPressed: () {
                            playing ? _player.pause() : _player.play();
                          },
                          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      _player.seek(_player.position + const Duration(seconds: 15));
                    },
                    icon: const Icon(Icons.forward_10, size: 28),
                  ),
                  IconButton(
                    onPressed: _currentIndex < widget.parts.length - 1 ? _playNext : null,
                    icon: const Icon(Icons.skip_next, size: 32),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
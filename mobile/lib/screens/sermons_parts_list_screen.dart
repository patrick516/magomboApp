import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../providers/sermon_browse_provider.dart';
import 'sermon_player_screen.dart';

class SermonsPartsListScreen extends ConsumerWidget {
  final String sermonId;
  final String sermonTheme;

  const SermonsPartsListScreen({
    super.key,
    required this.sermonId,
    required this.sermonTheme,
  });

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partsAsync = ref.watch(partsBySermonProvider(sermonId));

    return Scaffold(
      appBar: AppBar(title: Text(sermonTheme)),
      body: partsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (parts) {
          if (parts.isEmpty) {
            return const Center(
              child: Text(
                'No parts available yet.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
         // Display newest part first, but keep the underlying `parts` list
          // in correct Part 1→2→3 order so the player's next/previous
          // buttons still move chronologically.
          final displayOrder = List.generate(parts.length, (i) => i).reversed.toList();

          return ListView.builder(
            itemCount: parts.length,
            itemBuilder: (context, i) {
              final index = displayOrder[i]; // actual index into `parts`
             final part = parts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.accent,
                  child: Text(
                    '${part.partNumber}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text('Part ${part.partNumber}'),
                subtitle: Text(_formatDuration(part.durationSeconds)),
                trailing: const Icon(Icons.play_circle_outline, color: AppColors.primary),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SermonPlayerScreen(
                        sermonId: sermonId,
                        sermonTheme: sermonTheme,
                        parts: parts,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
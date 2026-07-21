import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../config/app_colors.dart';
import '../models/sermon.dart';
import '../providers/preacher_provider.dart';
import '../repositories/sermon_repository.dart';
import 'recording_screen.dart';

final sermonRepositoryProvider = Provider((ref) => SermonRepository());

final preacherSermonsProvider =
    FutureProvider.family<List<Sermon>, String>((ref, preacherId) async {
  final repo = ref.read(sermonRepositoryProvider);
  return repo.getByPreacher(preacherId);
});

class RecordSetupScreen extends ConsumerWidget {
  const RecordSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preacher = ref.watch(selectedPreacherProvider);

    if (preacher == null) {
      return const Scaffold(
        body: Center(child: Text('No preacher selected.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Start Recording')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Preaching as ${preacher.name}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // New theme
              ElevatedButton.icon(
                onPressed: () => _promptNewTheme(context, ref, preacher.id),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('New Theme'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Or continue an existing theme:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    final sermonsAsync =
                        ref.watch(preacherSermonsProvider(preacher.id));

                    return sermonsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Text('Error: $err'),
                      data: (sermons) {
                        if (sermons.isEmpty) {
                          return const Center(
                            child: Text(
                              'No existing themes yet.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: sermons.length,
                          itemBuilder: (context, index) {
                            final sermon = sermons[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(
                                  Icons.menu_book,
                                  color: AppColors.primary,
                                ),
                                title: Text(sermon.theme),
                                subtitle: sermon.series != null
                                    ? Text(sermon.series!)
                                    : null,
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RecordingScreen(
                                        sermonId: sermon.id,
                                        sermonTheme: sermon.theme,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _promptNewTheme(BuildContext context, WidgetRef ref, String preacherId) {
    final themeController = TextEditingController();
    final seriesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Sermon Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: themeController,
              decoration: const InputDecoration(
                labelText: 'Theme of Today\'s Sermon',
                hintText: 'e.g. Faith That Moves Mountains',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: seriesController,
              decoration: const InputDecoration(
                labelText: 'Series (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final theme = themeController.text.trim();
              if (theme.isEmpty) return;

              final sermon = Sermon(
                id: const Uuid().v4(),
                preacherId: preacherId,
                theme: theme,
                series: seriesController.text.trim().isEmpty
                    ? null
                    : seriesController.text.trim(),
                createdAt: DateTime.now().toIso8601String(),
              );

              final repo = ref.read(sermonRepositoryProvider);
              await repo.insert(sermon);
              ref.invalidate(preacherSermonsProvider(preacherId));

           if (dialogContext.mounted) Navigator.pop(dialogContext);

              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecordingScreen(
                      sermonId: sermon.id,
                      sermonTheme: sermon.theme,
                    ),
                  ),
                );
              }
            },
            child: const Text('Create & Continue'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../providers/sermon_browse_provider.dart';
import 'sermons_theme_list_screen.dart';

class SermonsPreacherListScreen extends ConsumerWidget {
  const SermonsPreacherListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preachersAsync = ref.watch(allPreachersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('View Sermons')),
      body: preachersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (preachers) {
          if (preachers.isEmpty) {
            return const Center(
              child: Text(
                'No sermons available yet.\nTap Sync on the home screen.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return ListView.builder(
            itemCount: preachers.length,
            itemBuilder: (context, index) {
              final preacher = preachers[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(preacher.name),
                subtitle: Text(preacher.position ?? ''),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SermonsThemeListScreen(
                        preacherId: preacher.id,
                        preacherName: preacher.name,
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
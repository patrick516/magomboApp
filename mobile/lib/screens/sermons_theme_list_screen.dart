import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../providers/sermon_browse_provider.dart';
import 'sermons_parts_list_screen.dart';

class SermonsThemeListScreen extends ConsumerWidget {
  final String preacherId;
  final String preacherName;

  const SermonsThemeListScreen({
    super.key,
    required this.preacherId,
    required this.preacherName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sermonsAsync = ref.watch(sermonsByPreacherProvider(preacherId));

    return Scaffold(
      appBar: AppBar(title: Text(preacherName)),
      body: sermonsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (sermons) {
          if (sermons.isEmpty) {
            return const Center(
              child: Text(
                'No sermons yet.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return ListView.builder(
            itemCount: sermons.length,
            itemBuilder: (context, index) {
              final sermon = sermons[index];
              return ListTile(
                leading: const Icon(Icons.menu_book, color: AppColors.primary),
                title: Text(sermon.theme),
                subtitle: sermon.series != null ? Text(sermon.series!) : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SermonsPartsListScreen(
                        sermonId: sermon.id,
                        sermonTheme: sermon.theme,
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
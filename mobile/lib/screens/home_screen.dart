import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../providers/app_mode_provider.dart';
import '../providers/preacher_provider.dart';
import '../providers/sync_provider.dart';
import '../widgets/preacher_picker_sheet.dart';
import 'setup_screen.dart';
import 'donation_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appModeAsync = ref.watch(appModeProvider);
    final isPastor = appModeAsync.value == AppMode.pastor;
    final selectedPreacher = ref.watch(selectedPreacherProvider);
    final syncState = ref.watch(syncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Magombo App'),
        actions: [
          IconButton(
            onPressed: syncState == SyncState.syncing
                ? null
                : () => ref.read(syncProvider.notifier).sync(),
            icon: _buildSyncIcon(syncState),
            tooltip: 'Sync now',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (syncState == SyncState.syncing)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(color: AppColors.accent),
                ),
              if (syncState == SyncState.failure)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.error),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sync failed. Tap sync to try again.',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              if (syncState == SyncState.success)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Synced successfully',
                        style: TextStyle(color: AppColors.success),
                      ),
                    ],
                  ),
                ),
              if (isPastor) ...[
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      selectedPreacher?.name ?? 'No profile selected',
                    ),
                    subtitle: Text(selectedPreacher?.position ?? ''),
                    trailing: TextButton(
                      onPressed: () => showPreacherPicker(context, ref),
                      child: const Text('Switch'),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/record-setup'),
                  icon: const Icon(Icons.mic),
                  label: const Text('Start Recording'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/sermons'),
                icon: const Icon(Icons.library_music),
                label: const Text('View Sermons'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
              if (!isPastor) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DonationScreen()),
                  ),
                  icon: const Icon(Icons.favorite),
                  label: const Text('Donate'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SetupScreen()),
                      );
                    },
                    child: const Text(
                      'Are you a preacher? Register here',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncIcon(SyncState state) {
    switch (state) {
      case SyncState.syncing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        );
      case SyncState.success:
        return const Icon(Icons.cloud_done, color: Colors.white);
      case SyncState.failure:
        return const Icon(Icons.cloud_off, color: Colors.white);
      case SyncState.idle:
        return const Icon(Icons.sync, color: Colors.white);
    }
  }
}

// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../providers/app_mode_provider.dart';
import '../providers/preacher_provider.dart';
import '../providers/preacher_stats_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/live_session_provider.dart';
import '../widgets/preacher_picker_sheet.dart';
import 'setup_screen.dart';
import 'donation_screen.dart';
import 'coming_soon_screen.dart';
import 'sermons_theme_list_screen.dart';
import 'go_live_setup_screen.dart';
import 'live_viewer_screen.dart';
import 'announcements_screen.dart';
import 'small_groups_screen.dart';
import 'prayer_request_screen.dart';
import 'testimonies_screen.dart';

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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ComingSoonScreen(title: 'Notifications'),
              ),
            ),
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            tooltip: 'Notifications',
          ),
          IconButton(
            onPressed: syncState == SyncState.syncing
                ? null
                : () => ref.read(syncProvider.notifier).sync(),
            icon: _buildSyncIcon(syncState),
            tooltip: 'Sync now',
          ),
        ],
        bottom: isPastor
            ? PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.accent,
                        child: Icon(Icons.person, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedPreacher?.name ?? 'No profile selected',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              selectedPreacher?.position ?? '',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => showPreacherPicker(context, ref),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          side: const BorderSide(color: AppColors.accent),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text('Switch'),
                      ),
                    ],
                  ),
                ),
              )
            : null,
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
                        child: Text('Sync failed. Tap sync to try again.', style: TextStyle(color: AppColors.error)),
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
                      Icon(Icons.check_circle_outline, color: AppColors.success),
                      SizedBox(width: 8),
                      Text('Synced successfully', style: TextStyle(color: AppColors.success)),
                    ],
                  ),
                ),

              if (isPastor) ...[
                if (selectedPreacher != null) _StatsRow(preacherId: selectedPreacher.id),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.mic,
                        label: 'Start Recording',
                        color: AppColors.accent,
                        onTap: () => Navigator.pushNamed(context, '/record-setup'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.videocam,
                        label: 'Go Live',
                        color: AppColors.error,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GoLiveSetupScreen()),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionLabel('MANAGE'),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.6,
                  children: [
                    _ManageTile(
                      icon: Icons.library_music_outlined,
                      label: 'My Sermons',
                      onTap: selectedPreacher == null
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SermonsThemeListScreen(
                                    preacherId: selectedPreacher.id,
                                    preacherName: selectedPreacher.name,
                                  ),
                                ),
                              ),
                    ),
                                        _ManageTile(
                      icon: Icons.campaign_outlined,
                      label: 'Announcements',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
                      ),
                    ),
                    _ManageTile(
                      icon: Icons.volunteer_activism_outlined,
                      label: 'Prayer Requests',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ComingSoonScreen(title: 'Prayer Requests')),
                      ),
                    ),
                    _ManageTile(
                      icon: Icons.insights_outlined,
                      label: 'Insights',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ComingSoonScreen(title: 'Insights')),
                      ),
                    ),
                  ],
                ),
              ],

              if (!isPastor) ...[
                const _LiveNowBanner(),
                Row(
                  children: [
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.library_music,
                        label: 'View Sermons',
                        color: AppColors.accent,
                        onTap: () => Navigator.pushNamed(context, '/sermons'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.favorite,
                        label: 'Donate',
                        color: AppColors.success,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DonationScreen()),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionLabel('EXPLORE'),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.6,
                  children: [
                    _ManageTile(
                      icon: Icons.campaign_outlined,
                      label: 'Announcements',
                                           onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
                      ),
                    ),
                                       _ManageTile(
                      icon: Icons.volunteer_activism_outlined,
                      label: 'Prayer Request',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PrayerRequestScreen()),
                      ),
                    ),
                    _ManageTile(
                      icon: Icons.chat_bubble_outline,
                      label: 'Testimonies',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TestimoniesScreen()),
                      ),
                    ),
                    _ManageTile(
                      icon: Icons.groups_outlined,
                      label: 'Small Groups',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SmallGroupsScreen()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupScreen()));
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

class _LiveNowBanner extends ConsumerWidget {
  const _LiveNowBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(currentLiveSessionProvider);

    return sessionAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (session) {
        if (session == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LiveViewerScreen(session: session)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'LIVE NOW',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            session.preacherName != null
                                ? '${session.preacherName} is preaching'
                                : session.title,
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: AppColors.textSecondary),
    );
  }
}

class _StatsRow extends ConsumerWidget {
  final String preacherId;
  const _StatsRow({required this.preacherId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(preacherStatsProvider(preacherId));

    return statsAsync.when(
      loading: () => const SizedBox(height: 64, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) => Row(
        children: [
          Expanded(child: _StatCard(value: '${stats.sermonCount}', label: 'Sermons')),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(value: '${stats.partCount}', label: 'Parts')),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(value: '${stats.totalPlays}', label: 'Listens')),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(height: 6),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManageTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ManageTile({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD8D3C4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}
// lib/screens/announcements_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../providers/app_mode_provider.dart';
import '../providers/content_provider.dart';
import '../utils/date_format.dart';
import 'post_announcement_screen.dart';

class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsProvider);
    final isPastor = ref.watch(appModeProvider).value == AppMode.pastor;

    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      floatingActionButton: isPastor
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.accent,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Post', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PostAnnouncementScreen()),
                );
                ref.invalidate(announcementsProvider);
              },
            )
          : null,
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () async {
          ref.invalidate(announcementsProvider);
          await ref.read(announcementsProvider.future);
        },
        child: announcementsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => ListView(
            children: [
              const SizedBox(height: 200),
              Center(child: Text('Could not load announcements.\n$err', textAlign: TextAlign.center)),
            ],
          ),
          data: (announcements) {
            if (announcements.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Text(
                      'No announcements yet.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: announcements.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final a = announcements[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD8D3C4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              a.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          if (a.eventDate != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                formatSimpleDate(a.eventDate!),
                                style: const TextStyle(fontSize: 10, color: AppColors.accent, fontWeight: FontWeight.w600),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(a.body, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Text(
                        a.preacherName != null
                            ? 'Posted by ${a.preacherName} · ${formatSimpleDate(a.createdAt)}'
                            : formatSimpleDate(a.createdAt),
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
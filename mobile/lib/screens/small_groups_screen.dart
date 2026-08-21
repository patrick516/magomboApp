// lib/screens/small_groups_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../providers/content_provider.dart';
import 'group_detail_screen.dart';

class SmallGroupsScreen extends ConsumerWidget {
  const SmallGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(smallGroupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Small Groups')),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () async {
          ref.invalidate(smallGroupsProvider);
          await ref.read(smallGroupsProvider.future);
        },
        child: groupsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => ListView(
            children: [
              const SizedBox(height: 200),
              Center(child: Text('Could not load small groups.\n$err', textAlign: TextAlign.center)),
            ],
          ),
          data: (groups) {
            if (groups.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Text(
                      'No small groups listed yet.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final g = groups[index];
                final meeting = [g.meetingDay, g.meetingTime]
                    .where((s) => s != null && s.isNotEmpty)
                    .join(' · ');

                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GroupDetailScreen(groupId: g.id)),
                  ),
                  child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD8D3C4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        g.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary),
                      ),
                      if (g.description != null && g.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(g.description!, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                      ],
                      const SizedBox(height: 8),
                      if (meeting.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 13, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(meeting, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      if (g.location != null && g.location!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.place_outlined, size: 13, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(g.location!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      if (g.leaderName != null && g.leaderName!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline, size: 13, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text('Led by ${g.leaderName}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                    ],
                  ),
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
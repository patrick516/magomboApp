// lib/screens/testimonies_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../providers/content_provider.dart';
import 'testimony_submit_screen.dart';

class TestimoniesScreen extends ConsumerWidget {
  const TestimoniesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testimoniesAsync = ref.watch(testimoniesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Testimonies')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Share Yours', style: TextStyle(color: Colors.white)),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TestimonySubmitScreen()),
          );
          ref.invalidate(testimoniesProvider);
        },
      ),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () async {
          ref.invalidate(testimoniesProvider);
          await ref.read(testimoniesProvider.future);
        },
        child: testimoniesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => ListView(
            children: [
              const SizedBox(height: 200),
              Center(child: Text('Could not load testimonies.\n$err', textAlign: TextAlign.center)),
            ],
          ),
          data: (testimonies) {
            if (testimonies.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'No testimonies shared yet. Be the first!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: testimonies.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final t = testimonies[index];
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
                      Text(t.message, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Text(
                        t.isAnonymous || t.authorName == null || t.authorName!.isEmpty
                            ? '— Anonymous'
                            : '— ${t.authorName}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../config/app_colors.dart';
import '../models/preacher.dart';
import '../providers/preacher_provider.dart';
import '../services/device_service.dart';

void showPreacherPicker(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _PreacherPickerContent(),
  );
}

class _PreacherPickerContent extends ConsumerWidget {
  const _PreacherPickerContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preachersAsync = ref.watch(devicePreachersProvider);
    final selected = ref.watch(selectedPreacherProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Who is preaching?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            preachersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err'),
              data: (preachers) => Column(
                children: preachers.map((preacher) {
                  final isSelected = preacher.id == selected?.id;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          isSelected ? AppColors.accent : AppColors.primary,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(preacher.name),
                    subtitle: preacher.position != null
                        ? Text(preacher.position!)
                        : null,
                    trailing:
                        isSelected ? const Icon(Icons.check_circle, color: AppColors.accent) : null,
                    onTap: () {
                      ref.read(selectedPreacherProvider.notifier).select(preacher);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add, color: AppColors.primary),
              title: const Text('Add another preacher'),
              onTap: () {
                Navigator.pop(context);
                _showAddPreacherDialog(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPreacherDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final positionController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Preacher'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: positionController,
              decoration: const InputDecoration(labelText: 'Position (optional)'),
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
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              final deviceId = await DeviceService.getDeviceId();
              final preacher = Preacher(
                id: const Uuid().v4(),
                deviceId: deviceId,
                name: name,
                position: positionController.text.trim().isEmpty
                    ? null
                    : positionController.text.trim(),
                createdAt: DateTime.now().toIso8601String(),
              );

              final repo = ref.read(preacherRepositoryProvider);
              await repo.insert(preacher);
              ref.read(selectedPreacherProvider.notifier).select(preacher);
              ref.invalidate(devicePreachersProvider);

              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
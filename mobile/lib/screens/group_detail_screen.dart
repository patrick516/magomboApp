// lib/screens/group_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../models/group_post.dart';
import '../providers/group_detail_provider.dart';
import '../services/api/small_group_api.dart';
import '../services/api/group_post_api.dart';
import '../services/device_service.dart';
import '../services/member_identity_service.dart';
import '../utils/date_format.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  final _groupApi = SmallGroupApi();
  final _postApi = GroupPostApi();
  final _messageController = TextEditingController();

  bool _busy = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<String?> _promptForName() async {
    final existing = await MemberIdentityService.getDisplayName();
    final controller = TextEditingController(text: existing ?? '');

    if (!mounted) return null;
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g. Grace Phiri'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      await MemberIdentityService.setDisplayName(name);
      return name;
    }
    return null;
  }

  Future<void> _toggleMembership(bool currentlyMember) async {
    setState(() => _busy = true);
    try {
      final deviceId = await DeviceService.getDeviceId();

      if (currentlyMember) {
        await _groupApi.leaveGroup(widget.groupId, deviceId: deviceId);
      } else {
        final name = await _promptForName();
        if (name == null) {
          setState(() => _busy = false);
          return;
        }
        await _groupApi.joinGroup(widget.groupId, deviceId: deviceId, memberName: name);
      }
      ref.invalidate(groupDetailProvider(widget.groupId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitPost() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => _busy = true);
    try {
      final deviceId = await DeviceService.getDeviceId();
      var name = await MemberIdentityService.getDisplayName();
      name ??= await _promptForName();
      if (name == null) {
        setState(() => _busy = false);
        return;
      }

      await _postApi.createPost(widget.groupId, deviceId: deviceId, authorName: name, message: message);
      _messageController.clear();
      ref.invalidate(groupPostsProvider(widget.groupId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not post. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addComment(String postId) async {
    final controller = TextEditingController();
    final message = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Write a comment...'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: AppColors.accent),
              onPressed: () => Navigator.pop(context, controller.text.trim()),
            ),
          ],
        ),
      ),
    );

    if (message == null || message.isEmpty) return;

    try {
      final deviceId = await DeviceService.getDeviceId();
      var name = await MemberIdentityService.getDisplayName();
      name ??= await _promptForName();
      if (name == null) return;

      await _postApi.createComment(widget.groupId, postId, deviceId: deviceId, authorName: name, message: message);
      ref.invalidate(groupPostsProvider(widget.groupId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not add comment. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(groupDetailProvider(widget.groupId));
    final postsAsync = ref.watch(groupPostsProvider(widget.groupId));

    return Scaffold(
      appBar: AppBar(title: const Text('Small Group')),
      body: groupAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Could not load this group.\n$err', textAlign: TextAlign.center)),
        data: (group) => Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  if (group.description != null && group.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(group.description!, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      if (group.meetingDay != null || group.meetingTime != null)
                        _InfoChip(icon: Icons.schedule, text: [group.meetingDay, group.meetingTime].where((s) => s != null).join(' · ')),
                      if (group.location != null && group.location!.isNotEmpty)
                        _InfoChip(icon: Icons.place_outlined, text: group.location!),
                      if (group.leaderName != null && group.leaderName!.isNotEmpty)
                        _InfoChip(icon: Icons.person_outline, text: 'Led by ${group.leaderName}'),
                      _InfoChip(icon: Icons.people_outline, text: '${group.memberCount} members'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _busy ? null : () => _toggleMembership(group.isMember),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: group.isMember ? AppColors.error : AppColors.accent,
                        side: BorderSide(color: group.isMember ? AppColors.error : AppColors.accent),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(group.isMember ? 'Leave Group' : 'Join Group'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: postsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Could not load posts.\n$err')),
                data: (posts) {
                  if (posts.isEmpty) {
                    return const Center(
                      child: Text('No posts yet. Be the first to say hello!', style: TextStyle(color: AppColors.textSecondary)),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: posts.length,
                    itemBuilder: (context, index) => _PostCard(
                      post: posts[index],
                      onAddComment: () => _addComment(posts[index].id),
                    ),
                  );
                },
              ),
            ),
            if (group.isMember)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Share something with the group...',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _busy ? null : _submitPost,
                      icon: const Icon(Icons.send, color: AppColors.accent),
                    ),
                  ],
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Join the group to post and comment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  final GroupPost post;
  final VoidCallback onAddComment;
  const _PostCard({required this.post, required this.onAddComment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
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
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primary,
                child: Text(
                  post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.primary)),
              ),
              Text(formatSimpleDate(post.createdAt), style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(post.message, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          if (post.comments.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...post.comments.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                      children: [
                        TextSpan(text: '${c.authorName}: ', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                        TextSpan(text: c.message),
                      ],
                    ),
                  ),
                )),
          ],
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onAddComment,
            child: const Text('Reply', style: TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
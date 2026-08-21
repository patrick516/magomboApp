// lib/models/group_post.dart

import 'group_comment.dart';

class GroupPost {
  final String id;
  final String authorName;
  final String message;
  final String createdAt;
  final List<GroupComment> comments;

  GroupPost({
    required this.id,
    required this.authorName,
    required this.message,
    required this.createdAt,
    this.comments = const [],
  });

  factory GroupPost.fromJson(Map<String, dynamic> json) => GroupPost(
        id: json['id'] as String,
        authorName: json['authorName'] as String,
        message: json['message'] as String,
        createdAt: json['createdAt'] as String,
        comments: (json['comments'] as List? ?? [])
            .map((c) => GroupComment.fromJson(c))
            .toList(),
      );
}
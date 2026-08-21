// lib/models/group_comment.dart

class GroupComment {
  final String id;
  final String authorName;
  final String message;
  final String createdAt;

  GroupComment({
    required this.id,
    required this.authorName,
    required this.message,
    required this.createdAt,
  });

  factory GroupComment.fromJson(Map<String, dynamic> json) => GroupComment(
        id: json['id'] as String,
        authorName: json['authorName'] as String,
        message: json['message'] as String,
        createdAt: json['createdAt'] as String,
      );
}
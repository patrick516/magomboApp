// lib/models/testimony.dart

class Testimony {
  final String? id;
  final String? authorName;
  final bool isAnonymous;
  final String message;
  final String? createdAt;
  final String? deviceId;

  Testimony({
    this.id,
    this.authorName,
    this.isAnonymous = false,
    required this.message,
    this.createdAt,
    this.deviceId,
  });

  Map<String, dynamic> toJson() => {
        'message': message,
        'authorName': isAnonymous ? null : authorName,
        'isAnonymous': isAnonymous,
        'deviceId': deviceId,
      };

  factory Testimony.fromJson(Map<String, dynamic> json) => Testimony(
        id: json['id'] as String,
        authorName: json['authorName'] as String?,
        isAnonymous: json['isAnonymous'] as bool? ?? false,
        message: json['message'] as String,
        createdAt: json['createdAt'] as String?,
      );
}
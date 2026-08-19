// lib/models/announcement.dart

class Announcement {
  final String id;
  final String? preacherName;
  final String title;
  final String body;
  final String? eventDate;
  final String createdAt;

  Announcement({
    required this.id,
    this.preacherName,
    required this.title,
    required this.body,
    this.eventDate,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
        id: json['id'] as String,
        preacherName: json['preacher']?['name'] as String?,
        title: json['title'] as String,
        body: json['body'] as String,
        eventDate: json['eventDate'] as String?,
        createdAt: json['createdAt'] as String,
      );
}
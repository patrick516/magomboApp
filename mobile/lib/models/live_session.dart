// lib/models/live_session.dart

class LiveSession {
  final String id;
  final String preacherId;
  final String? preacherName;
  final String? preacherPosition;
  final String title;
  final String status; // 'LIVE' | 'ENDED'
  final String? streamUrl;
  final String startedAt;
  final String? endedAt;

  LiveSession({
    required this.id,
    required this.preacherId,
    this.preacherName,
    this.preacherPosition,
    required this.title,
    required this.status,
    this.streamUrl,
    required this.startedAt,
    this.endedAt,
  });

  factory LiveSession.fromJson(Map<String, dynamic> json) => LiveSession(
        id: json['id'] as String,
        preacherId: json['preacherId'] as String,
        preacherName: json['preacher']?['name'] as String?,
        preacherPosition: json['preacher']?['position'] as String?,
        title: json['title'] as String,
        status: json['status'] as String,
        streamUrl: json['streamUrl'] as String?,
        startedAt: json['startedAt'] as String,
        endedAt: json['endedAt'] as String?,
      );
}
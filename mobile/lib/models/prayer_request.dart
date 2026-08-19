// lib/models/prayer_request.dart

class PrayerRequestSubmission {
  final String message;
  final String? requesterName;
  final bool isAnonymous;
  final String? deviceId;

  PrayerRequestSubmission({
    required this.message,
    this.requesterName,
    this.isAnonymous = false,
    this.deviceId,
  });

  Map<String, dynamic> toJson() => {
        'message': message,
        'requesterName': isAnonymous ? null : requesterName,
        'isAnonymous': isAnonymous,
        'deviceId': deviceId,
      };
}
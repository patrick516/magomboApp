class Preaching {
  final String id;
  final String sermonId;
  final int partNumber;
  final String dateRecorded;
  final int durationSeconds;
  final String? localFilePath; // local-only, before/instead of upload
  final String? cloudUrl; // maps to backend's `audioUrl`
  final int playCount;
  final bool synced;
  final bool downloadedLocally;
  final String createdAt;

  Preaching({
    required this.id,
    required this.sermonId,
    required this.partNumber,
    required this.dateRecorded,
    this.durationSeconds = 0,
    this.localFilePath,
    this.cloudUrl,
    this.playCount = 0,
    this.synced = false,
    this.downloadedLocally = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'sermon_id': sermonId,
        'part_number': partNumber,
        'date_recorded': dateRecorded,
        'duration_seconds': durationSeconds,
        'local_file_path': localFilePath,
        'cloud_url': cloudUrl,
        'play_count': playCount,
        'synced': synced ? 1 : 0,
        'downloaded_locally': downloadedLocally ? 1 : 0,
        'created_at': createdAt,
      };

  factory Preaching.fromMap(Map<String, dynamic> map) => Preaching(
        id: map['id'] as String,
        sermonId: map['sermon_id'] as String,
        partNumber: map['part_number'] as int,
        dateRecorded: map['date_recorded'] as String,
        durationSeconds: map['duration_seconds'] as int,
        localFilePath: map['local_file_path'] as String?,
        cloudUrl: map['cloud_url'] as String?,
        playCount: map['play_count'] as int,
        synced: (map['synced'] as int) == 1,
        downloadedLocally: (map['downloaded_locally'] as int) == 1,
        createdAt: map['created_at'] as String,
      );

  // Backend expects: sermonId, dateRecorded, durationSeconds, audioUrl
  // (partNumber is auto-assigned server-side, per preaching.service.js)
 // sermonId is passed in the URL path, not the body — see preaching.routes.js
  Map<String, dynamic> toJson() => {
        'dateRecorded': dateRecorded,
        'durationSeconds': durationSeconds,
        'audioUrl': cloudUrl,
      };
  factory Preaching.fromJson(Map<String, dynamic> json) => Preaching(
        id: json['id'] as String,
        sermonId: json['sermonId'] as String,
        partNumber: json['partNumber'] as int,
        dateRecorded: json['dateRecorded'] as String,
        durationSeconds: json['durationSeconds'] as int,
        cloudUrl: json['audioUrl'] as String?,
        playCount: json['playCount'] as int,
        synced: true,
        downloadedLocally: false,
        createdAt: json['createdAt'] as String,
      );
}
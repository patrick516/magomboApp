class Sermon {
  final String id;
  final String preacherId;
  final String theme;
  final String? series;
  final String createdAt;
  final bool synced;

  Sermon({
    required this.id,
    required this.preacherId,
    required this.theme,
    this.series,
    required this.createdAt,
    this.synced = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'preacher_id': preacherId,
        'theme': theme,
        'series': series,
        'created_at': createdAt,
        'synced': synced ? 1 : 0,
      };

  factory Sermon.fromMap(Map<String, dynamic> map) => Sermon(
        id: map['id'] as String,
        preacherId: map['preacher_id'] as String,
        theme: map['theme'] as String,
        series: map['series'] as String?,
        createdAt: map['created_at'] as String,
        synced: (map['synced'] as int) == 1,
      );

 Map<String, dynamic> toJson() => {
        'id': id,
        'preacherId': preacherId,
        'theme': theme,
        'series': series,
      };
 factory Sermon.fromJson(Map<String, dynamic> json) => Sermon(
        id: json['id'] as String,
        // backend nests preacher info as { preacher: { id, name, position } }
        // fall back to a flat preacherId if present (e.g. from POST response)
        preacherId: (json['preacher']?['id'] ?? json['preacherId']) as String,
        theme: json['theme'] as String,
        series: json['series'] as String?,
        createdAt: json['createdAt'] as String,
        synced: true,
      );
}
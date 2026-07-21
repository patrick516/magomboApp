class Preacher {
  final String id;
  final String deviceId;
  final String name;
  final String? position;
  final String createdAt;
  final bool synced;

  Preacher({
    required this.id,
    required this.deviceId,
    required this.name,
    this.position,
    required this.createdAt,
    this.synced = false,
  });

  // --- SQLite (snake_case) ---
  Map<String, dynamic> toMap() => {
        'id': id,
        'device_id': deviceId,
        'name': name,
        'position': position,
        'created_at': createdAt,
        'synced': synced ? 1 : 0,
      };

  factory Preacher.fromMap(Map<String, dynamic> map) => Preacher(
        id: map['id'] as String,
        deviceId: map['device_id'] as String,
        name: map['name'] as String,
        position: map['position'] as String?,
        createdAt: map['created_at'] as String,
        synced: (map['synced'] as int) == 1,
      );

  // --- REST API (camelCase, matches Prisma) ---
  Map<String, dynamic> toJson() => {
        'id': id,
        'deviceId': deviceId,
        'name': name,
        'position': position,
      };

  factory Preacher.fromJson(Map<String, dynamic> json) => Preacher(
        id: json['id'] as String,
        deviceId: json['deviceId'] as String,
        name: json['name'] as String,
        position: json['position'] as String?,
        createdAt: json['createdAt'] as String,
        synced: true, // came from server, so it's already synced
      );
}
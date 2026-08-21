// lib/models/small_group.dart

class SmallGroup {
  final String id;
  final String name;
  final String? description;
  final String? meetingDay;
  final String? meetingTime;
  final String? location;
  final String? leaderName;
  final int memberCount;
  final bool isMember;

  SmallGroup({
    required this.id,
    required this.name,
    this.description,
    this.meetingDay,
    this.meetingTime,
    this.location,
    this.leaderName,
    this.memberCount = 0,
    this.isMember = false,
  });

  factory SmallGroup.fromJson(Map<String, dynamic> json) => SmallGroup(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        meetingDay: json['meetingDay'] as String?,
        meetingTime: json['meetingTime'] as String?,
        location: json['location'] as String?,
        leaderName: json['leaderName'] as String?,
        memberCount: json['_count']?['memberships'] as int? ?? 0,
        isMember: json['isMember'] as bool? ?? false,
      );
}
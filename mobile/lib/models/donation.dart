/// Dart-friendly names; mapped explicitly to backend's UPPERCASE strings.
enum DonationCategory { tithe, offering, buildingFund, missions, thanksgiving, other }

enum DonationStatus { pending, success, failed }

// --- Mapping tables: Dart enum <-> backend string ---
const Map<DonationCategory, String> _categoryToApi = {
  DonationCategory.tithe: 'TITHE',
  DonationCategory.offering: 'OFFERING',
  DonationCategory.buildingFund: 'BUILDING_FUND',
  DonationCategory.missions: 'MISSIONS',
  DonationCategory.thanksgiving: 'THANKSGIVING',
  DonationCategory.other: 'OTHER',
};

const Map<DonationStatus, String> _statusToApi = {
  DonationStatus.pending: 'PENDING',
  DonationStatus.success: 'SUCCESS',
  DonationStatus.failed: 'FAILED',
};

DonationCategory _categoryFromApi(String value) =>
    _categoryToApi.entries.firstWhere((e) => e.value == value).key;

DonationStatus _statusFromApi(String value) =>
    _statusToApi.entries.firstWhere((e) => e.value == value).key;

class Donation {
  final String id;
  final double amount;
  final DonationCategory category;
  final String method;
  final DonationStatus status;
  final String? reference;
  final bool isAnonymous;
  final String? donorFirstName;
  final String? donorLastName;
  final String? donorPosition;
  final String? donorLocation;
  final String? deviceId;
  final String createdAt;
  final bool synced;

  Donation({
    required this.id,
    required this.amount,
    required this.category,
    required this.method,
    this.status = DonationStatus.pending,
    this.reference,
    this.isAnonymous = false,
    this.donorFirstName,
    this.donorLastName,
    this.donorPosition,
    this.donorLocation,
    this.deviceId,
    required this.createdAt,
    this.synced = false,
  });

  // --- SQLite (snake_case, stores backend-style strings for consistency) ---
  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'category': _categoryToApi[category],
        'method': method,
        'status': _statusToApi[status],
        'reference': reference,
        'is_anonymous': isAnonymous ? 1 : 0,
        'donor_first_name': donorFirstName,
        'donor_last_name': donorLastName,
        'donor_position': donorPosition,
        'donor_location': donorLocation,
        'device_id': deviceId,
        'created_at': createdAt,
        'synced': synced ? 1 : 0,
      };

  factory Donation.fromMap(Map<String, dynamic> map) => Donation(
        id: map['id'] as String,
        amount: map['amount'] as double,
        category: _categoryFromApi(map['category'] as String),
        method: map['method'] as String,
        status: _statusFromApi(map['status'] as String),
        reference: map['reference'] as String?,
        isAnonymous: (map['is_anonymous'] as int) == 1,
        donorFirstName: map['donor_first_name'] as String?,
        donorLastName: map['donor_last_name'] as String?,
        donorPosition: map['donor_position'] as String?,
        donorLocation: map['donor_location'] as String?,
        deviceId: map['device_id'] as String?,
        createdAt: map['created_at'] as String,
        synced: (map['synced'] as int) == 1,
      );

  // --- REST API (matches Prisma enum strings exactly) ---
  Map<String, dynamic> toJson() => {
        'amount': amount,
        'category': _categoryToApi[category],
        'method': method,
        'reference': reference,
        'isAnonymous': isAnonymous,
        'donorFirstName': isAnonymous ? null : donorFirstName,
        'donorLastName': isAnonymous ? null : donorLastName,
        'donorPosition': isAnonymous ? null : donorPosition,
        'donorLocation': isAnonymous ? null : donorLocation,
        'deviceId': deviceId,
      };

  factory Donation.fromJson(Map<String, dynamic> json) => Donation(
        id: json['id'] as String,
        amount: json['amount'] is String
            ? double.parse(json['amount'] as String)
            : (json['amount'] as num).toDouble(),
        category: _categoryFromApi(json['category'] as String),
        method: json['method'] as String,
        status: _statusFromApi(json['status'] as String),
        reference: json['reference'] as String?,
        isAnonymous: json['isAnonymous'] as bool? ?? false,
        donorFirstName: json['donorFirstName'] as String?,
        donorLastName: json['donorLastName'] as String?,
        donorPosition: json['donorPosition'] as String?,
        donorLocation: json['donorLocation'] as String?,
        deviceId: json['deviceId'] as String?,
        createdAt: json['createdAt'] as String,
        synced: true,
      );
}
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
  final String createdAt;
  final bool synced;

  Donation({
    required this.id,
    required this.amount,
    required this.category,
    required this.method,
    this.status = DonationStatus.pending,
    this.reference,
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
        createdAt: map['created_at'] as String,
        synced: (map['synced'] as int) == 1,
      );

  // --- REST API (matches Prisma enum strings exactly) ---
  Map<String, dynamic> toJson() => {
        'amount': amount,
        'category': _categoryToApi[category],
        'method': method,
        'reference': reference,
      };

  factory Donation.fromJson(Map<String, dynamic> json) => Donation(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: _categoryFromApi(json['category'] as String),
        method: json['method'] as String,
        status: _statusFromApi(json['status'] as String),
        reference: json['reference'] as String?,
        createdAt: json['createdAt'] as String,
        synced: true,
      );
}
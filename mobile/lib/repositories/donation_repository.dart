import 'package:sqflite/sqflite.dart';
import '../models/donation.dart';
import '../services/database_service.dart';

class DonationRepository {
  Future<Database> get _db async => DatabaseService.instance.database;

  Future<void> insert(Donation donation) async {
    final db = await _db;
    await db.insert(
      'donations',
      donation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Donation>> getAll() async {
    final db = await _db;
    final rows = await db.query('donations', orderBy: 'created_at DESC');
    return rows.map((r) => Donation.fromMap(r)).toList();
  }
}
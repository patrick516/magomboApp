import 'package:sqflite/sqflite.dart';
import '../models/preacher.dart';
import '../services/database_service.dart';

class PreacherRepository {
  Future<Database> get _db async => DatabaseService.instance.database;

  Future<void> insert(Preacher preacher) async {
    final db = await _db;
    await db.insert(
      'preachers',
      preacher.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Preacher>> getByDevice(String deviceId) async {
    final db = await _db;
    final rows = await db.query(
      'preachers',
      where: 'device_id = ?',
      whereArgs: [deviceId],
      orderBy: 'created_at ASC',
    );
    return rows.map((r) => Preacher.fromMap(r)).toList();
  }

  Future<List<Preacher>> getAll() async {
    final db = await _db;
    final rows = await db.query('preachers', orderBy: 'name ASC');
    return rows.map((r) => Preacher.fromMap(r)).toList();
  }

Future<Preacher?> getById(String id) async {
    final db = await _db;
    final rows = await db.query('preachers', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Preacher.fromMap(rows.first);
  }

  Future<List<Preacher>> getUnsynced() async {
    final db = await _db;
    final rows = await db.query('preachers', where: 'synced = 0');
    return rows.map((r) => Preacher.fromMap(r)).toList();
  }

  Future<void> markSynced(String id) async {
    final db = await _db;
    await db.update('preachers', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }
}
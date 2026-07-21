import 'package:sqflite/sqflite.dart';
import '../models/sermon.dart';
import '../services/database_service.dart';

class SermonRepository {
  Future<Database> get _db async => DatabaseService.instance.database;

  Future<void> insert(Sermon sermon) async {
    final db = await _db;
    await db.insert(
      'sermons',
      sermon.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// All themes created by a specific preacher — used for "continue existing theme" picker
  Future<List<Sermon>> getByPreacher(String preacherId) async {
    final db = await _db;
    final rows = await db.query(
      'sermons',
      where: 'preacher_id = ?',
      whereArgs: [preacherId],
      orderBy: 'created_at DESC',
    );
    return rows.map((r) => Sermon.fromMap(r)).toList();
  }

  Future<List<Sermon>> getAll() async {
    final db = await _db;
    final rows = await db.query('sermons', orderBy: 'created_at DESC');
    return rows.map((r) => Sermon.fromMap(r)).toList();
  }

 Future<Sermon?> getById(String id) async {
    final db = await _db;
    final rows = await db.query('sermons', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Sermon.fromMap(rows.first);
  }

  Future<List<Sermon>> getUnsynced() async {
    final db = await _db;
    final rows = await db.query('sermons', where: 'synced = 0');
    return rows.map((r) => Sermon.fromMap(r)).toList();
  }

  Future<void> markSynced(String id) async {
    final db = await _db;
    await db.update('sermons', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }
}
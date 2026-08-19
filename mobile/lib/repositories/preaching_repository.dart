import 'package:sqflite/sqflite.dart';
import '../models/preaching.dart';
import '../services/database_service.dart';

class PreachingRepository {
  Future<Database> get _db async => DatabaseService.instance.database;

  Future<void> insert(Preaching preaching) async {
    final db = await _db;
    await db.insert(
      'preachings',
      preaching.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// All parts under a theme, in order — Part 1, 2, 3...
  Future<List<Preaching>> getBySermon(String sermonId) async {
    final db = await _db;
    final rows = await db.query(
      'preachings',
      where: 'sermon_id = ?',
      whereArgs: [sermonId],
      orderBy: 'part_number ASC',
    );
    return rows.map((r) => Preaching.fromMap(r)).toList();
  }

  /// Works out the next part number for a given sermon (Part 1, 2, 3...)
  Future<int> getNextPartNumber(String sermonId) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT MAX(part_number) as maxPart FROM preachings WHERE sermon_id = ?',
      [sermonId],
    );
    final maxPart = result.first['maxPart'] as int?;
    return (maxPart ?? 0) + 1;
  }

    /// Total number of preaching parts across every sermon this preacher owns
  Future<int> getTotalPartsForPreacher(String preacherId) async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as totalParts
      FROM preachings p
      INNER JOIN sermons s ON p.sermon_id = s.id
      WHERE s.preacher_id = ?
    ''', [preacherId]);
    return (result.first['totalParts'] as int?) ?? 0;
  }

  /// Sum of play_count across every preaching this preacher has recorded
  Future<int> getTotalPlaysForPreacher(String preacherId) async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(p.play_count), 0) as totalPlays
      FROM preachings p
      INNER JOIN sermons s ON p.sermon_id = s.id
      WHERE s.preacher_id = ?
    ''', [preacherId]);
    return (result.first['totalPlays'] as int?) ?? 0;
  }



  Future<void> incrementPlayCount(String id) async {
    final db = await _db;
    await db.rawUpdate(
      'UPDATE preachings SET play_count = play_count + 1 WHERE id = ?',
      [id],
    );
  }

 Future<void> markSynced(String id, {String? cloudUrl}) async {
    final db = await _db;
    await db.update(
      'preachings',
      {
        'synced': 1,
        'cloud_url': ?cloudUrl,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Preaching>> getUnsynced() async {
    final db = await _db;
    final rows = await db.query('preachings', where: 'synced = 0');
    return rows.map((r) => Preaching.fromMap(r)).toList();
  }
}
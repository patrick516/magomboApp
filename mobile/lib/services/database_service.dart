// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'magombo.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE preachers (
        id TEXT PRIMARY KEY,
        device_id TEXT NOT NULL,
        name TEXT NOT NULL,
        position TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sermons (
        id TEXT PRIMARY KEY,
        preacher_id TEXT NOT NULL,
        theme TEXT NOT NULL,
        series TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (preacher_id) REFERENCES preachers (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE preachings (
        id TEXT PRIMARY KEY,
        sermon_id TEXT NOT NULL,
        part_number INTEGER NOT NULL,
        date_recorded TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL DEFAULT 0,
        local_file_path TEXT,
        cloud_url TEXT,
        play_count INTEGER NOT NULL DEFAULT 0,
        synced INTEGER NOT NULL DEFAULT 0,
        downloaded_locally INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (sermon_id) REFERENCES sermons (id),
        UNIQUE (sermon_id, part_number)
      )
    ''');

    await db.execute('''
      CREATE TABLE donations (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        method TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'PENDING',
        reference TEXT,
        is_anonymous INTEGER NOT NULL DEFAULT 0,
        donor_first_name TEXT,
        donor_last_name TEXT,
        donor_position TEXT,
        donor_location TEXT,
        device_id TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Existing dev/test devices already have a v1 `donations` table
      // without these columns — add them in place rather than dropping data.
      await db.execute('ALTER TABLE donations ADD COLUMN is_anonymous INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE donations ADD COLUMN donor_first_name TEXT');
      await db.execute('ALTER TABLE donations ADD COLUMN donor_last_name TEXT');
      await db.execute('ALTER TABLE donations ADD COLUMN donor_position TEXT');
      await db.execute('ALTER TABLE donations ADD COLUMN donor_location TEXT');
      await db.execute('ALTER TABLE donations ADD COLUMN device_id TEXT');
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static Database? _database;
  static const String dbName = 'announcement_app.db';
  static const int version = 1;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);
    print('📁 DB Path: $path');

    return await openDatabase(
      path,
      version: version,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE announcements (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        acknowledge INTEGER NOT NULL DEFAULT 0,
        file_url TEXT,
        image_url TEXT NOT NULL,
        is_dirty INTEGER DEFAULT 0,
        operation_type TEXT,
        updated_at TEXT NOT NULL,
        sync_status TEXT DEFAULT 'synced'
      )
    ''');
    print('✅ Table created');
  }

  static Future<int> getDirtyCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM announcements WHERE is_dirty = 1');
    return Sqflite.firstIntValue(result) ?? 0;
  }
  // Add to DatabaseHelper class
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('announcements');
    print('🗑️ All local data cleared');
  }



  static Future<void> printSyncStatus() async {
    final db = await database;

    // Dirty count
    final dirty = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM announcements WHERE is_dirty = 1')
    ) ?? 0;

    // Pending sync
    final pending = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM announcements WHERE sync_status = "pending"')
    ) ?? 0;

    // Total records
    final total = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM announcements')
    ) ?? 0;

    print('📊 DB Status: Dirty=$dirty | Pending=$pending | Total=$total');
  }


}

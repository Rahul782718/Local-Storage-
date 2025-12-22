import 'package:sqflite/sqflite.dart';
import '../../Local_database/Local_Model/announcementLocalModel.dart';
import '../../Local_database/databaseHelper.dart';
import '../models/AnnouncementView_Model.dart';

abstract class AnnouncementLocalDataSource {
  Future<List<AnnouncementLocalModel>> getAnnouncements();
  Future<void> insertAnnouncements(List<AnnouncementView> announcements);
  Future<void> upsertAnnouncement(AnnouncementLocalModel announcement);
  Future<List<AnnouncementLocalModel>> getDirtyAnnouncements();
  Future<void> updateSyncStatus(int id, String status);
}

class AnnouncementLocalDataSourceImpl implements AnnouncementLocalDataSource {
  @override
  Future<List<AnnouncementLocalModel>> getAnnouncements() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      'announcements',
      where: 'sync_status != ?',
      whereArgs: ['deleted'],
      orderBy: 'updated_at DESC',
    );
    return maps.map((map) => AnnouncementLocalModel.fromMap(map)).toList();
  }

  @override
  Future<void> insertAnnouncements(List<AnnouncementView> announcements) async {
    final db = await DatabaseHelper.database;
    final batch = db.batch();
    for (final ann in announcements) {
      final localModel = AnnouncementLocalModel(
        id: ann.id,
        title: ann.title,
        description: ann.description,
        acknowledge: ann.acknowledge,
        fileUrl: ann.fileUrl,
        imageUrl: ann.imageUrl,
        updatedAt: DateTime.now(),
        syncStatus: 'synced',
      );
      batch.insert('announcements', localModel.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> upsertAnnouncement(AnnouncementLocalModel announcement) async {
    final db = await DatabaseHelper.database;
    await db.insert(
      'announcements',
      announcement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<AnnouncementLocalModel>> getDirtyAnnouncements() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      'announcements',
      where: 'is_dirty = ?',
      whereArgs: [1],
    );
    return maps.map((map) => AnnouncementLocalModel.fromMap(map)).toList();
  }

  @override
  Future<void> updateSyncStatus(int id, String status) async {
    final db = await DatabaseHelper.database;
    await db.update(
      'announcements',
      {'sync_status': status, 'is_dirty': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

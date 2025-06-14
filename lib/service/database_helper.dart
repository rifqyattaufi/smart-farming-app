import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_farming_app/model/notifikasi_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  static const String _dbName = 'smartFarmingNotifications.db';
  static const String _tableName = 'notifications';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        received_at TEXT NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0,
        notification_type TEXT,
        payload TEXT
      )
    ''');
  }

  Future<int> insertNotification(NotifikasiModel notifikasi) async {
    Database db = await instance.database;

    return await db.insert(_tableName, notifikasi.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<NotifikasiModel>> getAllNotifications() async {
    Database db = await instance.database;

    final List<Map<String, dynamic>> maps =
        await db.query(_tableName, orderBy: 'received_at DESC');

    return List.generate(maps.length, (i) {
      return NotifikasiModel.fromMap(maps[i]);
    });
  }

  Future<List<NotifikasiModel>> getUnreadNotifications() async {
    Database db = await instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'isRead = ?',
      whereArgs: [0],
      orderBy: 'received_at DESC',
    );

    return List.generate(maps.length, (i) {
      return NotifikasiModel.fromMap(maps[i]);
    });
  }

  Future<List<NotifikasiModel>> getReadNotifications() async {
    Database db = await instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'isRead = ?',
      whereArgs: [1],
      orderBy: 'received_at DESC',
    );

    return List.generate(maps.length, (i) {
      return NotifikasiModel.fromMap(maps[i]);
    });
  }

  Future<int> markAsRead(String id) async {
    Database db = await instance.database;

    return await db.update(
      _tableName,
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markAllAsRead() async {
    Database db = await instance.database;
    int response;
    response = await db.update(
      _tableName,
      {'isRead': 1},
      where: 'isRead = ?',
      whereArgs: [0],
    );
    return response;
  }

  Future<int> deleteNotification(String id) async {
    Database db = await instance.database;

    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllNotifications() async {
    Database db = await instance.database;

    return await db.delete(_tableName);
  }

  Future<int> deleteReadNotifications() async {
    Database db = await instance.database;

    return await db.delete(
      _tableName,
      where: 'isRead = ?',
      whereArgs: [1],
    );
  }
}

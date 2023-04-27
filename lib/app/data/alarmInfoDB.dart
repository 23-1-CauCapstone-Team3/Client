import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/alarm_info.dart';

final String TABLENAME = 'alarmInfo';

class AlarmInfoProvider {
  static final AlarmInfoProvider _alarmInfoProvider = AlarmInfoProvider
      ._internal();

  AlarmInfoProvider._internal(){
    // init values...

    /*
    async cannot be used in constructor,
    so change 'get database'
    */
  }

  factory AlarmInfoProvider() {
    return _alarmInfoProvider;
  }

  static Database? _db;

  Future<Database> get database async => _db ??= await initDB();

  initDB() async {
    String path = join(await getDatabasesPath(), 'alarmInfo.db');
    return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE alarmInfo(
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              alarmDate TEXT NOT NULL UNIQUE,
              location TEXT NOT NULL
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion) {}
    );
  }

  Future<List<AlarmInfo>> getDB() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(TABLENAME, orderBy: "alarmDate");
    if (maps.isEmpty) return [];
    List<AlarmInfo> list = List.generate(maps.length, (index) {
      return AlarmInfo(
        id: maps[index]["id"],
        alarmDate: maps[index]["alarmDate"],
        location: maps[index]["location"],
      );
    });
    return list;
  }

  Future<AlarmInfo> getTodayAlarm(String today) async {
    final db = await database;
    final List<Map<String, dynamic>> map = await db!.query(
        TABLENAME,
        where: "alarmDate = ?",
        whereArgs: [today],
    );
    if (map.isEmpty) return AlarmInfo(alarmDate: "", location: "");
    return AlarmInfo(
      id: map[0]["id"],
      alarmDate: map[0]["alarmDate"],
      location: map[0]["location"],
    );
  }

  Future<void> insert(AlarmInfo alarmInfo) async {
    final db = await database;
    alarmInfo.id = await db?.insert(TABLENAME, alarmInfo.toMap());
  }

  Future<void> update(AlarmInfo alarmInfo) async {
    final db = await database;
    await db?.update(
      TABLENAME,
      alarmInfo.toMap(),
      where: "id = ?",
      whereArgs: [alarmInfo.id],
    );
  }

  Future<void> idDelete(AlarmInfo alarmInfo) async {
    final db = await database;
    await db?.delete(
      TABLENAME,
      where: "id = ?",
      whereArgs: [alarmInfo.id],
    );
  }

  Future<void> dateDelete(String alarmDate) async {
    final db = await database;
    await db?.delete(
      TABLENAME,
      where: "alarmDate = ?",
      whereArgs: [alarmDate],
    );
  }
}
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/location_info.dart';

final String TABLENAME = 'locationInfo';

class LocationInfoProvider {
  static final LocationInfoProvider _locationInfoProvider = LocationInfoProvider._internal();
  LocationInfoProvider._internal() {
    // init values...

    /*
    async cannot be used in constructor,
    so change 'get database'
    */
  }
  factory LocationInfoProvider() {
    return _locationInfoProvider;
  }

  static Database? _db;

  Future<Database> get database async => _db ??= await initDB();

  initDB() async {
    String path = join(await getDatabasesPath(), 'locationInfo.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
            CREATE TABLE locationInfo(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              location TEXT NOT NULL UNIQUE,
              address TEXT NOT NULL UNIQUE
            )
          ''');
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  Future<List<LocationInfo>> getDB() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(TABLENAME);
    if (maps.isEmpty) return [];
    List<LocationInfo> list = List.generate(maps.length, (index) {
      return LocationInfo(
        id: maps[index]["id"],
        location: maps[index]["location"],
        address: maps[index]["address"],
      );
    });
    return list;
  }

  Future<String> getDefaultLocation() async {
    final db = await database;
    final List<Map<String, dynamic>> map = await db!.query(
      TABLENAME,
      where: "id = ?",
      whereArgs: [1],
    );
    if (map.isEmpty) return "";
    return map[0]["location"];
  }

  Future<void> insert(LocationInfo locationInfo) async {
    final db = await database;
    locationInfo.id = await db?.insert(TABLENAME, locationInfo.toMap());
  }

  Future<void> update(LocationInfo locationInfo) async {
    final db = await database;
    await db?.update(
      TABLENAME,
      locationInfo.toMap(),
      where: "id = ?",
      whereArgs: [locationInfo.id],
    );
  }

  Future<void> delete(LocationInfo locationInfo) async {
    final db = await database;
    await db?.delete(
      TABLENAME,
      where: "id = ?",
      whereArgs: [locationInfo.id],
    );
  }
}

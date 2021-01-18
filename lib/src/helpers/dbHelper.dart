import 'package:map_demo/src/models/geoCordResponse.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class DBHelper {
  static Database _db;
  static const String ID = 'id';
  static const String Name = 'name';
  static const String Value = 'value';
  static const String TABLE = 'geoCord';
  static const String DB_NAME = 'geoCord.db';

  //return db if initialized else initialized it
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }

    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $TABLE($ID INTEGER PRIMARY KEY, $Name TEXT, $Value TEXT)");
  }

  Future<GeoCordResponse> insertToDb(GeoCordResponse _response) async {
    var dbClient = await db;
    //insert will return the id
    var insert = await dbClient.insert(TABLE, _response.toMap());
    return _response;
  }

  Future<List<GeoCordResponse>> getGeoPointsById(Uuid id) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE,
        columns: [ID, Name, Value], where: 'id = $id');
    List<GeoCordResponse> points = [];
    if (maps.length > 0) {
      for (var i = 0; i < maps.length; i++) {
        points.add(GeoCordResponse.fromMap(maps[i]));
      }
    }
    return points;
  }

  Future<List<GeoCordResponse>> getGeoPoints() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE, columns: [ID, Name, Value]);
    List<GeoCordResponse> points = [];
    if (maps.length > 0) {
      for (var i = 0; i < maps.length; i++) {
        points.add(GeoCordResponse.fromMap(maps[i]));
      }
    }
    return points;
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }

  Future deleteTable() async {
    var dbClient = await db;
    return await dbClient.delete(TABLE);
  }
}

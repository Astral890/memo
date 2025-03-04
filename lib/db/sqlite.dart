import 'package:memo/db/datos.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Sqlite {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDB();
    return _database!;
  }

  static Future<Database> _openDB() async {
    print("Path: ${await getDatabasesPath()}");
    return openDatabase(
      join(await getDatabasesPath(), 'datos.db'),
      onCreate: (db, version) async {
        await db.execute("""
        CREATE TABLE datos(
          id INTEGER PRIMARY KEY, 
          fecha TEXT, 
          victorias INTEGER, 
          derrotas INTEGER
        );
        """);
        await db.insert("datos", {
          "id": 1,
          "fecha": "2025-03-03",
          "victorias": 0,
          "derrotas": 0
        });
      },
      version: 1,
    );
  }

  static Future<int> insert(Datos data) async {
    final db = await database;
    return db.insert("datos", data.toMap());
  }

  static Future<int> delete(Datos data) async {
    final db = await database;
    return db.delete("datos", where: "id = 1");
  }

  Future<int> update(Datos data) async {
    final db = await database;
    return db.update("datos", data.toMap(), where: "id = 1");
  }

  static Future<Datos?> ver() async {
    final db = await database;
    final List<Map<String, dynamic>> datosMap = await db.query("datos", where: "id = 1");
    if (datosMap.isNotEmpty) {
      return Datos(
          id: datosMap[0]['id'],
          fecha: datosMap[0]['fecha'],
          victorias: datosMap[0]['victorias'],
          derrotas: datosMap[0]['derrotas']
      );
    }
    return null;
  }

  static Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

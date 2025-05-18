import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stated_management/model.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('alerts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE alerts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        startTime TEXT,
        endTime TEXT
      )
    ''');
  }

  Future<void> insertAlert(Alert alert) async {
    final db = await database;
    await db.insert('alerts', alert.toMap());
  }

  Future<List<Alert>> getAlerts() async {
    final db = await database;
    final maps = await db.query('alerts');
    return maps.map((map) => Alert.fromMap(map)).toList();
  }

  Future<void> deleteAlert(int id) async {
    final db = await database;
    await db.delete('alerts', where: 'id = ?', whereArgs: [id]);
  }
}

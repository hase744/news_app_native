import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
class History{
  late Database _database;
  Future<void> initDatabase() async {
    _database = await openDatabase(
      p.join(await getDatabasesPath(), 'my_database.db'),
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE Histories (
            id INTEGER PRIMARY KEY,
            youtube_id TEXT,
            title TEXT,
            channel_name TEXT,
            channel_id TEXT
          )
        ''');
      },
      version: 1,
    );
  }

  Future<void> deleteTable() async {
    final dbPath = p.join(await getDatabasesPath(), 'my_database.db');
    await deleteDatabase(dbPath);
  }

  Future<void> create(Map press) async {
    Map<String, String> stringMap = press.map((key, value) {
      return MapEntry(key.toString(), value.toString());
    });
    await _database.insert(
      'Histories',
      stringMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> all() async {
    return await _database.query('Histories');
  }

}
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
class Favorite{
  late Database _database;
  Favorite() {
    initDatabase();
  }
  
  Future<void> initDatabase() async {
    _database = await openDatabase(
      p.join(await getDatabasesPath(), 'my_database2.db'),
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE Favorites (
            id INTEGER PRIMARY KEY,
            youtube_id TEXT,
            title TEXT,
            channel_name TEXT,
            channel_id TEXT,
            created_at TEXT,
            second INTEGER
          )
        ''');
      },
      version: 1,
    );
  }

  Future<void> deleteTable() async {
    final dbPath = p.join(await getDatabasesPath(), 'my_database2.db');
    await deleteDatabase(dbPath);
  }

  Future<void> create(Map press) async {
    print(press['title']);
    Map<String, dynamic> stringMap = {
      'youtube_id': press['youtube_id'],
      'title': press['title'],
      'channel_id': press['channel_id'],
      'channel_name': press['channel_name'],
      'second': press['second'],
    };
    print("お気に入り追加");
    stringMap['created_at'] = "$DateTime.now()";
    await _database.insert(
      'Favorites',
      stringMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(int id) async {
    await _database.delete(
      'Favorites', 
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> exists(String youtube_id) async{
    final Database db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Favorites',
      where: 'youtube_id = ?',
      whereArgs: [youtube_id],
    );
    return maps.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> all() async {
    return await _database.query('Favorites');
  }

}
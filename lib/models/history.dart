import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
class History{
  late Database _database;

  History(){
    initDatabase();
  }
  Future<void> initDatabase() async {
    _database = await openDatabase(
      p.join(await getDatabasesPath(), 'my_database.db'),
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE Histories (
            id INTEGER PRIMARY KEY,
            youtube_id TEXT,
            title TEXT,z
            channel_name TEXT,
            channel_id TEXT,
            second INTEGER
          )
        ''');
      },
      version: 1,
    );
  }

  Future<String?> LastYouTubeId() async {
  final db = await _database;
  final List<Map<String, dynamic>> result = await db.query(
    'Histories',
    orderBy: 'id DESC', // idを降順にソートして最後の行を取得
    limit: 1, // 1行だけ取得
  );

  if (result.isNotEmpty) {
    final Map<String, dynamic> lastRow = result.first;
    final String? youtubeId = lastRow['youtube_id'];
    print(youtubeId);
    return youtubeId;
  } else {
    return null; // データが存在しない場合はnullを返します
  }
}

  Future<void> deleteTable() async {
    final dbPath = p.join(await getDatabasesPath(), 'my_database.db');
    await deleteDatabase(dbPath);
  }

  Future<void> create(Map video) async {
    Map<String, dynamic> stringMap = {
      'youtube_id': video['youtube_id'],
      'title': video['title'],
      'channel_id': video['channel_id'],
      'channel_name': video['channel_name'],
      'second': video['second'],
    };
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
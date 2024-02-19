import 'package:sqflite/sqflite.dart';
import 'package:video_news/models/downloader/video_data.dart';
import 'package:path/path.dart' as p;
class DbController{
  late Database _database;

  DbController(){
    initDatabase();
  }

  Future<void> initDatabase() async {
    _database = await openDatabase(
      p.join(await getDatabasesPath(), 'video.db'),
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE Videos (
            id INTEGER PRIMARY KEY,
            youtube_id TEXT,
            thumbnail_path TEXT,
            video_path TEXT,
            created_at INTEGER
          )
        ''');
      },
      version: 1,
    );
    print("OK");
  }

  Future<void> deleteTable() async {
    final dbPath = p.join(await getDatabasesPath(), 'video.db');
    await deleteDatabase(dbPath);
  }

  Future<void> create(VideoData data) async {
    Map<String, dynamic> stringMap = data.dbMap();
    await _database.insert(
      'Videos',
      stringMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> all() async {
    return await _database.query('Videos');
  }

  Future<Map<String, dynamic>?> getVideoByYoutubeId(String youtubeId) async {
    List<Map<String, dynamic>> result = await _database.query(
      'Videos',
      where: 'thumbnail_path = ?',
      whereArgs: [youtubeId],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getVideosByPaths(List paths) async {
    List<Map<String, dynamic>> result = await _database.query(
      'Videos',
      where: 'video_path IN (${paths.map((_) => '?').join(', ')})',
      whereArgs: paths,
    );

    if (result.isNotEmpty) {
      return result;
    } else {
      return [];
    }
  }

  Future<void> delete(int id) async {
    await _database.delete(
      "Videos",
      where: "id=?",
      whereArgs: [id],
    );
  }
  
  Future<void> deleteByPartialPath(String partialPath) async {
    await _database.delete(
      'Videos',
      where: 'video_path LIKE ?',
      whereArgs: ['%$partialPath%'],
    );
  }
Future<List<Map<String, dynamic>>> getRecordByPartialPath(String partialPath) async {
  List<Map<String, dynamic>> record = await _database.query(
    'Videos',
    where: 'video_path LIKE ?',
    whereArgs: ['%$partialPath%'],
  );
  return record;
}


  Future<void> updateVideo(int id, VideoData data) async {
    Map<String, dynamic> stringMap = data.dbMap();
    await _database.update(
      'Videos',
      stringMap,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
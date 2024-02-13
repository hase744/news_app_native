import 'package:path_provider/path_provider.dart';
class Folder{
  String path;
  String get name => path.toString().split('/').last;
  Future<String> get parent async {
    var rootPath = await getApplicationDocumentsDirectory();
    return path.replaceFirst(rootPath.path, "");
  }
  Future<String> get parentRelativePath async {
    var rootPath = await getApplicationDocumentsDirectory();
    var videoPath = path.replaceFirst(rootPath.path, "");
    List folders = videoPath.split('/');
    videoPath = folders.sublist(1, folders.length-1).join('/');
    return videoPath;
  }
  Folder({
    required this.path
  });
}
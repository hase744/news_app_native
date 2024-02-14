import 'dart:io';
import 'package:video_news/models/downloader/file_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_news/models/downloader/file_form.dart';
import 'package:video_news/models/downloader/path_form.dart';
import 'package:video_news/models/downloader/video_data.dart';
import 'package:video_news/models/downloader/file_form.dart';
import 'package:video_news/models/downloader/video_data.dart';

class DirectoryController{
  String currentPath;
  DirectoryController({
    required this.currentPath
  });
  Future<List<FileSystemEntity>> getDirectoriesOf(String? extension) async {
    Directory dir = Directory(currentPath);
    List<FileSystemEntity> directories = dir.listSync();
    if(extension == null){
      print(directories.where((dir) => dir is Directory ).toList());
      return directories.where((dir) => dir is Directory ).toList();
    }else{
      return directories.where((dir) => dir is File && dir.path.endsWith(extension)).toList();
    }
  }

  updateDirectories() async {
    final directory = Directory('$currentPath/');
    await directory.create(recursive: true);
  }

  Future<String> getFolderByVideo(VideoData target) async {
    final dir = await getApplicationDocumentsDirectory();
    String path = target.videoPath.substring(dir.path.length+1, target.videoPath.length - target.videoPathForm.title.length-1);
    return path; 
  }

  Future<List> getFileTitlesByDirectory(FileType type) async {
    String extension = FileForm(type: type).extension!;
    List<FileSystemEntity> dirs = await getDirectoriesOf(extension);
    return dirs.map((file) => PathForm.fromPath(file.path).title ).toList();
  }
}
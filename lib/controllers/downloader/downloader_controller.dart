import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:video_news/models/downloader/mode.dart';
import 'package:video_news/models/downloader/folder.dart';
import 'package:video_news/models/downloader/video_data.dart';
import 'package:video_news/models/downloader/file_type.dart';
import 'package:video_news/models/downloader/file_form.dart';
import 'package:video_news/models/downloader/path_form.dart';
import 'package:video_news/controllers/video_db_controller.dart';
import 'package:video_news/controllers/directory/directory_ontroller.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class DownloaderController{
  String downloadPath;
  double progress = 0.0;
  late final Function(double) onProcessed;
  final _videoForm = FileForm(type: FileType.video);
  final _imageForm = FileForm(type: FileType.image);

  final yt = YoutubeExplode();
  late DirectoryController _directoryController = DirectoryController(currentPath: downloadPath);
  DbController dbController = DbController();

  DownloaderController({
    required this.downloadPath,
    required this.onProcessed
  });
  Future<void> download(youtubeId, type) async{
    final yt = YoutubeExplode();
    final video = await yt.videos.get("https://www.youtube.com/watch?v=$youtubeId");

    var videoTitle = await getUniqueFileName(video.title, type);
    var imageTitle = await getUniqueFileName(youtubeId, FileType.image);

    final directory = Directory('$downloadPath/');
    await directory.create(recursive: true);
    
    String videoPath = await downloadVideo(youtubeId, videoTitle, yt, type);
    String imagePath = await downloadImage(youtubeId, imageTitle);
    
    print(videoPath);
    await dbController.initDatabase();
    VideoData data = VideoData(
      videoPath: videoPath,
      thumbnailPath: imagePath,
      youtubeId: youtubeId
    );
    dbController.create(data);
    print('saving in $videoPath');
  }

  Future<String> getArrangedFileName(String name) async {
    return 
    name
    .replaceAll(r'\', '')
    .replaceAll('/', '')
    .replaceAll('*', '')
    .replaceAll('?', '')
    .replaceAll('"', '')
    .replaceAll('<', '')
    .replaceAll('>', '')
    .replaceAll('|', '');
  }

  getUniqueFileName(String title, FileType type) async {
    final fileForm = FileForm(type: type);
    String fileName = '${await getArrangedFileName(title)}${fileForm.extension!}';
    List titles = await _directoryController.getFileTitlesByDirectory(type);
    var newTitle = fileName;
    for(var i = 1; titles.contains(newTitle); i++ ){
      newTitle = '${await getArrangedFileName(title)}($i)${fileForm.extension!}';
    }
    return newTitle.split('.').first;
  }

  downloadVideo(String youtubeId, String videoTitle, YoutubeExplode yt, FileType type) async {
    final manifest = await yt.videos.streamsClient.getManifest("https://www.youtube.com/watch?v=$youtubeId");
    //final streams = type == FileType.video ? manifest.muxed : manifest.audioOnly;
    final streams = manifest.muxed;
    final audio = streams.first;
    print(audio.container.name);
    var filename = '$videoTitle.${audio.container.name.toString()}';
    final file = File('$downloadPath/$filename');
    final output = file.openWrite(mode: FileMode.writeOnlyAppend);
    var len = audio.size.totalBytes;
    var count = 0;
    var msg = 'downloading $videoTitle.${audio.container.name}';
    final audiostream = yt.videos.streamsClient.get(audio);
    stdout.writeln(msg);
    await for (final data in audiostream){
      //setState(() {
        count += data.length;
        progress = count / len;
        output.add(data);
          onProcessed(progress);
        if(progress == 1){
          //progress = null;
          print("完了");
        }
        
        //print(progress);
      //});
    }
    await output.flush();
    await output.close();
    print("完了");
    return ('$downloadPath/$filename');
  }

  downloadImage(String youtubeId, String title) async {
    final http.Response response = await http.get(Uri.parse("http://img.youtube.com/vi/$youtubeId/mqdefault.jpg"));
    var imageFileName = '$title${_imageForm.extension!}';
    final directory = Directory('$downloadPath/');
    await directory.create(recursive: true);
    final imageFile = File('$downloadPath/$imageFileName');
    imageFile.writeAsBytesSync(response.bodyBytes);
    return('$downloadPath/$imageFileName');
  }

}
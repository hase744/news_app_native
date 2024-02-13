import 'package:video_news/models/downloader/path_form.dart';
class VideoData{
  int? id;
  String videoPath;
  String youtubeId;
  String thumbnailPath;
  int? get fileId => id;
  String get getVideoPath => videoPath;
  String get getThumbnailPath => thumbnailPath;
  PathForm get videoPathForm => PathForm.fromPath(videoPath);
  PathForm get thumbnailPathForm => PathForm.fromPath(thumbnailPath);

  VideoData({
    required this.videoPath,
    required this.thumbnailPath,
    required this.youtubeId,
  });

  replaceFolder(String oldPath, String newPath){
    videoPath = videoPath.replaceFirst(oldPath, newPath);
    thumbnailPath = thumbnailPath.replaceFirst(oldPath, newPath);
  }
  
  VideoData.fromDb(Map<String, dynamic> map)
    : id = map['id'],
      videoPath = map['video_path'],
      thumbnailPath = map['thumbnail_path'],
      youtubeId = map['youtube_id'];

  Map<String, dynamic> toMap() {
    return {
      'video_path': videoPath,
      'thumbnail_path': thumbnailPath,
    };
  }

  Map<String, dynamic> dbMap() {
    return {
      'video_path': videoPath,
      'thumbnail_path': thumbnailPath,
      'youtube_id': youtubeId,
    };
  }
}
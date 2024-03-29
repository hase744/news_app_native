import 'package:video_news/models/downloader/path_form.dart';
import 'package:intl/intl.dart';
class VideoData{
  int? id;
  String videoPath;
  String youtubeId;
  String thumbnailPath;
  Duration? duration;
  int createdAt;
  double? aspect;
  int? get fileId => id;
  DateTime get createdAtDateTime => DateTime.fromMillisecondsSinceEpoch(createdAt);
  String get createdAtString => DateFormat('yyyy-MM-dd-HH:mm').format(createdAtDateTime);
  String get getVideoPath => videoPath;
  String get getThumbnailPath => thumbnailPath;
  String get durationString => 
  '${duration!.inHours}:${(duration!.inMinutes % 60).toString().padLeft(2, '0')}:${(duration!.inSeconds % 60).toString().padLeft(2, '0')}';
  PathForm get videoPathForm => PathForm.fromPath(videoPath);
  PathForm get thumbnailPathForm => PathForm.fromPath(thumbnailPath);

  VideoData({
    required this.videoPath,
    required this.thumbnailPath,
    required this.youtubeId,
    required this.duration,
    required this.createdAt
  });

  replaceFolder(String oldPath, String newPath){
    videoPath = videoPath.replaceFirst(oldPath, newPath);
    thumbnailPath = thumbnailPath.replaceFirst(oldPath, newPath);
  }
  
  VideoData.fromDb(Map<String, dynamic> map)
    : id = map['id'],
      videoPath = map['video_path'],
      thumbnailPath = map['thumbnail_path'],
      youtubeId = map['youtube_id'],
      createdAt = map['created_at'],
      duration = null;


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
      'created_at': DateTime.now().millisecondsSinceEpoch
    };
  }
}
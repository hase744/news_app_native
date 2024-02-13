import 'package:video_news/models/downloader/file_type.dart';
class FileForm{
  FileType type;

  FileForm({
    required this.type
  });

  FileType get formType {
    return type;
  }
  
  String? get extension {
    switch (type) {
      case FileType.video:
        return '.mp4';
      case FileType.audio:
        return '.mp3';
      case FileType.image:
        return '.jpg';
      default:
        return null;
    }
  }
  factory FileForm.fromPath(String path) {
    FileType? type;
    switch(path.split('.').last) {
    case 'mp4':
      type = FileType.video;
    case 'mp3':
      type = FileType.audio;
    case 'jpg':
      type = FileType.image;
    default:
      type = null;
    }
    return FileForm(
      type: type!
    );
  }
}
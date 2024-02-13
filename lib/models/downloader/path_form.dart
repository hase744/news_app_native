
import 'package:video_news/models/downloader/file_form.dart';
class PathForm{
  String path;
  FileForm form;
  FileForm get fileForm => form;
  String get title => path.split('/').last;

  String get titleWithoutExtension {
    var file = path.split('/').last;
    return file.split('.').first; 
  }

  PathForm({
    required this.path,
    required this.form
  });

  factory PathForm.fromPath(String path) {
    return PathForm(
      form: FileForm.fromPath(path),
      path: path
    );
  }
}
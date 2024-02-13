import 'package:video_news/models/video.dart';
import 'package:video_news/controllers/downloader/downloader_controller.dart';
class DownloadingData{
  double progress;
  VideoForm form;
  DownloaderController controller;
  
  DownloadingData({
    required this.progress,
    required this.form,
    required this.controller
  });
}
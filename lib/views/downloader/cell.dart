import 'package:flutter/material.dart';
import 'package:video_news/models/video.dart';
import 'package:video_news/controllers/downloader/downloader_controller.dart';
class DownLoaderCell extends StatelessWidget {
  double progress;
  double cellHeight;
  double cellWidth;
  //DownloaderController downloaderController;
  //Video video;

  DownLoaderCell({
    required this.progress,
    //required this.downloaderController,
    required this.cellHeight,
    required this.cellWidth,
    //required this.video
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: cellWidth,
      height: cellHeight,
      child:
        Column(children: [
          Container(
            width: cellWidth,
            height: cellHeight/3,
            child: Text(
              "video.title",
              style: TextStyle(
                fontSize: cellHeight/5
              ),
            ),
          ),
          LinearProgressIndicator(
            value: progress,
          ),
        ],
      )
    );
  }
}
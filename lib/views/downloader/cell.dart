import 'package:flutter/material.dart';
import 'package:video_news/models/video.dart';
import 'package:video_news/controllers/downloader/downloader_controller.dart';
class DownLoaderCell extends StatelessWidget {
  double progress;
  double cellWidth;
  VideoForm video;
  //DownloaderController downloaderController;
  //Video video;

  DownLoaderCell({
    required this.progress,
    //required this.downloaderController,
    required this.cellWidth,
    required this.video
  });

  String getPercent(){
    int percent = (progress*100).toInt();
    String percentTwoDegit = percent.toString().padLeft(2, '');
    return '$percentTwoDegit%';
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: cellWidth,
      child:
        Column(children: [
          Container(
            width: cellWidth,
            padding: EdgeInsets.symmetric(horizontal: cellWidth/30),
            child: Text(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              video.title,
              style: TextStyle(
                fontSize: cellWidth/4/6
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(cellWidth/4/5),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade400, //枠線の色
                  width: 1, //枠線の太さ
                ),
              ),
            ),
            child: 
            Row(
              children: [
                if(progress >= 1.0)
                Text(
                  "完了",
                  style: TextStyle(
                    fontSize: cellWidth/30,
                      color: Colors.black87
                  ),
                ),
                if(progress < 1.0)
                Container(
                  margin: EdgeInsets.only(right: cellWidth/30),
                  width: cellWidth/30*23,
                  child:
                  LinearProgressIndicator(
                    value: progress,
                    color: Colors.blue,
                  )
                ),
                if(progress < 1.0)
                Expanded(
                  child: 
                  Text(
                    getPercent(),
                    style: TextStyle(
                      fontSize: cellWidth/30,
                      color: Colors.black87
                    ),
                  ),
                )
              ],
            )
          )
        ],
      )
    );
  }
}
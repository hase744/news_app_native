import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class VideoCellClass extends StatelessWidget {
  final Map video;
  final double cellWidth;
  final double cellHeight;
  final bool isSelected;
  final bool isSelectMode;
  //final BuildContext context; // BuildContext型のcontext変数
  //final void Function(String) openYoutube; // 関数型を使用した変数の定義
  final VoidCallback onPressedYoutube;
  final VoidCallback onPressedOptions;
  final VoidCallback onPressedTitle;
  final VoidCallback onSelected;

  VideoCellClass({
    required this.video,
    required this.cellHeight,
    required this.cellWidth,
    required this.onPressedYoutube,
    required this.onPressedOptions,
    required this.onPressedTitle,
    required this.onSelected,
    required this.isSelected,
    required this.isSelectMode,
  });
  
  secondsToString(int seconds){
    Duration duration = Duration(seconds: seconds);
    int hours = duration.inHours;
    int minutes = (duration.inMinutes % 60);
    int remainingSeconds = (duration.inSeconds % 60);
    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');

    return hoursStr == "00" ? '$minutesStr:$secondsStr' : '$hoursStr:$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    String youtube_id = video['youtube_id'];
    String dateString = "2023-10-16 14:30:00";
    DateTime publishedAt = DateTime.parse(video['published_at']);
    Duration difference = DateTime.now().difference(publishedAt);
    //String differenceStr = "${difference.inDays}日 ${difference.inHours} 時間 ${difference.inMinutes.remainder(60)} 分";
    String differenceHour = "${difference.inHours} 時間前";
    //double cellWidth = _deviceWidth!;
    //double cellHeight = _deviceWidth! / 2 / 16 * 9;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Stack(
              children: [
                Container(
                  color: isSelected ?Colors.grey.shade300 :Colors.white,
                  child:
                  Row(
                    children: [
                      Container(
                        width: (cellWidth / 2)*0.9,
                        height: cellHeight*0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey,
                        ),
                        //color: Colors.red,
                        margin: EdgeInsets.symmetric(horizontal:cellWidth/2*0.05, vertical: cellHeight*0.05),
                        child: InkWell(
                          onTap: onPressedYoutube,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child:Image.network(
                                    "http://img.youtube.com/vi/$youtube_id/sddefault.jpg",
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, o, s) {
                                      return const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      );
                                    },
                                  )
                                ),
                              ),
                              Positioned.fill(
                                child: Center(
                                  child: Opacity(
                                    opacity: isSelectMode ? 1 : 0.7,
                                    child: Icon(
                                      isSelectMode ? (isSelected ? Icons.check_circle_sharp : Icons.check_circle_outline)  : Icons.play_circle,
                                      size: 50,
                                      color: isSelected ?Colors.blue :Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: cellHeight /20,
                                bottom: cellHeight /20,
                                child:
                                Opacity(
                                  opacity: 0.7,
                                  child:
                                  Container(
                                    color: Colors.black,
                                    child: Text(
                                      secondsToString(video['total_seconds']),
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: cellHeight / 10,
                                        color: Colors.white
                                      ),
                                    )
                                  ),
                                )
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: cellWidth / 2,
                        height: cellHeight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: onPressedTitle,
                              child: 
                              Column(
                                children: [
                                  Container(
                                    width: cellWidth / 2,
                                    height: cellHeight / 5 * 3,
                                    child: Text(
                                      video['title'],
                                      style: TextStyle(
                                          fontSize: cellHeight /8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 3,
                                    )
                                  ),
                                  Container(
                                    width: cellWidth / 2,
                                    height: cellHeight / 5,
                                    child: Text(
                                      differenceHour,
                                      style: TextStyle(
                                        fontSize: cellHeight /10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 3,
                                    )
                                  )
                                ],
                              )
                              
                            ),
                            Container(
                              width: cellWidth / 2,
                              height: cellHeight / 5,
                              child: Row(
                                children: [
                                  Container(
                                    width: cellWidth / 2 - 35,
                                    child: Text(
                                      video['channel_name'],
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: cellHeight / 4 / 2,
                                          color: Colors.grey),
                                    )
                                  ),
                                  InkWell(
                                    onTap: onPressedOptions,
                                    child: Container(
                                      height: 35,
                                      width: 35,
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        height: 25,
                                        width: 25,
                                        child: Icon(Icons.more_horiz),
                                      )
                                    )
                                  ),
                                ],
                              )
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                if(isSelectMode)
                InkWell(
                  onTap: onSelected,
                  child: 
                  SizedBox(
                    height: cellHeight,
                    width: cellWidth,
                  )
                ),
              ],
            )
          )
        ],
      ),
    );
  }
}

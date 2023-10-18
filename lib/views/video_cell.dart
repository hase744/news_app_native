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
    final Duration duration = Duration(seconds: seconds);
    String formattedDuration = '';
    if (duration.inHours > 0) {
      formattedDuration += '${duration.inHours.toString().padLeft(2, '0')}:';
    }
    formattedDuration += '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:';
    formattedDuration += '${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    return formattedDuration;
  }

  getFromNow(Duration difference){
    if(difference.inDays < 1){
      return "${difference.inHours}時間前";
    }else{
      return "${difference.inDays}日前";
    }
  }

  @override
  Widget build(BuildContext context) {
    String youtube_id = video['youtube_id'];
    //String dateString = "2023-10-16 14:30:00";
    DateTime publishedAt = DateTime.parse(video['published_at']);
    Duration difference = DateTime.now().difference(publishedAt);
    String differenceStr = getFromNow(difference);
    double horizontalPadding = cellHeight*0.1;
    double verticalPadding = cellWidth*0.015;
    double innerWidth = cellWidth - horizontalPadding*2;
    double centerThreadWidth = innerWidth /30;
    double leftSideWidth = (innerWidth / 2) - centerThreadWidth;
    double rightSideWidth = innerWidth - leftSideWidth - centerThreadWidth;
    double innerHeight = leftSideWidth /16 *9;
    //String differenceStr = "${difference.inDays}日 ${difference.inHours} 時間 ${difference.inMinutes.remainder(60)} 分";
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
                  margin: EdgeInsets.symmetric(horizontal:horizontalPadding, vertical: verticalPadding),
                  child:
                  Row(
                    children: [
                      Container(
                        width: leftSideWidth,
                        height: innerHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey,
                        ),
                        //color: Colors.red,
                        margin: EdgeInsets.only(right: centerThreadWidth),
                        //margin: EdgeInsets.symmetric(horizontal:cellWidth/2*0.05, vertical: cellHeight*0.05),
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
                                    opacity: isSelectMode ? 1 : 0.3,
                                    child: Icon(
                                      isSelectMode ? (isSelected ? Icons.check_circle_sharp : Icons.check_circle_outline)  : Icons.play_arrow,
                                      size: 50,
                                      color: isSelected ?Colors.blue :Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: innerHeight /20,
                                bottom: innerHeight /20,
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
                                        fontSize: innerHeight / 10,
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
                        width: rightSideWidth,
                        height: innerHeight,
                        //color: Colors.red,
                        //margin: EdgeInsets.symmetric(horizontal:innerWidth/2*0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: onPressedTitle,
                              child: 
                              Column(
                                children: [
                                  Container(
                                    width: rightSideWidth,
                                    height: innerHeight / 5 * 3,
                                    child: Text(
                                      video['title'],
                                      style: TextStyle(
                                          fontSize: innerHeight /14 *2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 3,
                                    )
                                  ),
                                  Container(
                                    width: rightSideWidth,
                                    height: innerHeight / 5,
                                    child: Text(
                                      differenceStr,
                                      style: TextStyle(
                                        fontSize: innerHeight /10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 1,
                                    )
                                  )
                                ],
                              )
                              
                            ),
                            Container(
                              width: rightSideWidth,
                              height: innerHeight / 5,
                              child: Row(
                                children: [
                                  Container(
                                    width: rightSideWidth - innerHeight/3,
                                    child: Text(
                                      video['channel_name'],
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: innerHeight / 4 / 2,
                                          color: Colors.grey),
                                    )
                                  ),
                                  InkWell(
                                    onTap: onPressedOptions,
                                    child: Container(
                                      height: innerHeight/2,
                                      width: innerHeight/3,
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        height: innerHeight/5,
                                        width: innerHeight/5,
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
                    height: innerHeight,
                    width: innerWidth,
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

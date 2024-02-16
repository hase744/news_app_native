import 'package:flutter/material.dart';
import 'package:video_news/consts/config.dart';
import 'package:video_news/models/video.dart';
import 'package:video_news/controllers/version_controller.dart';
class VideoCell extends StatefulWidget {
  final VersionController versionController = VersionController();
  final domain = Config.domain;
  final VideoForm video;
  final double cellWidth;
  final double cellHeight;
  final bool isSelected;
  final bool isSelectMode;
  final bool isReleased;
  //final BuildContext context; // BuildContext型のcontext変数
  //final void Function(String) openYoutube; // 関数型を使用した変数の定義
  final VoidCallback onPressedYoutube;
  final VoidCallback onPressedOptions;
  final VoidCallback onPressedTitle;
  final VoidCallback onSelected;
  @override

  VideoCell({
    required this.video,
    required this.cellHeight,
    required this.cellWidth,
    required this.onPressedYoutube,
    required this.onPressedOptions,
    required this.onPressedTitle,
    required this.onSelected,
    required this.isSelected,
    required this.isSelectMode,
    required this.isReleased,
  });

  @override
  State<VideoCell> createState() => _VideoCellState();
}
class _VideoCellState extends State<VideoCell>  with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    String youtube_id = widget.video.youtubeId;
    //String dateString = "2023-10-16 14:30:00";
    double horizontalPadding = widget.cellHeight*0.1;
    double verticalPadding = widget.cellWidth*0.015;
    double innerWidth = widget.cellWidth - horizontalPadding*2;
    double centerThreadWidth = innerWidth /30;
    double leftSideWidth = (innerWidth / 2) - centerThreadWidth;
    double rightSideWidth = innerWidth - leftSideWidth - centerThreadWidth;
    double innerHeight = leftSideWidth /16 *9;
    //String differenceStr = "${difference.inDays}日 ${difference.inHours} 時間 ${difference.inMinutes.remainder(60)} 分";
    //double widget.cellWidth = _deviceWidth!;
    //double widget.cellHeight = _deviceWidth! / 2 / 16 * 9;
    return Container(
      color: widget.isSelected ?Colors.grey.shade300 :Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Stack(
              children: [
                Container(
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
                        //margin: EdgeInsets.symmetric(horizontal:widget.cellWidth/2*0.05, vertical: widget.cellHeight*0.05),
                        child: InkWell(
                          onTap: widget.onPressedYoutube,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child:Image.network(
                                    widget.isReleased ? "http://img.youtube.com/vi/$youtube_id/sddefault.jpg" : '${widget.domain}/images/${youtube_id}.jpg',
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, o, s) {
                                      return  Image.asset(
                                        "assets/images/no_image.png",
                                        fit: BoxFit.cover,
                                      );
                                      //const Icon(
                                      //  Icons.error,
                                      //  color: Colors.red,
                                      //);
                                    },
                                  )
                                ),
                              ),
                              Positioned.fill(
                                child: Center(
                                  child: Opacity(
                                    opacity: widget.isSelectMode ? 1 : 0.3,
                                    child: Icon(
                                      widget.isSelectMode ? (widget.isSelected ? Icons.check_circle_sharp : Icons.check_circle_outline)  : Icons.play_arrow,
                                      size: 50,
                                      color: widget.isSelected ?Colors.blue :Colors.white,
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
                                      widget.video.getReadableDuration(),
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: innerHeight / 10,
                                        color: Colors.white
                                      )
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
                              onTap: widget.onPressedTitle,
                              child: 
                              Column(
                                children: [
                                  Container(
                                    width: rightSideWidth,
                                    height: innerHeight / 5 * 3,
                                    child: Text(
                                      widget.video.title,
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
                                      widget.video.getFromNow(),
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
                                      widget.video.channelName,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: innerHeight / 4 / 2,
                                          color: Colors.grey),
                                    )
                                  ),
                                  InkWell(
                                    onTap: widget.onPressedOptions,
                                    child: Container(
                                      height: innerHeight/2,
                                      width: innerHeight/3,
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        height: innerHeight/5,
                                        width: innerHeight/5,
                                        child: const Icon(
                                          Icons.more_horiz,
                                          color: Colors.black54,
                                          ),
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
                if(widget.isSelectMode)
                InkWell(
                  onTap: widget.onSelected,
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

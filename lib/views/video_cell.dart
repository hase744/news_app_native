import 'package:flutter/material.dart';
class VideoCellClass extends StatelessWidget {
  final Map press;
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
    required this.press,
    required this.cellHeight,
    required this.cellWidth,
    required this.onPressedYoutube,
    required this.onPressedOptions,
    required this.onPressedTitle,
    required this.onSelected,
    required this.isSelected,
    required this.isSelectMode,
    });

  @override
  Widget build(BuildContext context) {
    String youtube_id = press['youtube_id'];
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
                  color: isSelected ?Colors.blue :Colors.white,
                  child:
                  Row(
                    children: [
                      Container(
                        width: (cellWidth / 2)*0.9,
                        height: cellHeight*0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blue,
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
                                    opacity: 0.5,
                                    child: Icon(
                                      Icons.play_circle,
                                      size: 50,
                                      color: isSelected ?Colors.blue :Colors.white,
                                    ),
                                  ),
                                ),
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
                              child: Container(
                                width: cellWidth / 2,
                                height: cellHeight / 4 * 3,
                                child: Text(
                                  press['title'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 3,
                                )
                              )
                            ),
                            Container(
                              width: cellWidth / 2,
                              height: cellHeight / 4,
                              child: Row(
                                children: [
                                  Container(
                                    width: cellWidth / 2 - 35,
                                    child: Text(
                                      press['channel_name'],
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

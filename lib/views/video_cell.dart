import 'package:flutter/material.dart';
class VideoCellClass extends StatelessWidget {
  final Map press;
  final double cellWidth;
  final double cellHeight;
  //final BuildContext context; // BuildContext型のcontext変数
  //final void Function(String) openYoutube; // 関数型を使用した変数の定義
  final VoidCallback onPressedYoutube;
  final VoidCallback onPressedOptions;
  final VoidCallback onPressedTitle;

  VideoCellClass({
    required this.press,
    required this.cellHeight,
    required this.cellWidth,
    required this.onPressedYoutube,
    required this.onPressedOptions,
    required this.onPressedTitle
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
            child: Row(
              children: [
                Container(
                  width: cellWidth / 2,
                  height: cellHeight,
                  color: Colors.red,
                  child: InkWell(
                    onTap: onPressedYoutube,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            "http://img.youtube.com/vi/$youtube_id/sddefault.jpg",
                            fit: BoxFit.cover,
                            errorBuilder: (c, o, s) {
                              return const Icon(
                                Icons.error,
                                color: Colors.red,
                              );
                            },
                          ),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: Opacity(
                              opacity: 0.5,
                              child: Icon(
                                Icons.play_circle,
                                size: 50,
                                color: Colors.white,
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
                                maxLines: 3,
                              ))),
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
                                  )),
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
                                      ))),
                            ],
                          ))
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
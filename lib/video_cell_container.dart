import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:sqflite/sqflite.dart';

class VideoCellContainer extends StatefulWidget {
  final Map press; // Map型のpress変数
  final BuildContext context; // BuildContext型のcontext変数
  final YoutubePlayerController youtubeController;
  final void Function(String) openYoutube; // 関数型を使用した変数の定義

  VideoCellContainer({
    Key? key,
    required this.press,
    required this.context,
    required this.youtubeController,
    required this.openYoutube,
  }) : super(key: key);

  @override
  _VideoCellContainerState createState() => _VideoCellContainerState();
}

class _VideoCellContainerState extends State<VideoCellContainer> {
  double? _deviceWidth, _deviceHeight;
  Map _press = {}; // Map型のpress変数
  BuildContext? _context; // BuildContext型のcontext変数
  YoutubePlayerController? _youtubeController;
  void Function(String)? _openYoutube; // 関数型を使用した変数の定義

  @override
  void initState() {
    super.initState();
      _context = widget.context;
      _press = widget.press;
      _openYoutube = widget.openYoutube;
      _youtubeController = widget.youtubeController;
      _deviceWidth = MediaQuery.of(_context!).size.width;
      _deviceHeight = MediaQuery.of(_context!).size.height;
  }

  modalWindow(String youtubeId, BuildContext context) {
    //String value = "";
    List? values;
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        //mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextButton(
            child: Container(
              width: _deviceWidth,
              child: Center(
                child:Text(
                "＋お気に入りに追加",
                style: TextStyle(
                    fontSize: _deviceWidth!/15,
                    color: Colors.grey
                  ),
                )
              ),
            ),
            style: OutlinedButton.styleFrom(
              primary: Colors.black,
            ),
            onPressed: () async {
              //final prefs = await SharedPreferences.getInstance();
              //values = stringToList(prefs.getString("favoriteYoutubeIds")!);
              //values!.add(youtubeId);
              //prefs.setString('favoriteYoutubeIds', values!.join(','));
              print("お気に入り追加");
              Navigator.of(context).pop();
            },
          ),
        ]),
        height: 500,
        alignment: Alignment.center,
        width: double.infinity,
        decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 20,
          )
        ],
      ),
    );
  }

  Widget videoCell(BuildContext context, Map press){
    String youtube_id = press['youtube_id'];
    double cellWidth = _deviceWidth!;
    double cellHeight = _deviceWidth!/2/16*9;
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
                    onTap: () {
                      // onPressed イベントの処理をここに書きます
                      print('Container tapped!');
                      setState(() {
                        _openYoutube!(youtube_id);
                        _youtubeController!.load( youtube_id,startAt:0);
                      });
                    },
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
                  width: cellWidth/2,
                  height: cellHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: cellWidth/2,
                        height: cellHeight/4*3,
                        child:
                        Text(
                          press['title'],
                          maxLines: 3,
                        )
                      ),
                      Container(
                        width: cellWidth/2,
                        height: cellHeight/4,
                        child:Row(
                          children:[
                            Container(
                              width: cellWidth/2 - 25,
                              //color: Colors.blue,
                              child: Text(
                                press['channel_name'],
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: cellHeight/4/2,
                                  color: Colors.grey
                                ),
                              )
                            ),
                            InkWell(
                              onTap: () {
                                print("押された");
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return modalWindow(youtube_id, context);
                                  },
                                );
                              },
                              child:Container(
                                height: 25,
                                width: 25,
                                //color: Colors.red,
                                child: Icon(Icons.more_horiz),
                              )
                            ),
                          ],
                        )
                      )
                    ])
                )
              ]
            )
          )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return videoCell(_context!, _press);
    //return Text(_press['youtube_id']);
  }
}
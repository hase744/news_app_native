import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
   List<Color> colors = [
    const Color.fromRGBO(250, 100, 100, 1),
    const Color.fromRGBO(250, 140, 60, 1),
    const Color.fromRGBO(90, 255, 109, 1),
    const Color.fromRGBO(90, 145, 255, 1),
    const Color.fromRGBO(184, 91, 255, 1),
   ];
   double? _deviceWidth, _deviceHeight;
   String? _categories = "";
   List _press = [];
   List _categoriesJson = [];
   List<Widget> _videoCells = [Container(
                    height: 200,
                    color: Colors.green,
                  ),
                  Container(
                    height: 200,
                    color: Colors.blue,
                  ),
                  Container(
                    height: 200,
                    color: Colors.red,
                  ),
                  Container(
                    height: 200,
                    color: Colors.yellow,
                  ),];
   String _category_name = "ビジネス";
   Color _color = Color.fromRGBO(250, 100, 100, 1);
   final prefs = SharedPreferences.getInstance();
  @override
  void initState() {
    final prefs = SharedPreferences.getInstance();
    init();
    // ここに初期化時に実行したい特定の処理を記述します
    // 例えば、API呼び出しやデータの読み込みなどです
    print("HomePage initialized"); // これは例です
  }
  void init() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      //　データの読み込み
      _categories = prefs.getString('categories')!;
      _categoriesJson = json.decode(_categories!);
      SelectCategory(0);
    });
  }

  double fontSize(int text_count) {
    double fontSize = 0;
    if(text_count < 4){
      fontSize = _deviceWidth!/20;
    }else{
      fontSize = _deviceWidth!/5/text_count;
    }
    return fontSize -1;
  }

  void SelectCategory(int category_num){
    setState(() {
      _category_name = _categoriesJson[category_num]['japanese_name'];
      _color =  colors[category_num % colors.length];
      _videoCells = [];
      _press = json.decode(_categoriesJson[category_num]['press']);
      print("OK");
      for(var i=0; i < _press.length; i++){
        _videoCells.add(
          VideoCell(i)
        );
      }
    });
  }

  Widget VideoCell(int video_num){
    String youtube_id = _press[video_num]['youtube_id'];
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
                  width: cellWidth/2,
                  height: cellHeight,
                  color: Colors.red,
                  child:Stack(
                    children: [
                      Positioned.fill(
                        child: 
                        Image.network(
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
                          )
                          
                        ),
                      ),
                    ],
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
                        child:Text(
                          _press[video_num]['title'],
                          maxLines: 3,
                        )
                      ),
                      Container(
                        width: cellWidth/2,
                        height: cellHeight/4,
                        child:Text(
                          _press[video_num]['channel_name'],
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: cellHeight/4/2,
                            color: Colors.grey
                          ),
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
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    final container_width = _deviceWidth!/5;
    final container_height = _deviceWidth!/10;
    _categoriesJson = json.decode(_categories!);
    for (var item in _categoriesJson) {
      String japaneseName = item['japanese_name'];
      print(japaneseName);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("$_category_name"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < _categoriesJson.length; i++)
                  Container(
                    color: colors[i % colors.length],
                    width: container_width,
                    height: container_height,
                    padding: EdgeInsets.all(0),
                    margin: EdgeInsets.all(0),
                    child:TextButton(
                      onPressed: () {
                        SelectCategory(i);
                      },
                      child: Text(
                        _categoriesJson[i]['japanese_name'],
                        style: TextStyle(
                          fontSize: fontSize(_categoriesJson[i]['japanese_name'].length),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(0), // ボタンの内側の余白
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0), // 角丸の半径
                        ),
                      ),
                    )
                  ),
              ],
            ),
          ),
          Container(
                    color: _color,
                    width: _deviceWidth,
                    height: 5,
                    ),
          Container(
            height: (_deviceHeight! - 200),
            //margin: EdgeInsets.only(bottom: 100),
            child: SingleChildScrollView(
              child: Column(
                children: _videoCells,
              ),
            )
          ),
        ],
      )   
    );
  }
}


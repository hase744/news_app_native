import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
   double? _deviceWidth, _deviceHeight;
   String? _categories = "";
   final prefs = SharedPreferences.getInstance();
   List<Color> colors = [
    const Color.fromRGBO(250, 100, 100, 1),
    const Color.fromRGBO(250, 140, 60, 1),
    const Color.fromRGBO(90, 255, 109, 1),
    const Color.fromRGBO(90, 145, 255, 1),
    const Color.fromRGBO(184, 91, 255, 1),
   ];
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
      print("カテゴリー");
      print(_categories);
    });
  }

  double fontSize(int text_count) {
    double fontSize = 0;
    if(text_count < 4){
      fontSize = _deviceWidth!/20;
    }else{
      fontSize = _deviceWidth!/5/text_count;
    }
    print(text_count);
    print(fontSize);
    return fontSize -1;
  }

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    final container_width = _deviceWidth!/5;
    final container_height = _deviceWidth!/10;
    final categories = json.decode(_categories!);
    for (var item in categories) {
      String japaneseName = item['japanese_name'];
      print(japaneseName);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_categories!),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < categories.length; i++)
                  Container(
                    color: colors[i % colors.length],
                    width: container_width,
                    height: container_height,
                    padding: EdgeInsets.all(0),
                    margin: EdgeInsets.all(0),
                    child:TextButton(
                      onPressed: () {},
                      child: Text(
                        categories[i]['japanese_name'],
                        style: TextStyle(
                          fontSize: fontSize(categories[i]['japanese_name'].length),
                          color: Colors.black,
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
            height: (_deviceHeight! - 200),
            //margin: EdgeInsets.only(bottom: 100),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
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
                  ),
                ],
              ),
            )
          ),
        ],
      )   
    );
  }
}


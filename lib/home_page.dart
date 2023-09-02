import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'bottom_navigation_bar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'history.dart';
import 'favorite.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Color> colors = [
   const Color.fromRGBO(250, 100, 100, 1),
   const Color.fromRGBO(250, 140, 60, 1),
   const Color.fromRGBO(90, 255, 110, 1),
   const Color.fromRGBO(90, 145, 255, 1),
   const Color.fromRGBO(185, 90, 255, 1),
  ];
  double? _deviceWidth, _deviceHeight, _innerHeight;
  String? _categories = "";
  List _press = [];
  List _categoriesJson = [];
  YoutubePlayerController youtubeController = YoutubePlayerController(
    initialVideoId: '4b6DuHGcltI',
    flags: YoutubePlayerFlags(
        autoPlay: false,  // 自動再生しない
      ),
    );
  ScrollController _scrollController = ScrollController();
  bool displayYoutube = true;
  var history = History(); 
  var favorite = Favorite(); // History クラスのインスタンスを作成
   
  Map<String, double> layoutHeight = {};
  String _categoryName = "ビジネス";
  Color _color = Color.fromRGBO(250, 100, 100, 1);
  int currentIndex = 0;
  int currentCategoryIndex = 0;
  int _pressUnitCount = 8;
  late int _pressCount =  _pressUnitCount;
  bool _displayLoadingScreen = false;
  String? _alert;
  final prefs = SharedPreferences.getInstance();

  late List<Map<dynamic, dynamic>> mixedMap = [
    {
    "name": 'home',
    "item":BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム')
    },
    {
    "name": 'favorite',
    "item":BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'お気に入り')
    },
    {
    "name": 'history',
    "item":BottomNavigationBarItem(icon: Icon(Icons.history), label: '履歴')
    },
    {
    "name": 'setting',
    "item":BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定')
    },
  ];

  @override
  void initState() {
    init();
  }

  void init() async {
    final prefs = await SharedPreferences.getInstance();
    String defaultYoutubeId = prefs.getString('default_youtube_id')!;
    setState(() {
      //youtubeController.load(lastYoutubeId,startAt:0);
      var _padding = MediaQuery.of(context).padding;
      _deviceWidth = MediaQuery.of(context).size.width;
      _deviceHeight = MediaQuery.of(context).size.height;
      _innerHeight = _deviceHeight! - _padding.top - _padding.bottom;
      _categories = prefs.getString('categories')!;
      _categoriesJson = json.decode(_categories!);
      favorite.deleteTable;
      youtubeController =  YoutubePlayerController(
        initialVideoId: defaultYoutubeId,
        flags: YoutubePlayerFlags(
          autoPlay: false,  // 自動再生しない
        ),);
    });
    await displayNews();
    resetPressCount();
  }

  Future<void> displayHistory() async {
    print("履歴");
    _press = [];
    await history.initDatabase();
    List<Map<String, dynamic>> histories = await history.all();
    histories = histories.reversed.toList();// あなたの非同期処理;
    setState(() {
      setDefauldLayout();
      layoutHeight['category_bar'] = 0;
      layoutHeight['category_bar_line'] = 0;
      layoutHeight['youtube_display'] = 0;
      print(layoutHeight);
      setNesCellsHeight();
      _press = histories; // 取得したデータを _press 変数に代入
      resetPressCount();
    });
  }

  void resetPressCount(){
    setState(() {
      _displayLoadingScreen = false;
      _pressCount =  _pressUnitCount;
      if (_pressCount > _press.length) {
        _pressCount = _press.length;
      }
    });
  }

  Future<void> displayNews() async {
    setState(() {
      setDefauldLayout();
      SelectCategory(currentCategoryIndex);
    });
    resetPressCount();
  }

  Future<void> displayFavorites() async {
    _press = [];
    await favorite.initDatabase();
    await Future.delayed(Duration.zero);
    List<Map<String, dynamic>> favorites = await favorite.all();
    favorites = favorites.reversed.toList();// あなたの非同期処理;
    print(favorites);
    setState(() {
      setDefauldLayout();
      layoutHeight['category_bar'] = 0;
      layoutHeight['category_bar_line'] = 0;
      layoutHeight['youtube_display'] = 0;
      print(layoutHeight);
      setNesCellsHeight();
      _press = favorites; // 取得したデータを _press 変数に代入
      print("総数${_press.length}");
      print("表示数${_pressCount}");
      resetPressCount();
    });
    print("お気に入り");
  }

  void setDefauldLayout(){
    HomeBottomNavigationBar bar = HomeBottomNavigationBar(initialIndex: 0);
    layoutHeight = {
      'app_bar':40,
      'category_bar':_deviceWidth!/10,
      'category_bar_line':5,
      'youtube_display':_deviceWidth!/16*9,
      'bottom_nabigation_bar': bar.height,
      'alert':0
    };
    setNesCellsHeight();
    print(layoutHeight);
  }

  void setNesCellsHeight(){
    layoutHeight['news_cells'] = 0;
    layoutHeight['news_cells'] = _innerHeight! - layoutHeight.values.reduce((a, b) => a + b) - 2;
  }

  void openYoutube(Map press) async {
    String youtube_id = press["youtube_id"];
    layoutHeight['youtube_display'] = _deviceWidth!/16*9;
    setNesCellsHeight();
    displayYoutube = true;
    //最後に再生した動画を保存機能
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(Duration.zero);
    youtubeController.load( youtube_id,startAt:0);
    await prefs.setString('default_youtube_id', youtube_id);
    await history.initDatabase(); 
    List<Map<String, dynamic>> histories = await history.all();
    print(histories);
    await history.create(press);
  }

  void closeYoutube(){
    layoutHeight['youtube_display'] = 0;
    setNesCellsHeight();
    youtubeController.pause();
    displayYoutube = false;
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

  Future<void> SelectCategory(int category_num) async {
    setState(() {
      closeYoutube();
      _categoryName = _categoriesJson[category_num]['japanese_name'];
      _color =  colors[category_num % colors.length];
    });
    _press = await json.decode(_categoriesJson[category_num]['press']);
    print("総数${_press.length}");
  }

  String listToString(List<String> list) {
    return list.map<String>((String value) => value).join(',');
  }
  
  modalWindow(Map press, BuildContext context) {
    bool isFavorite = mixedMap[currentIndex]['name'] == 'favorite';
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
                isFavorite ? "ーお気に入りから削除" : "＋お気に入りに追加",
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
              isFavorite ? favorite.delete(press['id']) : favorite.create(press);
              updateScreen();
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
  
  void updateScreen(){
    switch(mixedMap[currentIndex]['name']) {
      case 'home':
        displayNews();
        break;
      case 'favorite':
        displayFavorites();
        break;
      case 'history':
        displayHistory();
        break;
      default:
        break;
    }
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
                        openYoutube(press);
                        youtubeController.load( youtube_id,startAt:0);
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
                              width: cellWidth/2 - 35,
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
                                    return modalWindow(press, context);
                                  },
                                );
                              },
                              child:Container(
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
    final container_width = _deviceWidth!/5;
    final container_height = layoutHeight['category_bar'];

    _categoriesJson = json.decode(_categories!);
    List<BottomNavigationBarItem> itemList = mixedMap.map((map) => map["item"]).toList()
    .whereType<BottomNavigationBarItem>() // BottomNavigationBarItem型の要素のみ抽出
    .toList();

    return Scaffold(
      appBar: PreferredSize(
         preferredSize: Size.fromHeight(layoutHeight['app_bar']!),
         child: AppBar(
           title: Text("$_categoryName"),
         ),
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
                      setState(() {
                        currentCategoryIndex = i;
                      });
                      SelectCategory(currentCategoryIndex);
                      resetPressCount();
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
            height: layoutHeight['category_bar_line'],
          ),
          if(_alert != null)
          Container(
            height: layoutHeight['alert'],
            child: Text(_alert!),
          ),
          Container(
            height: layoutHeight['youtube_display'],
            color: Colors.red,
            child:
            YoutubePlayer(
              controller: youtubeController,
              //controller: YoutubePlayerController(initialVideoId: youtubeId),
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.blueAccent,
            ),
          ),
          Flexible(    
            //Flexibleでラップ
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollNotification) {
                if (scrollNotification is ScrollEndNotification) {
                  final before = scrollNotification.metrics.extentBefore;
                  final max = scrollNotification.metrics.maxScrollExtent;
                  if (before == max) {
                    print("した");
                    setState(() {
                      //挿入可能な記事があれば記事を挿入
                      _pressCount += _pressUnitCount;
                      if (_pressCount > _press.length) { //ロード過多
                        _pressCount = _press.length;
                        _displayLoadingScreen = false;
                      }else{
                        _displayLoadingScreen = true;
                      }
                    });
                  }
                }//
                return false;
              },
              child: 
              ListView(
                controller: _scrollController,
                children: [
                for(var i=0; i<_pressCount; i++)
                  videoCell(context, _press[i]),
                if(_displayLoadingScreen)
                Container(
                  alignment: Alignment.center,
                  width: _deviceWidth,
                  child: 
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 8.0,
                        backgroundColor: Colors.black,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)
                        ),
                    ),
                  )
                ],
              )
              //for(var i=0; i<_press.length; i++)
              //    videoCell(context, _press[i]);
              //  ],
              //ListView.builder(
              //  itemCount: _press.length,
              //  itemBuilder: (BuildContext context, int position) {
              //    return videoCell(context, _press[position]);
              //  },
              //),
            )
          ),
        ],
      ),
      //bottomNavigationBar: HomeBottomNavigationBar(initialIndex: 0)
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            _pressCount = 0;
            currentIndex = index;
            youtubeController.pause();
          });
          updateScreen();
        },
        items: itemList,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}


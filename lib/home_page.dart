import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'bottom_navigation_bar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'history.dart';


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
   bool displayYoutube = true;
  var history = History();  // History クラスのインスタンスを作成
   
   Map<String, double> layout_height = {};
   String _category_name = "ビジネス";
   Color _color = Color.fromRGBO(250, 100, 100, 1);
   int currentIndex = 0;

  late List<Map<dynamic, dynamic>> mixedMap = [
    {
    "name": 'home',
    "item":BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム')
    },
    {
    "name": 'history',
    "item":BottomNavigationBarItem(icon: Icon(Icons.history), label: '履歴')
    },
    {
    "name": 'notification',
    "item":BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'お知らせ')
    },
    {
    "name": 'setting',
    "item":BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定')
    },
  ];

  Future<void> displayHistory() async {
    print("履歴");
    _press = [];
    await history.initDatabase();
    List<Map<String, dynamic>> histories = await history.all();
    histories = histories.reversed.toList();// あなたの非同期処理;
    setState(() {
      setDefauldLayout();
      layout_height['category_bar'] = 0;
      layout_height['category_bar_line'] = 0;
      layout_height['youtube_display'] = 0;
      print(layout_height);
      set_news_cells_height();
      _press = histories; // 取得したデータを _press 変数に代入
    });
  }

  Future<void> displayNews() async {
    print("ニュース");
    setState(() {
      setDefauldLayout();
      SelectCategory(0);
    });
  }

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
      var _padding = MediaQuery.of(context).padding;
      _deviceWidth = MediaQuery.of(context).size.width;
      _deviceHeight = MediaQuery.of(context).size.height;
      _innerHeight = _deviceHeight! - _padding.top - _padding.bottom;
      _categories = prefs.getString('categories')!;
      _categoriesJson = json.decode(_categories!);
      //_deleteHistoriesTable();
      setDefauldLayout();
      SelectCategory(0);
    });
  }

  void setDefauldLayout(){
    HomeBottomNavigationBar bar = HomeBottomNavigationBar(initialIndex: 0);
    layout_height = {
      'app_bar':40,
      'category_bar':_deviceWidth!/10,
      'category_bar_line':5,
      'youtube_display':_deviceWidth!/16*9,
      'bottom_nabigation_bar': bar.height,
    };
    set_news_cells_height();
    print(layout_height);
  }

  void set_news_cells_height(){
    layout_height['news_cells'] = 0;
    layout_height['news_cells'] = _innerHeight! - layout_height.values.reduce((a, b) => a + b) - 2;
  }

  void openYoutube(Map press) async {
    String youtube_id = press["youtube_id"];
    layout_height['youtube_display'] = _deviceWidth!/16*9;
    set_news_cells_height();
    displayYoutube = true;
    await Future.delayed(Duration.zero);
    youtubeController.load( youtube_id,startAt:0);
    await history.initDatabase(); 
    List<Map<String, dynamic>> histories = await history.all();
    print(histories);
    await history.create(press);
  }

  void closeYoutube(){
    layout_height['youtube_display'] = 0;
    set_news_cells_height();
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

  void SelectCategory(int category_num) {
    setState(() {
      closeYoutube();
      _category_name = _categoriesJson[category_num]['japanese_name'];
      _color =  colors[category_num % colors.length];
      _press = json.decode(_categoriesJson[category_num]['press']);
    });
  }

  Future<Database> openDatabaseConnection() async {
  final dbPath = await getDatabasesPath();
  final path = p.join(dbPath, 'my_database.db');
  return await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute(
        'CREATE TABLE my_table(id INTEGER PRIMARY KEY, name TEXT)',
      );
    },
  );
}

  String listToString(List<String> list) {
    return list.map<String>((String value) => value).join(',');
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

  Widget VideoCell(BuildContext context, Map press){
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
    final container_width = _deviceWidth!/5;
    final container_height = layout_height['category_bar'];

    _categoriesJson = json.decode(_categories!);
    List<BottomNavigationBarItem> itemList = mixedMap.map((map) => map["item"]).toList()
    .whereType<BottomNavigationBarItem>() // BottomNavigationBarItem型の要素のみ抽出
    .toList();

    for (var item in _categoriesJson) {
      String japaneseName = item['japanese_name'];
      print(japaneseName);
    }
    return Scaffold(
      appBar: PreferredSize(
         preferredSize: Size.fromHeight(layout_height['app_bar']!),
         child: AppBar(
           title: Text("$_category_name"),
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
            height: layout_height['category_bar_line'],
            ),
          Container(
            height: layout_height['youtube_display'],
            color: Colors.red,
            child:
            YoutubePlayer(
              controller: youtubeController,
              //controller: YoutubePlayerController(initialVideoId: youtubeId),
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.blueAccent,
            ),
          ),
          Container(
            height: layout_height['news_cells'],
            //margin: EdgeInsets.only(bottom: 100),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var i = 0; i < _press.length; i++)
                    VideoCell(context, _press[i])
                    //VideoCellContainer(
                    //  press:_press[i],
                    //  context: context,
                    //  youtubeController: youtubeController,
                    //  openYoutube: openYoutube,
                    //)
                ],
              ),
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
            currentIndex = index;
          });
          switch(mixedMap[currentIndex]['name']) {
            case 'home':
              displayNews();
              break;
            case 'history':
              displayHistory();
              break;
            case 'notification':
              displayNews();
              break;
            default:
              break;
          }
        },
        items: itemList,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}


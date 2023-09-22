import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'bottom_navigation_bar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'history.dart';
import 'favorite.dart';
import 'setting_page.dart';
import 'category_setting.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/scheduler.dart';
import 'setting_page.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'web_window.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'models/layout_height.dart';
import 'controllers/default_values_controller.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>  {
  List<Color> colors = [
   const Color.fromRGBO(250, 100, 100, 1),
   const Color.fromRGBO(250, 140, 60, 1),
   const Color.fromRGBO(90, 255, 110, 1),
   const Color.fromRGBO(90, 145, 255, 1),
   const Color.fromRGBO(185, 90, 255, 1),
  ];
  double? _deviceWidth, _deviceHeight, _innerHeight;
  String? _pressesJson = "";
  List _press = [];
  List _presses = [];
  YoutubePlayerController youtubeController = YoutubePlayerController(
    initialVideoId: '4b6DuHGcltI',
    flags: YoutubePlayerFlags(
        autoPlay: false,  // 自動再生しない
      ),
    );
  ScrollController _innerScrollController = ScrollController();
  ScrollController _outerScrollController = ScrollController();
  bool ableInnerScroll = false;
  bool ableOuterScroll = true;
  bool displayYoutube = true;
  var history = History(); 
  var favorite = Favorite(); // History クラスのインスタンスを作成
  var category_setting = CategorySetting();
  LayoutHeight layoutHeight = LayoutHeight(deviceWidth:0, deviceHeight: 0, barHeight:0, innerHeight: 0);
  DefaultValue defaultValue = DefaultValue();
  String _categoryName = "ビジネス";
  Color _color = Color.fromRGBO(250, 100, 100, 1);
  int currentIndex = 0;
  int currentCategoryIndex = 0;
  int _pressUnitCount = 20;
  int _scrollUperCount = 0;
  late int _pressCount =  _pressUnitCount;
  bool _displayLoadingScreen = false;
  String? _alert;
  Future<void>? _launched;
  String mode = 'normal';
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
    super.initState();
    init();
  }

  void init() async {
    await defaultValue.initialize();
    String? defaultYoutubeId = defaultValue.getStoredValue('default_youtube_id');
    category_setting = CategorySetting();
    List presses = await category_setting.getPressOrder();
    setState(() {
      var _padding = MediaQuery.of(context).padding;
      _deviceWidth = MediaQuery.of(context).size.width;
      _deviceHeight = MediaQuery.of(context).size.height;
      _innerHeight = _deviceHeight! - _padding.top - _padding.bottom;
      category_setting = CategorySetting();
      _presses = presses;
      favorite.deleteTable;
      youtubeController =  YoutubePlayerController(
        initialVideoId: defaultYoutubeId!,
        flags: YoutubePlayerFlags(
          autoPlay: false,  // 自動再生しない
        ),);
      _innerScrollController = ScrollController(initialScrollOffset: _deviceWidth!/10);
    });

    _innerScrollController.addListener(() {
      setOffset();
    });
    SettingPage settingPage = SettingPage();
    await displayNews();
    resetPressCount();
  }

  setOffset(){
    setState(() {
      double offset = _innerScrollController.offset;
      layoutHeight.scrollOffset = offset.clamp(0.0, layoutHeight.menu_area);//menuが見える時以外offsetは0にする
    });
  }

  Future<void> displayHistory() async {
    _press = [];
    await history.initDatabase();
    List<Map<String, dynamic>> histories = await history.all();
    histories = histories.reversed.toList();// あなたの非同期処理;
    setState(() {
      setDefauldLayout();
      layoutHeight.setForDefault();

      layoutHeight.setForNewsCellsHeight();
      _press = histories; // 取得したデータを _press 変数に代入
      resetPressCount();
      _outerScrollController.jumpTo(0);
    });
    setForInnerScroll();
  }

  Future<void> displayNews() async {
    setDefauldLayout();
    await SelectCategory(currentCategoryIndex);
    resetPressCount();
    setState(() {
      _innerScrollController.jumpTo(_deviceHeight!/10);
    });
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
      layoutHeight.setForDefault();

      layoutHeight.setForNewsCellsHeight();
      _press = favorites; // 取得したデータを _press 変数に代入
      resetPressCount();
      _outerScrollController.jumpTo(0);
    });
    setForInnerScroll();
    print("お気に入り");
  }

  void setForOuterScroll(){
    setState(() {
      ableInnerScroll = false;
      ableOuterScroll = true;
    });
  }
  void setForInnerScroll(){
    setState(() {
      ableInnerScroll = true;
      ableOuterScroll = false;
    });
  }

  void setDefauldLayout(){
    HomeBottomNavigationBar bar = HomeBottomNavigationBar(initialIndex: 0);
    setState(() {
      var _padding = MediaQuery.of(context).padding;
      layoutHeight = LayoutHeight(
        deviceWidth: _deviceWidth!,
        deviceHeight: _deviceHeight!,
        barHeight: bar.height,
        innerHeight: _deviceHeight! - _padding.top - _padding.bottom
      );
      //_innerScrollController.jumpTo(100.0);
    });
    layoutHeight.setForNewsCellsHeight();
  }

  void openYoutube(Map press) async {
    String youtube_id = press["youtube_id"];
    print("youtube 開く");
    layoutHeight.displayYoutube();
    layoutHeight.setForNewsCellsHeight();
    //最後に再生した動画を保存機能
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(Duration.zero);
    setState(() {
      youtubeController.load( youtube_id,startAt:0);
    });
    await prefs.setString('default_youtube_id', youtube_id);
    await history.initDatabase(); 
    List<Map<String, dynamic>> histories = await history.all();
    await history.create(press);
  }

  void closeYoutube(){
    layoutHeight.hideYoutube();
    layoutHeight.setForNewsCellsHeight();
    youtubeController.pause();
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
    List press = await json.decode(_presses[category_num]['press']);
    setState(() {
      closeYoutube();
      _categoryName = _presses[category_num]['japanese_name'];
      _color =  colors[category_num % colors.length];
      _press = press;
    });
    print("カテゴリ");
    print(_press);
  }

  Future<void> resetCategory(int category_num) async {
    await SelectCategory(category_num);
    await resetPressCount();
  }

  Future<void> resetPressCount() async {
    setState(() {
      _displayLoadingScreen = false;
      _pressCount =  _pressUnitCount;
      if (_pressCount > _press.length) {
        _pressCount = _press.length;
      }
    });
  }

  String listToString(List<String> list) {
    return list.map<String>((String value) => value).join(',');
  }

  settingWindow(BuildContext context){
    SettingPage settingPage = SettingPage();
    return settingPage;
    //category_setting;
  }

  Future<void> _launchInWebViewOrVC(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $url');
    }
  }

  webViewWindow(String youtube_id,BuildContext context) {
    print("https://emma.tools/magazine/ai-writing-blog/#AI");
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse("https://emma.tools/magazine/ai-writing-blog/#AI"),
      );
    return
    Container(
      height: _deviceHeight!*0.7,
      child: WebViewWidget(
        controller: controller,
      ),
    );
  }
  
  modalWindow(Map press, BuildContext context, String mode) {
    bool isFavorite = mixedMap[currentIndex]['name'] == 'favorite';
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        //mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          if(mode == 'each_video')
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
          if(mode == 'menu')
          TextButton(
            child: Container(
              width: _deviceWidth,
              child: Center(
                child:Text(
                "選択",
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
          ]
        ),
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
      case 'setting':
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>SettingPage()),
          );
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
                      InkWell(
                      onTap: () {
                        print('押された');
                        final Uri toLaunch =
                            Uri(scheme: 'https', host: 'www.youtube.com', path: "watch",queryParameters: {'v':youtube_id});
                        _launched = _launchInWebViewOrVC(toLaunch);
                      },
                      child: Container(
                        width: cellWidth/2,
                        height: cellHeight/4*3,
                        child:
                        Text(
                          press['title'],
                          maxLines: 3,
                        )
                      )),
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
                                    return modalWindow(press, context, 'each_video');
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

  transitNavigation(index){
    setState(() {
      _pressCount = 0;
      currentIndex = index;
      youtubeController.pause();
    });
    updateScreen();
  }

  saveMultiple(){
    updateScreen();
    print("お気に入り追加");
  }


  Offset synchronizedWidgetPosition = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    //_presses = json.decode(_pressesJson!);
    List<BottomNavigationBarItem> itemList = mixedMap.map((map) => map["item"]).toList()
    .whereType<BottomNavigationBarItem>() // BottomNavigationBarItem型の要素のみ抽出
    .toList();
    return 
      SafeArea(
      child:
      Stack(
        children: <Widget>[
          Scaffold(
            appBar: PreferredSize(
               preferredSize: Size.fromHeight(layoutHeight.app_bar!),
               child: AppBar(
                 title: Text("$_categoryName"),
                 leading: Container(),
               ),
            ),
            body: Container(
              height: _deviceHeight,
              width: _deviceWidth,
              //color: Colors.blue,
              child: 
                Container(
                  height: layoutHeight.getInnerScrollHeight(),
                  child: 
                  Stack(
                  children: <Widget>[
                    NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollNotification) {
                        if (scrollNotification is ScrollEndNotification) {
                          final before = scrollNotification.metrics.extentBefore;
                          final max = scrollNotification.metrics.maxScrollExtent;
                          if(before < layoutHeight.menu_area!){
                            setState(() {
                            //layoutHeight.menu_area =  before;
                            });
                          }
                          if (before == 0 && mixedMap[currentIndex]['name'] == 'home') {
                            setForOuterScroll();
                          }
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
                      Positioned(
                        right: 0,
                        left: 0,
                        top: layoutHeight.listViewTop(),
                        bottom: 0,
                        child: 
                        ListView(
                          controller: _innerScrollController,
                          //physics: ableInnerScroll ?  const AlwaysScrollableScrollPhysics() : const  NeverScrollableScrollPhysics(),
                          children: [
                            Container(
                              width: _deviceWidth!,
                              height: layoutHeight.menu_area,
                              //color: Colors.blue,
                              child: Spacer(),
                            ),
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
                      )
                    ),
                    Container(
                      height: layoutHeight.menu_area,
                      alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.pending),
                          onPressed: () {
                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context) {
                                return modalWindow({}, context, 'menu');
                              },
                            );
                          },
                        )
                    ),
                    Container(
                      //height: 200.0, // Height of the synchronized widget
                      child: Transform.translate(
                        offset: layoutHeight.categorybarOffset(),
                        child: Container(
                          //color: Colors.blue,
                          alignment: Alignment.center,
                          child: 
                            Column(
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      for (var i = 0; i < _presses.length; i++)
                                      Container(
                                        color: colors[i % colors.length],
                                        width: _deviceWidth!/5,
                                        height: layoutHeight.category_bar,
                                        padding: EdgeInsets.all(0),
                                        margin: EdgeInsets.all(0),
                                        child:TextButton(
                                          onPressed: () {
                                            setState(() {
                                              currentCategoryIndex = i;
                                            });
                                            //SelectCategory(currentCategoryIndex);
                                            //resetPressCount();
                                            resetCategory(currentCategoryIndex);
                                          },
                                          child: Text(
                                            _presses[i]['japanese_name'],
                                            style: TextStyle(
                                              fontSize: fontSize(_presses[i]['japanese_name'].length),
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
                                  height: layoutHeight.category_bar_line,
                                ),
                                if(_alert != null)
                                Container(
                                  height: layoutHeight.alert,
                                  child: Text(_alert!),
                                ),
                              ],
                            )
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              selectedItemColor: Colors.blue,
              currentIndex: currentIndex,
              onTap: (index) {
                transitNavigation(index);
              },
              items: true ? itemList : itemList,
              type: BottomNavigationBarType.fixed,
            ),
          ),
          Transform.translate(
            offset: layoutHeight.youtubePlayerOffset(context),//Offset(0, 0),
              child: SizedBox(
              height: layoutHeight.getYoutubeDisplayHeight(context),
              width: layoutHeight.getYoutubeDisplayWidth(context),
              child:
                YoutubePlayerBuilder(
                  player: YoutubePlayer(
                      controller: youtubeController,
                  ),
                  builder: (context, player){
                  return Column(
                    children: [
                    // some widgets
                    player,
                    //some other widgets
                    ],
                  );
                },
              ),
            ),
          ),
        ]
      )
    );
  }
}


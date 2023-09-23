import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'bottom_navigation_bar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'models/history.dart';
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
import 'views/video_cell.dart';
import 'views/modal_window.dart';
import 'models/menu_button.dart';
import 'models/favorite.dart';

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
  ScrollController _scrollController = ScrollController();
  History _history = History(); 
  Favorite _favorite = Favorite(); // History クラスのインスタンスを作成
  var category_setting = CategorySetting();
  LayoutHeight layoutHeight = LayoutHeight(deviceWidth:0, deviceHeight: 0, barHeight:0, innerHeight: 0);
  DefaultValue defaultValue = DefaultValue();
  String _categoryName = "ビジネス";
  int currentIndex = 0;
  int currentCategoryIndex = 0;
  int _pressUnitCount = 20;
  int _scrollUperCount = 0;
  bool _displayLoadingScreen = false;
  String? _alert;
  Future<void>? _launched;
  late int _pressCount =  _pressUnitCount;
  late Color _curretColor = colors[0];

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
      //_history.deleteTable();
      //_favorite.deleteTable();
      youtubeController =  YoutubePlayerController(
        initialVideoId: defaultYoutubeId!,
        flags: YoutubePlayerFlags(
          autoPlay: false,  // 自動再生しない
        ),);
      _scrollController = ScrollController(initialScrollOffset: _deviceWidth!/10);
    });

    _scrollController.addListener(() {
      setOffset();
    });
    SettingPage settingPage = SettingPage();
    await displayNews();
    resetPressCount();
  }

  setOffset(){
    setState(() {
      double offset = _scrollController.offset;
      layoutHeight.scrollOffset = offset.clamp(0.0, layoutHeight.menu_area);//menuが見える時以外offsetは0にする
    });
  }

  Future<void> displayNews() async {
    setDefauldLayout();
    await SelectCategory(currentCategoryIndex);
    resetPressCount();
    setState(() {
      _scrollController.jumpTo(_deviceHeight!/10);
    });
  }

  Future<void> displayHistory() async {
    _press = [];
    await _history.initDatabase();
    List<Map<String, dynamic>> histories = await _history.all();
    histories = histories.reversed.toList();// あなたの非同期処理;
    setState(() {
      //setDefauldLayout();
      layoutHeight.setForDefault();
      layoutHeight.setForNewsCellsHeight();
      _press = histories; // 取得したデータを _press 変数に代入
      resetPressCount();
    });
  }

  Future<void> displayFavorites() async {
    _press = [];
    List<Map<String, dynamic>> favorites = await _favorite.all();
    favorites = favorites.reversed.toList();// あなたの非同期処理;
    setState(() {
      //setDefauldLayout();
      layoutHeight.setForDefault();
      layoutHeight.setForNewsCellsHeight();
      _press = favorites; // 取得したデータを _press 変数に代入
      resetPressCount();
    });
    closeYoutube();
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
      //_scrollController.jumpTo(100.0);
    });
    layoutHeight.setForNewsCellsHeight();
  }

  void openYoutube(Map press) async {
    String youtube_id = press["youtube_id"];
    layoutHeight.displayYoutube();
    layoutHeight.setForNewsCellsHeight();
    //最後に再生した動画を保存機能
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(Duration.zero);
    setState(() {
      youtubeController.load( youtube_id,startAt:0);
    });
    await prefs.setString('default_youtube_id', youtube_id);
    await _history.initDatabase(); 
    List<Map<String, dynamic>> histories = await _history.all();
    await _history.create(press);
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
      _curretColor =  colors[category_num % colors.length];
      _press = press;
    });
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
  
  void updateScreen(){
    switch(mixedMap[currentIndex]['name']) {
      case 'home':
        displayNews();
        break;
      case 'favorite':
        displayFavorites();
        closeYoutube();
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
    bool isFavorite = mixedMap[currentIndex]['name'] == 'favorite';
    return VideoCellClass(
      press: press, 
      cellHeight: cellHeight, 
      cellWidth: cellWidth, 
      onPressedYoutube: (){
        openYoutube(press);
      },
      onPressedOptions: (){
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return ModalWindow(
              windowWidth: _deviceWidth!,
              buttons: [
                MenuButton(
                  onPressed: () async {
                    if (isFavorite) {
                      await _favorite.delete(press['id']);
                    } else {
                      await _favorite.create(press);
                    }
                    updateScreen();
                    print("お気に入り追加");
                    Navigator.of(context).pop();
                  },
                  name:isFavorite ? "ーお気に入りから削除" : "＋お気に入りに追加"
                ),
              ],
            );
          }
        );
      },
      onPressedTitle: (){
        final Uri toLaunch = Uri(
            scheme: 'https',
            host: 'www.youtube.com',
            path: "watch",
            queryParameters: {'v': press['youtube_id']});
        _launched = _launchInWebViewOrVC(toLaunch);
      },
    );
  }

  transitNavigation(index){
    setState(() {
      _pressCount = 0;
      currentIndex = index;
      youtubeController.pause();
    });
    updateScreen();
    closeYoutube();
    layoutHeight.hideYoutube();
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
                          controller: _scrollController,
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
                              return ModalWindow(
                                windowWidth: _deviceWidth!,
                                buttons: [
                                  MenuButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                    },
                                    name:"複数選択"
                                  ),
                                  if(mixedMap[currentIndex]['name'] == 'favorite')
                                  MenuButton(
                                    onPressed: () async {
                                      _favorite.deleteTable();
                                      _favorite = Favorite();
                                      updateScreen();
                                      Navigator.of(context).pop();
                                    },
                                    name:"お気に入りを全て削除"
                                  ),
                                  if(mixedMap[currentIndex]['name'] == 'history')
                                  MenuButton(
                                    onPressed: () async {
                                      _history.deleteTable();
                                      _history = History();
                                      updateScreen();
                                      Navigator.of(context).pop();
                                    },
                                    name:"履歴を全て削除"
                                  ),
                                ],
                              );
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
                                  color: _curretColor,
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


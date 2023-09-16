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
   
  Map<String, double> layoutHeight = {};
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
        initialVideoId: defaultYoutubeId,
        flags: YoutubePlayerFlags(
          autoPlay: false,  // 自動再生しない
        ),);
      _outerScrollController = ScrollController(initialScrollOffset: _deviceWidth!/10);
    });
    SettingPage settingPage = SettingPage();
    await displayNews();
    resetPressCount();
  }

  Future<void> displayHistory() async {
    _press = [];
    await history.initDatabase();
    List<Map<String, dynamic>> histories = await history.all();
    histories = histories.reversed.toList();// あなたの非同期処理;
    setState(() {
      setDefauldLayout();
      layoutHeight['category_bar'] = 0;
      layoutHeight['category_bar_line'] = 0;
      layoutHeight['youtube_display'] = 0;
      setNesCellsHeight();
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
      _outerScrollController.jumpTo(_deviceHeight!/10);
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
      layoutHeight['category_bar'] = 0;
      layoutHeight['category_bar_line'] = 0;
      layoutHeight['youtube_display'] = 0;
      setNesCellsHeight();
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
      layoutHeight = {
        'app_bar':40,
        'category_bar':_deviceWidth!/10,
        'category_bar_line':5,
        'menu_area':_deviceWidth!/10,
        'youtube_display':_deviceWidth!/16*9,
        'bottom_nabigation_bar': bar.height,
        'alert':0
      };
    });
    setNesCellsHeight();
  }

  void setNesCellsHeight(){
    layoutHeight['news_cells'] = 0;
    layoutHeight['news_cells'] = _innerHeight! - layoutHeight.values.reduce((a, b) => a + b) - 2;
  }

  double getInnerScrollHeight(){
    double height = layoutHeight['app_bar']! + layoutHeight['category_bar']! + layoutHeight['category_bar_line']! + layoutHeight['youtube_display']! + layoutHeight['news_cells']!;
    if(mixedMap[currentIndex]['name'] == 'home'){
      return height;
    }else{
      return height - layoutHeight['menu_area']!;
    }
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

    //_presses = json.decode(_pressesJson!);
    List<BottomNavigationBarItem> itemList = mixedMap.map((map) => map["item"]).toList()
    .whereType<BottomNavigationBarItem>() // BottomNavigationBarItem型の要素のみ抽出
    .toList();

    return Scaffold(
      appBar: PreferredSize(
         preferredSize: Size.fromHeight(layoutHeight['app_bar']!),
         child: AppBar(
           title: Text("$_categoryName"),
           leading: Container(),
         ),
      ),
      body: Container(
        height: _deviceHeight,
        width: _deviceWidth,
        //color: Colors.blue,
        child: Flexible(
            //Flexibleでラップ
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollNotification) {
                if (scrollNotification is ScrollEndNotification) {
                  final before = scrollNotification.metrics.extentBefore;
                  final max = scrollNotification.metrics.maxScrollExtent;
                  if (before == max &&  mixedMap[currentIndex]['name'] == 'home') {
                    setForInnerScroll();
                  }
                }//
                return false;
              },
              child: 
              ListView(
                controller: ableOuterScroll ? _outerScrollController : _innerScrollController,
                 physics: ableOuterScroll ?  const AlwaysScrollableScrollPhysics() : const  NeverScrollableScrollPhysics(),
                children: [
                  //上のメニュー
                  Container(
                    height: layoutHeight['menu_area'],
                    alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: _deviceHeight!*0.7,
                                width: double.infinity,
                                //color: Colors.red,//Color.fromRGBO(245, 245, 245, 1),
                                child: settingWindow(context),
                              );
                            },
                          );
                        },
                        //style: ElevatedButton.styleFrom(
                        //  primary: Colors.red,
                        //),
                      ),
                  ),
                  //カテゴリー選択
                  Container(
                    height: getInnerScrollHeight(),
                    child: 
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (var i = 0; i < _presses.length; i++)
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
                      //カテゴリー選択の場所のボトムバー
                      Container(
                        color: _color,
                        width: _deviceWidth,
                        height: layoutHeight['category_bar_line'],
                      ),
                      //アラート
                      if(_alert != null)
                      Container(
                        height: layoutHeight['alert'],
                        child: Text(_alert!),
                      ),
                      //if(layoutHeight['menu_area']! > 0)
                      //youtube再生場所
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
                      //youtube一覧
                      Flexible(    
                        //Flexibleでラップ
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollNotification) {
                            if (scrollNotification is ScrollEndNotification) {
                              final before = scrollNotification.metrics.extentBefore;
                              final max = scrollNotification.metrics.maxScrollExtent;
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
                          ListView(
                            controller: _innerScrollController,
                            physics: ableInnerScroll ?  const BouncingScrollPhysics() : const  NeverScrollableScrollPhysics(),
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
                        )
                      ),
                    ],
                  ),
                )
              //for(var i=0; i<_pressCount; i++)
              //  Container(
              //    width: _deviceWidth,
              //    height: 100,
              //    child:Text("ああああああ")
              //  )
              ],
            )
          )
        ),
      ),
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


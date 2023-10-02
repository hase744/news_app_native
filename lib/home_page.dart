import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'views/bottom_navigation_bar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'models/history.dart';
import 'setting_page.dart';
import 'category_setting.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'models/layout_height.dart';
import 'controllers/default_values_controller.dart';
import 'views/video_cell.dart';
import 'views/modal_window.dart';
import 'models/menu_button.dart';
import 'models/favorite.dart';
import 'package:video_news/views/bottom_menu_bar.dart';
import 'package:video_news/views/alert.dart';
import 'package:video_news/consts/navigation_list_config.dart';
import 'package:video_news/models/navigation_item.dart';
import 'package:flutter/services.dart';
import 'package:video_news/controllers/access_controller.dart';
import 'package:flutter/cupertino.dart';

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
  List<Map> selection = [];
  List selectedVideos = [];
  YoutubePlayerController youtubeController = YoutubePlayerController(
    initialVideoId: '4b6DuHGcltI',
    flags: YoutubePlayerFlags(
        autoPlay: false,  // 自動再生しない
      ),
    );
  ScrollController _scrollController = ScrollController();
  History _history = History(); 
  Favorite _favorite = Favorite(); // History クラスのインスタンスを作成
  CategorySetting category_setting = CategorySetting();
  HomeLayout homeLayout = HomeLayout(deviceWidth:0, deviceHeight: 0, barHeight:0, innerHeight: 0);
  DefaultValue defaultValue = DefaultValue();
  String _categoryName = "ビジネス";
  int pageIndex = 0;
  int currentCategoryIndex = 0;
  int _pressUnitCount = 20;
  bool _displayLoadingScreen = true;
  String loadText = " ↓ 引き下げて更新";
  String? _alert;
  bool isSelectMode = false;
  Future<void>? _launched;
  late int _pressCount =  _pressUnitCount;
  late Color _curretColor = colors[0];
  final _controller = TextEditingController();
  List<NavigationItem> menuList = NavigationListConfig.menuList;
  List<NavigationItem> pageList = NavigationListConfig.pageList;

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
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white
      ),
    );
    FocusScope.of(context).unfocus();
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
      _scrollController = ScrollController(initialScrollOffset: (_deviceWidth!*homeLayout.topMenuRatio));
      _scrollController.addListener(_onScroll);
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
      homeLayout.videoCellsOffset = offset.clamp(0.0, homeLayout.getTopMenuHeight());//menuが見える時以外offsetは0にする
    });
  }

  Future<void> displayNews() async {
    setDefauldLayout();
    await SelectCategory(currentCategoryIndex);
    resetPressCount();
    setState(() {
      _scrollController.jumpTo(homeLayout.getTopMenuHeight());
    });
  }

  Future<void> displayHistory() async {
    _press = [];
    await _history.initDatabase();
    List<Map<String, dynamic>> histories = await _history.all();
    histories = histories.reversed.toList();// あなたの非同期処理;
    setState(() {
      homeLayout.setForList();
      homeLayout.setHeightForVideoCells();
      _press = histories; // 取得したデータを _press 変数に代入
      resetPressCount();
    });
    closeYoutube();
  }

  Future<void> displayFavorites() async {
    _press = [];
    List<Map<String, dynamic>> favorites = await _favorite.all();
    favorites = favorites.reversed.toList();// あなたの非同期処理;
    setState(() {
      homeLayout.setForList();
      homeLayout.setHeightForVideoCells();
      _press = favorites; // 取得したデータを _press 変数に代入
      resetPressCount();
    });
    closeYoutube();
  }

  void setDefauldLayout(){
    setState(() {
      var _padding = MediaQuery.of(context).padding;
      homeLayout = HomeLayout(
        deviceWidth: _deviceWidth!,
        deviceHeight: _deviceHeight!,
        barHeight: 100,
        innerHeight: _deviceHeight! - _padding.top - _padding.bottom,
      );
      //_scrollController.jumpTo(100.0);
    });
    homeLayout.setHeightForVideoCells();
  }

  void openYoutube(Map press) async {
    String youtube_id = press["youtube_id"];
    homeLayout.displayYoutube();
    homeLayout.setHeightForVideoCells();
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
    homeLayout.hideYoutube();
    homeLayout.setHeightForVideoCells();
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
    switch(pageList[pageIndex].name) {
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

  displayAlert(String alert){
    setState(() {
    _alert = alert;
    homeLayout.alertHeight = 20;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        homeLayout.alertHeight = 0;
        _alert = null;
      });
    });
  }

  bottmBar(){
    if(isSelectMode){
      return BottomMenuNavigationBar(
        initialIndex: pageIndex, 
        onTap: (int index){
          switch(menuList[index].name){
            case 'favorite':
              if(selection.isNotEmpty){
                _favorite.createBatch(selection);
                displayAlert("お気に入りに追加しました");
                setState(() {
                  isSelectMode = false;
                  selection = [];
                });
              }else{
                displayAlert("選択されてません");
              }
            case 'close':
                setState(() {
                  isSelectMode = false;
                  selection = [];
                });
            default:
          }
        }, 
      );
    }else{
      return HomeBottomNavigationBar(
        initialIndex: pageIndex, 
        onTap: (int index){
          pageIndex = index;
          updateScreen();
          print(index);
        }, 
        isSelectMode: isSelectMode
      );
    }
  }

  selectVideo(Map video){
    int index = selection.indexWhere((map) => map["youtube_id"] == video['youtube_id']);
    setState(() {
      if(index != -1){
        selection.removeAt(index);
      }else{
        selection.add(video);
      }
    });
  }

  Widget videoCell(BuildContext context, Map video){
    String youtube_id = video['youtube_id'];
    double cellWidth = _deviceWidth!;
    double cellHeight = _deviceWidth!/2/16*9;
    bool isFavorite = pageList[pageIndex].name == 'favorite';
    List youtubeIds = selection.map((map) => map["youtube_id"]).toList();
    return VideoCellClass(
      press: video, 
      isSelectMode: isSelectMode,
      isSelected: youtubeIds.contains(youtube_id),
      cellHeight: cellHeight, 
      cellWidth: cellWidth, 
      onSelected: (){
        selectVideo(video);
      },
      onPressedYoutube: (){
        openYoutube(video);
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
                      await _favorite.delete(video['id']);
                    } else {
                      await _favorite.create(video);
                    }
                    updateScreen();
                    Navigator.of(context).pop();
                    displayAlert(isFavorite ? "削除しました" : "追加しました");
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
          queryParameters: {'v': video['youtube_id']}
        );
        _launched = _launchInWebViewOrVC(toLaunch);
      },
    );
  }

  transitNavigation(index){
    setState(() {
      _pressCount = 0;
      pageIndex = index;
      youtubeController.pause();
    });
    updateScreen();
    closeYoutube();
    homeLayout.hideYoutube();
  }

  scrollToPoint(double offset){
    Future.delayed(Duration(seconds: 0), () {
      _scrollController.animateTo(
        offset,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
  }

  scrollForMenu(double offest){
    if(homeLayout.loadAreaHeight > 0 && offest < homeLayout.loadAreaHeight){
      scrollToPoint(homeLayout.loadAreaHeight);
    }else if(offest > homeLayout.loadAreaHeight && offest < homeLayout.loadAreaHeight + homeLayout.searchAreaHeight/2){
      scrollToPoint(homeLayout.loadAreaHeight);
    }else if(offest > homeLayout.loadAreaHeight + homeLayout.searchAreaHeight/2 && offest < homeLayout.getTopMenuHeight()){
      scrollToPoint(homeLayout.getTopMenuHeight());
    }
  }

  updatePresses() async {
    print("アップデート");
    AccessController access = AccessController();
    await access.accessPress();
      if (access.statusCode == 200) {
        List press = await category_setting.getPressOrder();
        print(press);
        setState(() {
        _presses = press;
        });
      } else {
        throw Exception('Failed to load data');
      }
  }

  countLoad(){
      Timer.periodic(Duration(milliseconds: 25), (timer) {
        setState(() {
          homeLayout.loadCount += 1;
        });
        if(!homeLayout.loadCounting || homeLayout.loadCount >= homeLayout.maxLoadCount){
          setState(() {
            loadText = " ↑ はなして更新";
            homeLayout.isLoading = true;
          });
          timer.cancel();
        }
      }
    );
  }

  void _onScroll() {
    final before = _scrollController.position.pixels;
    final end = _scrollController.position.maxScrollExtent;
    setState(() {
      if (before == end) {
        _displayLoadingScreen = true;
      }
      if(homeLayout.isLoading){
        loadText = "更新中";
      }
      if(before >= homeLayout.loadAreaHeight){
        homeLayout.isLoading = false;
      }
      if(!homeLayout.isLoading){
        loadText = " ↓ 引き下げて更新 ";
      }
      if(before <= 0 && !homeLayout.loadCounting){
        homeLayout.loadCounting = true;
        countLoad();
      }
      if(before > 0 || homeLayout.loadCount >= homeLayout.maxLoadCount){
        homeLayout.loadCounting = false;
        homeLayout.loadCount = 1;
      }
      FocusScope.of(context).unfocus();
    });
  }
  
  List<MenuButton> menuButtons(context){
    return [
      MenuButton(
        onPressed: () async {
          Navigator.of(context).pop();
          setState(() {
            isSelectMode = true;
             updateScreen();
          });
        },
        name:"複数選択"
      ),
      if(pageList[pageIndex].name == 'favorite')
      MenuButton(
        onPressed: () async {
          _favorite.deleteTable();
          _favorite = Favorite();
          Navigator.of(context).pop();
          displayFavorites();
          displayAlert("削除しました");
        },
        name:"お気に入りを全て削除"
      ),
      if(pageList[pageIndex].name == 'history')
      MenuButton(
        onPressed: () async {
          _history.deleteTable();
          Navigator.of(context).pop();
          displayHistory();
          displayAlert("削除しました");
        },
        name:"履歴を全て削除"
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    //_presses = json.decode(_pressesJson!);
    return 
      SafeArea(
      child:
      Stack(
        children: <Widget>[
          Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(homeLayout.appBarHeight),
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
                  height: homeLayout.getInnerScrollHeight(),
                  child: 
                  Stack(
                  children: <Widget>[
                    NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollNotification) {
                        if (scrollNotification is ScrollEndNotification) {
                          // The ListView has stopped scrolling
                          final before = scrollNotification.metrics.extentBefore;
                          final max = scrollNotification.metrics.maxScrollExtent;
                          scrollForMenu(before);
                          if (before == max) {
                            setState(() {
                              //挿入可能な記事があれば記事を挿入
                              _pressCount += _pressUnitCount;
                              if (_pressCount > _press.length) { //ロード過多
                                _pressCount = _press.length;
                                if(_displayLoadingScreen){
                                  _displayLoadingScreen = false;
                                }
                              }
                            });
                          }
                          if(before == 0 && homeLayout.isLoading){
                            updatePresses();
                          }
                        }//
                        return false;
                      },
                      child: 
                      Positioned(
                        right: 0,
                        left: 0,
                        top: homeLayout.listViewTop(),
                        bottom: 0,
                        child: 
                        ListView(
                          controller: _scrollController,
                          physics: ClampingScrollPhysics(),
                          children: [
                            Container(
                              width: _deviceWidth!,
                              height: homeLayout.getTopMenuHeight(),
                              //color: Colors.blue,
                              child: Spacer(),
                            ),
                            if(_press.isNotEmpty)//これがないテーブルごと全て削除した時にエラーが起きる
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
                                child: 
                                CircularProgressIndicator(
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
                    Transform.translate(
                      offset: homeLayout.getTopMenuOffset(),
                      child:
                       Column(
                          children: [
                          Container(
                            height: homeLayout.loadAreaHeight,
                            alignment: Alignment.bottomCenter,
                            color: Colors.white,
                            child: 
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(loadText),
                                  if(homeLayout.loadCounting && homeLayout.loadCount < homeLayout.maxLoadCount)
                                  Container(
                                    height: homeLayout.loadAreaHeight/4,
                                    width: homeLayout.loadAreaHeight/4,
                                    child: 
                                    CircularProgressIndicator(
                                      value: homeLayout.loadCount/homeLayout.maxLoadCount,
                                      color: Colors.grey,
                                    ),
                                  )
                                ]
                              )
                            )
                          ),
                          Container(
                            height: homeLayout.searchAreaHeight,
                            alignment: Alignment.centerRight,
                            color: Colors.white,
                            child: 
                            Row(
                              children: <Widget>[
                                Container(
                                  color: Colors.white,
                                  width: _deviceWidth! - homeLayout.searchAreaHeight,
                                  child: TextField(
                                    controller: _controller,
                                    decoration: InputDecoration(
                                      hintText: 'キーワードで検索',
                                      prefixIcon: IconButton(
                                        icon: Icon(Icons.search),
                                        onPressed: () {
                                          String searchText = _controller.text;
                                          print(searchText);
                                        },
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () {
                                          _controller.clear();
                                        },
                                      ),
                                    ),
                                    onSubmitted: (text) => (){
                                      print("検索$text");
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: homeLayout.searchAreaHeight,
                                  child:
                                  IconButton(
                                    icon: Icon(Icons.more_vert, color: Colors.blue,),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return ModalWindow(
                                            windowWidth: _deviceWidth!,
                                            buttons: menuButtons(context),
                                          );
                                        },
                                      );
                                    },
                                  )
                                )
                              ],
                            ),
                          )
                        ]
                      )
                    ),
                    Container(
                      //height: 200.0, // Height of the synchronized widget
                      child: Transform.translate(
                        offset: homeLayout.categorybarOffset(),
                        child: Container(
                          //color: Colors.blue,
                          alignment: Alignment.center,
                          child: 
                            Column(
                              children: [
                                Container(
                                  width: _deviceWidth,
                                  height: homeLayout.categoryBarHeight,
                                  child: 
                                  ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      for (var i = 0; i < _presses.length; i++)
                                      Container(
                                        color: colors[i % colors.length],
                                        width: _deviceWidth! / 5,
                                        height: homeLayout.categoryBarHeight,
                                        padding: EdgeInsets.all(0),
                                        margin: EdgeInsets.all(0),
                                        child: TextButton(
                                          onPressed: () {
                                            setState(() {
                                              currentCategoryIndex = i;
                                            });
                                            // SelectCategory(currentCategoryIndex);
                                            // resetPressCount();
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
                                        ),
                                      ),
                                    ],
                                  )
                                ),
                                Container(
                                  color: _curretColor,
                                  width: _deviceWidth,
                                  height: homeLayout.categoryBarLineHeight,
                                ),
                                if(_alert != null)
                                Alert(
                                  text: _alert!, 
                                  width: _deviceWidth!,
                                  height: homeLayout.alertHeight
                                )
                              ],
                            )
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: bottmBar(),
          ),
          Transform.translate(
            offset: homeLayout.youtubePlayerOffset(context),//Offset(0, 0),
              child: SizedBox(
              height: homeLayout.getYoutubeDisplayHeight(context),
              width: homeLayout.getYoutubeDisplayWidth(context),
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


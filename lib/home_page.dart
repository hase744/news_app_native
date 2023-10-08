// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_news/controllers/category_controller.dart';
import 'dart:convert';
import 'views/bottom_navigation_bar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'models/history.dart';
import 'setting_page.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'models/home_layout.dart';
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
import 'package:video_news/views/top_navigation.dart';
import 'package:video_news/controllers/video_controller.dart';
import 'package:video_news/models/category.dart';
import 'package:video_news/models/video.dart';

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
  double? _deviceWidth, _deviceHeight;
  History _history = History(); 
  Favorite _favorite = Favorite(); // History クラスのインスタンスを作成
  HomeLayout homeLayout = HomeLayout(deviceWidth:0, deviceHeight: 0, barHeight:0, innerHeight: 0);
  DefaultValue defaultValue = DefaultValue();
  int pageIndex = 0;
  String loadText = " ↓ 引き下げて更新";
  String? _alert;
  bool isSelectMode = false;
  Future<void>? _launched;
  TextEditingController _controller = TextEditingController();
  VideoController _videoController = VideoController();
  ScrollController _scrollController = ScrollController();
  CategoryController categoryController = CategoryController();
  YoutubePlayerController youtubeController = YoutubePlayerController(
    initialVideoId: '4b6DuHGcltI',
    flags: YoutubePlayerFlags(
        autoPlay: false,  // 自動再生しない
      ),
    );
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
    await _videoController.setVideosList();

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white
      ),
    );
    FocusScope.of(context).unfocus();
    setState(() {
      _deviceWidth = MediaQuery.of(context).size.width;
      _deviceHeight = MediaQuery.of(context).size.height;
      //_history.deleteTable();
      //_favorite.deleteTable();
      youtubeController =  YoutubePlayerController(
        initialVideoId: defaultYoutubeId!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,  // 自動再生しない
        ),
      );
      _scrollController = ScrollController(initialScrollOffset: (_deviceWidth!*homeLayout.topMenuRatio));
    });
    _scrollController.addListener(() {
      _onScroll();
    });
    SettingPage settingPage = SettingPage();
    await displayNews();
    resetPressCount();
  }

  Future<void> displayNews() async {
    setDefauldLayout();
    await selectCategory(categoryController.categoryIndex);
    resetPressCount();
    setState(() {
      _scrollController.jumpTo(homeLayout.getTopMenuHeight());
    });
  }

  Future<void> displayHistory() async {
    _videoController.videos = [];
    await _history.initDatabase();
    List<Map<String, dynamic>> histories = await _history.all();
    histories = histories.reversed.toList();
    setState(() {
      homeLayout.setForList();
      homeLayout.setHeightForVideoCells();
      _videoController.videos = histories; // 取得したデータを _press 変数に代入
      resetPressCount();
    });
    closeYoutube();
  }

  Future<void> displayFavorites() async {
    _videoController.videos = [];
    List<Map<String, dynamic>> favorites = await _favorite.all();
    favorites = favorites.reversed.toList();
    await _videoController.displayFavorites();
    setState(() {
      homeLayout.setForList();
      homeLayout.setHeightForVideoCells();
      //_videoController.videos = favorites; // 取得したデータを _press 変数に代入
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

  Future<void> selectCategory(int category_num) async {
    setState(() {
      closeYoutube();
      _videoController.changeVideos(category_num);
    });
  }

  Future<void> resetCategory(int category_num) async {
    await selectCategory(category_num);
    await resetPressCount();
  }

  Future<void> resetPressCount() async {
    setState(() {
      _videoController.resetVideoCount();
    });
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

  Widget bottomBar(){
    if(isSelectMode){
      return BottomMenuNavigationBar(
        initialIndex: 0, 
        onTap: (int index){
          switch(menuList[index].name){
            case 'favorite':
              if(_videoController.selection.isNotEmpty){
                _favorite.createBatch(_videoController.selection);
                _videoController.createSelectedFavorite();
                displayAlert("お気に入りに追加しました");
                setState(() {
                  isSelectMode = false;
                  _videoController.selection = [];
                });
              }else{
                displayAlert("選択されてません");
              }
            case 'close':
                setState(() {
                  isSelectMode = false;
                  _videoController.selection = [];
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

  Widget topNavigation(context){
    return TopNavigation(
      homeLayout: homeLayout, 
      loadText: loadText, 
      width: _deviceWidth!, 
      controller: _controller, 
      onSearched: (String text){}, 
      onClosesd: () {
        String searchText = _controller.text;
        print(searchText);
        setState(() {
          homeLayout.displaySearch = false;
        });
      }, 
      menuOpened: () {
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
      searchOpened: (){
        setState(() {
          homeLayout.displaySearch = true;
        });
      }
    );
  }

  Widget videoCell(BuildContext context, Map video){
    String youtube_id = video['youtube_id'];
    double cellWidth = _deviceWidth!;
    double cellHeight = _deviceWidth!/2/16*9;
    bool isFavorite = pageList[pageIndex].name == 'favorite';
    List youtubeIds = _videoController.selection.map((map) => map["youtube_id"]).toList();
    return VideoCellClass(
      press: video, 
      isSelectMode: isSelectMode,
      isSelected: youtubeIds.contains(youtube_id),
      cellHeight: cellHeight, 
      cellWidth: cellWidth, 
      onSelected: (){
        setState(() {
          _videoController.selectVideo(video);
        });
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
                      await _videoController.deleteFavorite(video);
                    } else {
                      await _videoController.createFavorite(video);
                      //await _favorite.create(video);
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
      _videoController.videoCount = 0;
      pageIndex = index;
      youtubeController.pause();
    });
    updateScreen();
    closeYoutube();
    homeLayout.hideYoutube();
  }

  scrollToPoint(double offset){
    Future.delayed(const Duration(seconds: 0), () {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
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
    final prefs = await SharedPreferences.getInstance();
    await access.accessPress();
    if (access.statusCode == 200) {
      await prefs.setString('presses', access.data);
      List press = await categoryController.getPressOrder();
      setState(() {
        _videoController.videosList = press;
      });
      selectCategory(categoryController.categoryIndex);
    } else {
      displayAlert("ロードに失敗しました");
      throw Exception('Failed to load data');
    }
  }

  countLoad(){
    Timer.periodic(Duration(milliseconds: 25), (timer) {
      setState(() {
        homeLayout.loadCount += 1;
        if(!homeLayout.loadCounting || homeLayout.loadCount >= homeLayout.maxLoadCount){
          loadText = " ↑ はなして更新";
          homeLayout.isLoading = true;
          timer.cancel();
        }
      });
    });
  }

  void _onScroll() {
    final before = _scrollController.position.pixels;
    final end = _scrollController.position.maxScrollExtent;
    setState(() {
      if (before == end) {
        _videoController.displayLoadingScreen = true;
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
      double offset = _scrollController.offset;
      homeLayout.videoCellsOffset = offset.clamp(0.0, homeLayout.getTopMenuHeight());//menuが見える時以外offsetは0にする
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
          //_favorite.deleteTable();
          //_favorite = Favorite();
          _videoController.deleteAllFavorite();
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
    //_videoController.videosList = json.decode(_videoController.videosListJson!);
    return 
      SafeArea(
      child:
      Stack(
        children: <Widget>[
          Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(homeLayout.appBarHeight),
              child: AppBar(
                title: Text(categoryController.currentCategory.japaneseName),
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
                              _videoController.loadVideos();
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
                            if(_videoController.videos.isNotEmpty)//これがないテーブルごと全て削除した時にエラーが起きる
                              for(var i=0; i<_videoController.videoCount; i++)
                                videoCell(context, _videoController.videos[i]),
                            if(_videoController.displayLoadingScreen)
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
                      child:topNavigation(context),
                    ),
                    Container(
                      child: Transform.translate(
                        offset: homeLayout.categorybarOffset(),
                        child: Container(
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
                                      for (var i = 0; i < _videoController.videosList.length; i++)
                                      Container(
                                        color: colors[i % colors.length],
                                        width: _deviceWidth! / 5,
                                        height: homeLayout.categoryBarHeight,
                                        padding: EdgeInsets.all(0),
                                        margin: EdgeInsets.all(0),
                                        child: TextButton(
                                          child: 
                                          Text(
                                            categoryController.categories[i].japaneseName,
                                            style: TextStyle(
                                              fontSize: fontSize(categoryController.categories[i].japaneseName.length),
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              categoryController.categoryIndex = i;
                                            });
                                            resetCategory(categoryController.categoryIndex);
                                          },
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
                                  color: colors[categoryController.categoryIndex%5],
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
            bottomNavigationBar: bottomBar(),
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


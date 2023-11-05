// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_news/controllers/category_controller.dart';
import 'dart:convert';
import 'bottom_navigation_bar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_news/models/history.dart';
import 'package:video_news/views/setting_page.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:video_news/models/home_layout.dart';
import 'package:video_news/controllers/default_values_controller.dart';
import 'video_cell.dart';
import 'modal_window.dart';
import 'package:video_news/models/menu_button.dart';
import 'package:video_news/models/favorite.dart';
import 'package:video_news/views/bottom_menu_bar.dart';
import 'package:video_news/views/alert.dart';
import 'package:flutter/services.dart';
import 'package:video_news/views/top_navigation.dart';
import 'package:video_news/controllers/video_controller.dart';
import 'package:video_news/models/category.dart';
import 'package:video_news/models/video.dart';
import 'package:video_news/controllers/load_controller.dart';
import 'package:video_news/controllers/page_controller.dart';
import 'package:video_news/views/category_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.initialIndex});
  final int initialIndex;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>  {
  double? _deviceWidth, _deviceHeight;
  History _history = History(); 
  Favorite _favorite = Favorite(); // History クラスのインスタンスを作成
  HomeLayout homeLayout = HomeLayout(deviceWidth:0, deviceHeight: 0, barHeight:0, innerHeight: 0);
  DefaultValue defaultValue = DefaultValue();
  String? _alert;
  Timer? _timer;
  Future<void>? _launched;
  TextEditingController _controller = TextEditingController();
  VideoController _videoController = VideoController();
  ScrollController _scrollController = ScrollController();
  ScrollController _categoryScrollController = ScrollController();
  CategoryController _categoryController = CategoryController();
  LoadController _loadController = LoadController();
  PageControllerClass _pageController = PageControllerClass();
  YoutubePlayerController _youtubeController = YoutubePlayerController(
    initialVideoId: '4b6DuHGcltI',
    flags: YoutubePlayerFlags(
        autoPlay: false,  // 自動再生しない
      ),
    );
  

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
      _youtubeController =  YoutubePlayerController(
        initialVideoId: defaultYoutubeId!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,  // 自動再生しない
        ),
      );
      _scrollController = ScrollController(
        initialScrollOffset: (_deviceWidth!*homeLayout.topMenuRatio),
        );
      _scrollController.addListener(_onScroll);
      _pageController.pageIndex = widget.initialIndex;
      homeLayout.updateCellsTop(0);
      //_scrollController.jumpTo(0.0);
      //_history.deleteTable();
      //_favorite.deleteTable();
    });
    setDefauldLayout();
    updateScreen();
  }

  Future<void> displayNews() async {
    setDefauldLayout();
    await selectCategory(_categoryController.categoryIndex);
    resetPressCount();
    setState(() {
      print(homeLayout.getTopMenuHeight());
      _scrollController.jumpTo(homeLayout.getTopMenuHeight());
      print("OK");
    });
  }

  Future<void> displayHistory() async {
    setDefauldLayout();
    closeYoutube();
    _videoController.videos = [];
    //await _history.initDatabase();
    //List<Map<String, dynamic>> histories = await _history.all();
    //histories = histories.reversed.toList();
    setState(() {
      _videoController.videos = [];
      _videoController.displayLoadingScreen = true;
      homeLayout.setForList();
      homeLayout.setHeightForVideoCells();
    });
    if(!await _videoController.displayHistories()){
      displayAlert("ロードに失敗しました");
    }
    resetPressCount();
  }

  //Future<void> displayHistory() async {
  //  _videoController.videos = [];
  //  await _history.initDatabase();
  //  List<Map<String, dynamic>> histories = await _history.all();
  //  histories = histories.reversed.toList();
  //  setState(() {
  //    homeLayout.setForList();
  //    homeLayout.setHeightForVideoCells();
  //    _videoController.videos = histories; // 取得したデータを _press 変数に代入
  //    resetPressCount();
  //  });
  //  homeLayout.updateCellsTop(0);
  //  closeYoutube();
  //}

  Future<void> displayFavorites() async {
    setDefauldLayout();
    _videoController.videos = [];
    //List<Map<String, dynamic>> favorites = await _favorite.all();
    //favorites = favorites.reversed.toList();
    setState(() {
      _videoController.videos = [];
      _videoController.displayLoadingScreen = true;
      homeLayout.setForList();
      homeLayout.setHeightForVideoCells();
    });
    if(!await _videoController.displayFavorites()){
      displayAlert("ロードに失敗しました");
    }
    resetPressCount();
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

  void openYoutube(Video video) async {
    String youtube_id = video.youtubeId;
    homeLayout.displayYoutube();
    homeLayout.setHeightForVideoCells();
    //最後に再生した動画を保存機能
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(Duration.zero);
    setState(() {
      _youtubeController.load( youtube_id,startAt:0);
      homeLayout.updateCellsTop(_scrollController.offset);
    });
    print(youtube_id);
    await prefs.setString('default_youtube_id', youtube_id);
    _videoController.createHistory(video);
    //await _history.initDatabase(); 
    //List<Map<String, dynamic>> histories = await _history.all();
    //await _history.create(video);
  }

  void closeYoutube(){
    homeLayout.hideYoutube();
    homeLayout.setHeightForVideoCells();
    _youtubeController.pause();
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
    switch(_pageController.getCurrentPageName()) {
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
    if(_videoController.isSelectMode){
      return BottomMenuNavigationBar(
        list: _pageController.getCurrentList(),
        initialIndex: 0, 
        onTap: (int index) async {
          switch(_pageController.getNameFromIndex(index)){
            case 'delete':
              if(_videoController.selection.isNotEmpty){
                if(_pageController.isFavoritePage() && await _videoController.deleteSelectedFavorite()){
                  displayAlert("お気に入りから削除しました");
                }else if(_pageController.isHistoryPage() && await _videoController.deleteSelectedHistory()){
                  displayAlert("履歴から削除しました");
                }else{
                  displayAlert("削除に失敗しました");
                };
                setState(() {
                  _videoController.disableSelectMode();
                });
                updateScreen();
              }else{
                displayAlert("選択されてません");
              }
            case 'favorite':
              if(_videoController.selection.isNotEmpty){
                if(await _videoController.createSelectedFavorite()){
                  displayAlert("お気に入りに追加しました");
                }else{
                  displayAlert("追加に失敗しました。");
                };
                setState(() {
                  _videoController.disableSelectMode();
                });
              }else{
                displayAlert("選択されてません");
              }
            case 'close':
              setState(() {
                _videoController.disableSelectMode();
              });
            default:
              displayAlert("エラー");
          }
        }, 
      );
    }else{
      return HomeBottomNavigationBar(
        initialIndex: _pageController.pageIndex, 
        onTap: (int index){
          _pageController.updatePage(index);
          updateScreen();
          print(index);
        }, 
        isSelectMode: _videoController.isSelectMode
      );
    }
  }

  Widget topNavigation(context){
    return TopNavigation(
      loadController: _loadController,
      homeLayout: homeLayout,
      width: _deviceWidth!, 
      controller: _controller, 
      onSearched: (String text) async {
        if(!await _videoController.search(text, _pageController.getCurrentPageName())){
          displayAlert("検索に失敗しました");
        };
        _scrollController.jumpTo(homeLayout.loadAreaHeight);
      }, 
      onClosesd: () {
        setState(() {
          homeLayout.displaySearch = false;
        });
      }, 
      menuOpened: () {
        showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            title: const Text('メニュー'),
            //message: const Text('Message'),
            actions: <CupertinoActionSheetAction>[
              for(var button in menuButtons(context))
              CupertinoActionSheetAction(
                isDefaultAction: true,
                isDestructiveAction: button.isDestractive,
                onPressed: button.onPressed,
                child: Text(
                  button.name,
                  style: TextStyle(
                    color: button.isDestractive ? Colors.red : Colors.blue
                  ),
                  ),
              ),
            ],
          ),
        );
      },
      searchOpened: (){
        setState(() {
          homeLayout.displaySearch = true;
        });
      }
    );
  }

  Widget videoCell(BuildContext context, Video video){
    int cellId = video.id;
    double cellWidth = _deviceWidth!;
    double cellHeight = _deviceWidth! /2 /16 *9;
    List cellIds = _videoController.selection.map((map) => map.id).toList();
    
    return VideoCell(
      video: video, 
      isSelectMode: _videoController.isSelectMode,
      isSelected: cellIds.contains(cellId),
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
        showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            title: Text(video.title),
            //message: const Text('Message'),
            actions: <CupertinoActionSheetAction>[
              for(var button in videoButtons(context, video))
              CupertinoActionSheetAction(
                isDefaultAction: true,
                isDestructiveAction: button.isDestractive,
                onPressed: button.onPressed,
                child: Text(
                  button.name,
                  style: TextStyle(
                    color: button.isDestractive ? Colors.red : Colors.blue
                  ),
                  ),
              ),
            ]
          )
        );
      },
      onPressedTitle: (){
        launchWebView(video);
      },
    );
  }

  launchWebView (Video video){
    final Uri toLaunch = Uri(
      scheme: 'https',
      host: 'www.youtube.com',
      path: "watch",
      queryParameters: {'v': video.youtubeId}
    );
    _launched = _launchInWebViewOrVC(toLaunch);
  }

  transitNavigation(index){
    setState(() {
      _videoController.videoCount = 0;
      _pageController.pageIndex = index;
      _youtubeController.pause();
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

  countLoad(){
    _timer = Timer.periodic(const Duration(milliseconds: 25), (timer) {
      setState(() {
        _loadController.loadCount += 1;
        if(_loadController.loadCount >= _loadController.maxLoadCount){
          _loadController.canLoad = true;
          _timer!.cancel();
        }
      });
    });
  }

  void _onScroll() {
    final before = _scrollController.position.pixels;
    final end = _scrollController.position.maxScrollExtent;
    setState(() {
      if (before == end && _videoController.videoCount >= _videoController.videoLength) {
        _videoController.displayLoadingScreen = true;
      }
      if (before > 0) {
        _loadController.loadCount = 0;
        if(_timer != null){_timer!.cancel();}
      }
      if(before >= homeLayout.loadAreaHeight){
        _loadController.isLoading = false;
      }
      if(before <= 0 && !_loadController.loadCounting){
        if(_pageController.isHomePage()){
          _loadController.loadCounting = true;
          countLoad();
        }
      }
      if(before > 0 || _loadController.loadCount >= _loadController.maxLoadCount){
        _loadController.loadCounting = false;
        _loadController.loadCount = 1;
      }
    });
    homeLayout.updateCellsTop(_scrollController.offset);
    FocusScope.of(context).unfocus();
  }

  List<MenuButton> videoButtons(BuildContext context, Video video){
    bool isFavorite = _pageController.isFavoritePage();
    bool isHistory = _pageController.isHistoryPage();
    return [
      MenuButton(
        onPressed: () async {
          Navigator.of(context).pop();
          launchWebView(video);
        },
        isDestractive: false,
        name: "ページを開く"
      ),
      MenuButton(
        onPressed: () async {
          Navigator.of(context).pop();
          if (isFavorite) {
            if(await _videoController.deleteFavorite(video)){
              displayAlert('削除しました');
            }else{
              displayAlert('削除に失敗しました');
            }
          } else {
            if(await _videoController.createFavorite(video)){
              displayAlert('追加しました');
            }else{
              displayAlert('追加に失敗しました');
            }
          }
        },
        isDestractive: isFavorite,
        name:isFavorite ? "ーお気に入りから削除" : "＋お気に入りに追加"
      ),
      if(isHistory)
      MenuButton(
        onPressed: () async {
          if(await _videoController.deleteHistory(video)){
            displayAlert('削除しました');
          }else{
            displayAlert('削除に失敗しました');
          }
          Navigator.of(context).pop();
        },
        isDestractive: true,
        name: "ー履歴から削除"
      ),
    ];
  }
  
  List<MenuButton> menuButtons(context){
    final navigator = Navigator.of(context);
    return [
      MenuButton(
        onPressed: () async {
          Navigator.of(context).pop();
          setState(() {
            _videoController.ableSelectMode();
          });
        },
        isDestractive: false,
        name:"複数選択",
      ),
      if(_pageController.isFavoritePage())
      MenuButton(
        onPressed: () async {
          Navigator.of(context).pop();
          showConfirmativeButton(
            context, 
            MenuButton(
              onPressed: () async {
                navigator.pop(); 
                if(await _videoController.deleteAllFavorite()){
                  displayFavorites();
                  displayAlert("削除しました");
                }else{
                  displayFavorites();
                  displayAlert("削除に失敗しました");
                }
              },
              isDestractive: true,
              name:"お気に入りを全て削除しますか？"
            ),
          );
        },
        isDestractive: true,
        name:"お気に入りを全て削除"
      ),
      if(_pageController.isHistoryPage())
      MenuButton(
        onPressed: () async {
          Navigator.of(context).pop();
          showConfirmativeButton(
            context, 
            MenuButton(
              onPressed: () async {
                navigator.pop(); 
                if(await _videoController.deleteAllHistory()){
                  displayHistory();
                  displayAlert("削除しました");
                }else{
                  displayHistory();
                  displayAlert("削除に失敗しました");
                }
              },
              isDestractive: true,
              name:"履歴を全て削除しますか？"
            ),
          );
        },
        isDestractive: true,
        name:"履歴を全て削除"
      ),
    ];
  }
  

  updateVideos() async {
    if(!await _videoController.updateVideos(_categoryController.categoryIndex)){
      displayAlert("ロードに失敗しました");
    };
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  loadVideos() async {
    if(!await _videoController.loadVideos(_pageController.getCurrentPageName(), homeLayout.displaySearch)){
      displayAlert("ロードに失敗しました");
    };
    setState(() {
      _videoController = _videoController;
    });
  }

 void showConfirmativeButton(BuildContext context, MenuButton button) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(button.name),
        //message: const Text('Message'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: button.onPressed,
            child: Text(
              '削除する',
              style: TextStyle(
                color: button.isDestractive ? Colors.red : Colors.blue
              ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
           child: const Text("キャンセル"),
           onPressed: () {
           Navigator.pop(context);
           },
        ),
      ),
    );
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
                title: Text(_categoryController.currentCategory.japaneseName),
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
                    Positioned(
                      right: 0,
                      left: 0,
                      top: homeLayout.listViewTop(),
                      bottom: 0,
                      child: 
                      NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollNotification) {
                          if (scrollNotification is ScrollEndNotification) {
                            // The ListView has stopped scrolling
                            final before = scrollNotification.metrics.extentBefore;
                            final max = scrollNotification.metrics.maxScrollExtent;
                            if(_pageController.isHomePage()){
                              scrollForMenu(before);
                            }
                            if (before == max) {
                              loadVideos();
                            }
                            if(_loadController.canLoad){
                              _loadController.isLoading = true;
                              _loadController.canLoad = false;
                              updateVideos();
                            }
                          }//
                          return true;
                        },
                        child: 
                        ListView(
                          controller: _scrollController,
                          physics: ClampingScrollPhysics(),
                          children: [
                            Container(
                              width: _deviceWidth!,
                              height: homeLayout.getTopMenuHeight(),
                              //color: Colors.blue,
                            ),
                            if(_videoController.videos.isNotEmpty)//これがないテーブルごと全て削除した時にエラーが起きる
                              for(var video in _videoController.videos)
                              videoCell(context, video),
                              //for(var i=0; i<_videoController.videoCount; i++)
                              //  videoCell(context, _videoController.videos[i]),
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
                            ),
                            Container(
                              width: _deviceWidth!,
                              height: homeLayout.getbottomSpaceHeight(_videoController.videoCount),
                              color: Colors.white,
                            ),
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
                        child: 
                        CategoryBar(
                          controller: _categoryScrollController,
                          barHeight: homeLayout.categoryBarHeight,
                          lineHeight: homeLayout.categoryBarLineHeight,
                          width: _deviceWidth!,
                          categoryController: _categoryController,
                          onSelected: (int i){
                            setState(() {
                              Future.delayed(const Duration(seconds: 0), () {
                                _categoryScrollController.animateTo(
                                  _deviceWidth!/5*(i-2),
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              });
                              _categoryController.update(i);
                              resetCategory(_categoryController.categoryIndex);
                              _scrollController.jumpTo(homeLayout.getTopMenuHeight());
                            });
                          },
                        )
                      ),
                    ),
                    if(_alert != null)
                    Positioned(
                      right: 0,
                      left: 0,
                      top: homeLayout.getAlertTop(),
                      child:
                        Alert(
                          text: _alert!, 
                          width: _deviceWidth!,
                          height: homeLayout.alertHeight
                        )
                    )
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
                    controller: _youtubeController,
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
          Positioned(//safeareaのroadAreaが見えないようにする
            right: 0,
            left: 0,
            top: -_deviceHeight!,
            child:
              Container(
                color: Colors.white,
                width: _deviceWidth!,
                height: _deviceHeight!,
              )
          )
        ]
      )
    );
  }
}


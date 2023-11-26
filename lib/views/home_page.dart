// ignore_for_file: unused_field
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_news/models/history.dart';
import 'package:video_news/models/menu_button.dart';
import 'package:video_news/models/favorite.dart';
import 'package:video_news/models/video.dart';
import 'package:video_news/views/setting_page.dart';
import 'package:video_news/views/video_cell.dart';
import 'package:video_news/views/alert.dart';
import 'package:video_news/views/category_bar.dart';
import 'package:video_news/views/top_navigation.dart';
import 'package:video_news/views/bottom_menu_bar.dart';
import 'package:video_news/views/bottom_navigation_bar.dart';
import 'package:video_news/controllers/home_layout_controller.dart';
import 'package:video_news/controllers/default_values_controller.dart';
import 'package:video_news/controllers/video_controller.dart';
import 'package:video_news/controllers/category_controller.dart';
import 'package:video_news/controllers/load_controller.dart';
import 'package:video_news/controllers/page_controller.dart';
import 'package:video_news/controllers/version_controller.dart';
import 'package:video_news/helpers/ad_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.initialIndex});
  final int initialIndex;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>  {
  double? _deviceWidth;
  double? _deviceHeight;
  String? _alert;
  Timer? _timer;
  final _history = History(); 
  final _favorite = Favorite(); // History クラスのインスタンスを作成
  HomeLayoutController _homeLayoutController = HomeLayoutController(deviceWidth:0, deviceHeight: 0, barHeight:0, innerHeight: 0, appBarHeight:0);
  DefaultValue defaultValue = DefaultValue();
  Future<void>? _launched;
  VideoController _videoController = VideoController();
  ScrollController _scrollController = ScrollController();
  VersionController _versionController = VersionController();
  final ScrollController _categoryScrollController = ScrollController();
  final CategoryController _categoryController = CategoryController();
  final LoadController _loadController = LoadController();
  final PageControllerClass _pageController = PageControllerClass();
  final TextEditingController _controller = TextEditingController();
  YoutubePlayerController _youtubeController = YoutubePlayerController(
    initialVideoId: '',
    flags: const YoutubePlayerFlags(
        autoPlay: false,  // 自動再生しない
      ),
    );
  final List<BannerAd> _bannerAds = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await defaultValue.initialize();
    String? defaultYoutubeId = defaultValue.getStoredValue('default_youtube_id');
    await _videoController.setVideosList();
    //final prefs = await SharedPreferences.getInstance();
    //await prefs.remove('version');
    await _versionController.initialize();
    await updateVersion();
    setState(() {
      FocusScope.of(context).unfocus();
      MobileAds.instance.initialize();
      for(var i =0; i<3; i++){
        _bannerAds.add(BannerAd(
          size: AdSize.banner,
          adUnitId: AdHelper.bannerAdUnitId,
          listener: BannerAdListener(
            onAdFailedToLoad: (Ad ad, LoadAdError error) {
              ad.dispose();
            },
          ),
          request: const AdRequest()
        )
        );
      }
      for(var bannerAd in _bannerAds){
        bannerAd.load();
      }
      _deviceWidth = MediaQuery.of(context).size.width;
      _deviceHeight = MediaQuery.of(context).size.height;
      _youtubeController =  YoutubePlayerController(
        initialVideoId: defaultYoutubeId!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,  // 自動再生しない
        ),
      );
      _scrollController = ScrollController(
        initialScrollOffset: (_deviceWidth!*_homeLayoutController.topMenuRatio),
      );
      _scrollController.addListener(_onScroll);
      _pageController.pageIndex = widget.initialIndex;
      _homeLayoutController.updateCellsTop(0);
      //_scrollController.jumpTo(0.0);
      //_history.deleteTable();
      //_favorite.deleteTable();
    });
    print("プロダクト");
    print(const bool.fromEnvironment('dart.vm.product'));
    setDefauldLayout();
    updateScreen();
  }

  updateVersion() async {
    setState(() {
      _versionController = _versionController;
    });
  }

  Future<void> displayNews() async {
    setDefauldLayout();
    await selectCategory(_categoryController.categoryIndex);
    setState(() {
      closeYoutube();
      _videoController.displayLoadingScreen = false;
      _scrollController.jumpTo(_homeLayoutController.getTopMenuHeight());
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
      _homeLayoutController.setForList();
      _homeLayoutController.setHeightForVideoCells();
    });
    if(!await _videoController.displayHistories()){
      displayAlert("ロードに失敗しました");
    }
    setState(() {
      _videoController.displayLoadingScreen = false;
    });
  }

  //Future<void> displayHistory() async {
  //  _videoController.videos = [];
  //  await _history.initDatabase();
  //  List<Map<String, dynamic>> histories = await _history.all();
  //  histories = histories.reversed.toList();
  //  setState(() {
  //    _homeLayoutController.setForList();
  //    _homeLayoutController.setHeightForVideoCells();
  //    _videoController.videos = histories; // 取得したデータを _press 変数に代入
  //    resetPressCount();
  //  });
  //  _homeLayoutController.updateCellsTop(0);
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
      _homeLayoutController.setForList();
      _homeLayoutController.setHeightForVideoCells();
    });
    if(!await _videoController.displayFavorites()){
      displayAlert("ロードに失敗しました");
    }
    setState(() {
      _videoController.displayLoadingScreen = false;
    });
    closeYoutube();
  }

  void setDefauldLayout(){
    setState(() {
      var padding = MediaQuery.of(context).padding;
      _homeLayoutController = HomeLayoutController(
        appBarHeight: 0,
        deviceWidth: _deviceWidth!,
        deviceHeight: _deviceHeight!,
        barHeight: 100,
        innerHeight: _deviceHeight! - padding.top - padding.bottom,
      );
      //_scrollController.jumpTo(100.0);
    });
    _homeLayoutController.setHeightForVideoCells();
  }

  void openYoutube(Video video) async {
    String youtubeId = video.youtubeId;
    _homeLayoutController.displayYoutube();
    _homeLayoutController.setHeightForVideoCells();
    //最後に再生した動画を保存機能
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(Duration.zero);
    setState(() {
      _youtubeController.load( youtubeId,startAt:0);
      _homeLayoutController.updateCellsTop(_scrollController.offset);
    });
    await prefs.setString('default_youtube_id', youtubeId);
    _videoController.createHistory(video);
    //await _history.initDatabase(); 
    //List<Map<String, dynamic>> histories = await _history.all();
    //await _history.create(video);
  }

  void closeYoutube(){
    setState(() {
      _homeLayoutController.hideYoutube();
      _homeLayoutController.setHeightForVideoCells();
      _youtubeController.pause();
    });
  }

  Future<void> selectCategory(int categoryNum) async {
    setState(() {
      _homeLayoutController.displaySearch = false;
      _videoController.changeVideos(categoryNum);
    });
  }

  Future<void> _launchInWebViewOrVC(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $url');
    }
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
      _homeLayoutController.alertHeight = 20;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _homeLayoutController.alertHeight = 0;
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
                }
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
                }
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
        }, 
        isSelectMode: _videoController.isSelectMode
      );
    }
  }

  Widget topNavigation(context){
    return TopNavigation(
      loadController: _loadController,
      homeLayoutController: _homeLayoutController,
      width: _deviceWidth!, 
      controller: _controller, 
      onSearched: (String text) async {
        if(!await _videoController.search(text, _pageController.getCurrentPageName())){
          displayAlert("検索に失敗しました");
        }
        updateVideos();
        _scrollController.jumpTo(_homeLayoutController.loadAreaHeight);
      }, 
      onClosesd: () => setState(() { _homeLayoutController.displaySearch = false; }) , 
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
      searchOpened: (){ setState(() { _homeLayoutController.displaySearch = true; });
      }
    );
  }

  Widget videoCell(BuildContext context, Video video, int index) {
    int cellId = video.id;
    double cellWidth = _deviceWidth!;
    double cellHeight = _deviceWidth! /2 /16 *9;
    List cellIds = _videoController.selection.map((map) => map.id).toList();
    BannerAd? bannerAd;
    if (_pageController.isHomePage() && (index %5 == 2 && index < 15)){
      bannerAd = _bannerAds[index~/5];
      bannerAd.load();
    }
    return 
    Column ( 
      children: [
        VideoCell(
          video: video, 
          isSelectMode: _videoController.isSelectMode,
          isSelected: cellIds.contains(cellId),
          cellHeight: cellHeight, 
          cellWidth: cellWidth, 
          onSelected: () => setState(() { _videoController.selectVideo(video);}),
          onPressedYoutube: () => openYoutube(video),
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
          onPressedTitle: () => openYoutube(video),
        ),
        if (
          bannerAd != null 
          && (
            !_homeLayoutController.isYoutubeDisplaying() 
            || _versionController.isReleased
            )
          )
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: bannerAd.size.width.toDouble(),
            height: bannerAd.size.height.toDouble(),
            child: AdWidget(ad: bannerAd),
          ),
        ),
      ],
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
      _pageController.pageIndex = index;
      _youtubeController.pause();
    });
    updateScreen();
    closeYoutube();
    _homeLayoutController.hideYoutube();
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
    if(_homeLayoutController.loadAreaHeight > 0 && offest < _homeLayoutController.loadAreaHeight){
      scrollToPoint(_homeLayoutController.loadAreaHeight);
    }else if(offest > _homeLayoutController.loadAreaHeight && offest < _homeLayoutController.loadAreaHeight + _homeLayoutController.searchAreaHeight/2){
      scrollToPoint(_homeLayoutController.loadAreaHeight);
    }else if(offest > _homeLayoutController.loadAreaHeight + _homeLayoutController.searchAreaHeight/2 && offest < _homeLayoutController.getTopMenuHeight()){
      scrollToPoint(_homeLayoutController.getTopMenuHeight());
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
      if (before == end) {
        _videoController.displayLoadingScreen = true;
      }
      if (before > 0) {
        _loadController.loadCount = 0;
        _timer?.cancel();
      }
      if(before >= _homeLayoutController.loadAreaHeight){
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
    _homeLayoutController.updateCellsTop(_scrollController.offset);
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
          setState(() {Navigator.of(context).pop();});
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
  

  updatePress() async {
    if(!await _videoController.updatePress(_categoryController.categoryIndex)){
      displayAlert("ロードに失敗しました");
    }
    updateVideos();
  }

  updateVideos(){
    setState(() {
      _videoController = _videoController;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for(var ad in _bannerAds){
      ad.dispose();
    }
    super.dispose();
  }
  
  loadVideos() async {
    if(!await _videoController.loadVideos(_pageController.getCurrentPageName(), _homeLayoutController.displaySearch)){
      displayAlert("ロードに失敗しました");
    }
    setState(() {
      _videoController.displayLoadingScreen = false;
      updateVideos();
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
    Scaffold(
      body:
      SafeArea(
        child:
        Stack(
          children: <Widget>[
            Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(_homeLayoutController.appBarHeight),
                child: AppBar(
                  title: Text("_categoryController.currentCategory.japaneseName"),
                  leading: Container(),
                ),
              ),
              body: 
              SizedBox(
                height: _deviceHeight,
                width: _deviceWidth,
                child: 
                  SizedBox(
                    height: _homeLayoutController.getInnerScrollHeight(),
                    child: 
                    Stack(
                    children: <Widget>[
                      Positioned(
                        right: 0,
                        left: 0,
                        top: _homeLayoutController.listViewTop(),
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
                                updatePress();
                              }
                            }//
                            return true;
                          },
                          child: 
                          ListView(
                            controller: _scrollController,
                            physics: const ClampingScrollPhysics(),
                            children: [
                              SizedBox(
                                width: _deviceWidth!,
                                height: _homeLayoutController.getTopMenuHeight(),
                                //color: Colors.blue,
                              ),
                              //if(_videoController.videos.isNotEmpty)//これがないテーブルごと全て削除した時にエラーが起きる
                              //  for(var video in _videoController.videos)
                              //  videoCell(context, video),
                              for(var i=0; i<_videoController.videos.length; i++)
                                if(_videoController.videos.isNotEmpty)
                                videoCell(context, _videoController.videos[i], i),
                              if(_videoController.displayLoadingScreen)
                              Container(
                                alignment: Alignment.center,
                                width: _deviceWidth,
                                child: 
                                const SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: 
                                  CircularProgressIndicator(
                                    strokeWidth: 8.0,
                                    backgroundColor: Colors.grey,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)
                                  ),
                                ),
                              ),
                              Container(
                                width: _deviceWidth!,
                                height: _homeLayoutController.getbottomSpaceHeight(_videoController.videos.length),
                                color: Colors.white,
                              ),
                            ],
                          )
                        )
                      ),
                      Transform.translate(
                        offset: _homeLayoutController.getTopMenuOffset(),
                        child:topNavigation(context),
                      ),
                      Transform.translate(
                        offset: _homeLayoutController.categorybarOffset(),
                        child: 
                        CategoryBar(
                          controller: _categoryScrollController,
                          barHeight: _homeLayoutController.categoryBarHeight,
                          lineHeight: _homeLayoutController.categoryBarLineHeight,
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
                              selectCategory(_categoryController.categoryIndex);
                              _scrollController.jumpTo(_homeLayoutController.getTopMenuHeight());
                            });
                          },
                        )
                      ),
                      if(_alert != null)
                      Positioned(
                        right: 0,
                        left: 0,
                        top: _homeLayoutController.getAlertTop(),
                        child:
                        Alert(
                          text: _alert!, 
                          width: _deviceWidth!,
                          height: _homeLayoutController.alertHeight
                        )
                      )
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: bottomBar(),
            ),
            Transform.translate(
              offset: _homeLayoutController.youtubePlayerOffset(context),//Offset(0, 0),
                child: SizedBox(
                height: _homeLayoutController.getYoutubeDisplayHeight(context),
                width: _homeLayoutController.getYoutubeDisplayWidth(context),
                child:
                YoutubePlayerBuilder(
                  player: YoutubePlayer(
                    controller: _youtubeController,
                  ),
                  builder: (context, player){
                    return Column(
                      children: [
                      player,
                      ],
                    );
                  },
                ),
              ),
            ),
            Transform.translate(
              offset: _homeLayoutController.youtubeCloseOffset(context),//Offset(0, 0),
              child:
              InkWell(
                child: Container(
                  width: _homeLayoutController.youtubeCloseButtonSize,
                  height: _homeLayoutController.youtubeCloseButtonSize,
                  color: Colors.white,
                  child: Icon(Icons.clear, size: _homeLayoutController.youtubeCloseButtonSize,)
                ),
                onTap: () => closeYoutube(),
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
            ),
          ]
        )
      )
    );
  }
}


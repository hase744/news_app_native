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
import 'package:video_news/models/downloader/mode.dart';
import 'package:video_news/models/ad_display.dart';
import 'package:video_news/views/setting_page.dart';
import 'package:video_news/views/video_cell.dart';
import 'package:video_news/views/alert.dart';
import 'package:video_news/views/category_bar.dart';
import 'package:video_news/views/downloader/video_downloader_page.dart';
import 'package:video_news/views/top_navigation.dart';
import 'package:video_news/views/bottom_menu_bar.dart';
import 'package:video_news/views/bottom_navigation_bar.dart';
import 'package:video_news/views/shared/summarizer_page.dart';
import 'package:video_news/views/shared/display_buttom_button.dart';
import 'package:video_news/controllers/home_layout_controller.dart';
import 'package:video_news/controllers/default_values_controller.dart';
import 'package:video_news/controllers/video_controller.dart';
import 'package:video_news/controllers/category_controller.dart';
import 'package:video_news/controllers/category_bar_controller.dart';
import 'package:video_news/controllers/load_controller.dart';
import 'package:video_news/controllers/page_controller.dart';
import 'package:video_news/controllers/version_controller.dart';
import 'package:video_news/controllers/banner_adds_controller.dart';
import 'package:video_news/consts/config.dart';
import 'package:video_news/consts/device.dart';
import 'package:video_news/helpers/ad_helper.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.initialIndex});
  final int initialIndex;

  @override
  State<HomePage> createState() => _HomePageState();
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
  VideoForm? _currentVideo;
  VideoController _videoController = VideoController();
  ScrollController _scrollController = ScrollController();
  List<ScrollController> _scrollControllers = [];
  VersionController _versionController = VersionController();
  final ScrollController _categoryScrollController = ScrollController();
  final CategoryController _categoryController = CategoryController();
  final LoadController _loadController = LoadController();
  final PageControllerClass _pageController = PageControllerClass();
  final PageController _pressPageController = PageController();
  
  final TextEditingController _controller = TextEditingController();
  late YoutubePlayerController _youtubeController;
  late Future<void> _initializeVideoPlayerFuture;
  late VideoPlayerController _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(''));
  late CategoryBarController _categoryBarController;
  late BannerAddsController _bannerAddsController;
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
      _deviceWidth = MediaQuery.of(context).size.width;
      _deviceHeight = MediaQuery.of(context).size.height;
      if(_versionController.isReleased){
        _youtubeController =  YoutubePlayerController(
          initialVideoId: defaultYoutubeId!,
          flags: const YoutubePlayerFlags(
            autoPlay: false,  // 自動再生しない
          ),
        );
        _youtubeController.addListener(_onChangeYoutube);
      }else{
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(
            '${Config.domain}/videos/MKq4tyzf3Dw.mp4',
          ),
        );
        _videoPlayerController.setLooping(true);
        _initializeVideoPlayerFuture = _videoPlayerController.initialize();
      }
      for(var i =0; i< _categoryController.categories.length; i++){
        ScrollController scrollController = ScrollController(
          initialScrollOffset: (_deviceWidth!*_homeLayoutController.topMenuRatio),
        );
        _scrollControllers.add(scrollController);
        scrollController.addListener(_onScrolls);
      }
      _scrollController = ScrollController(
        initialScrollOffset: (_deviceWidth!*_homeLayoutController.topMenuRatio),
      );
      _bannerAddsController = BannerAddsController(bannerAdCount: 8);
      _scrollController.addListener(_onScroll);
      _pageController.pageIndex = widget.initialIndex;
      _homeLayoutController.updateCellsTop(0);
      _pressPageController.addListener(() => changeCategory(_pressPageController.page!));
      _categoryController.insertAllChildCategories();
      _categoryBarController = CategoryBarController(
        width: _deviceWidth!, 
        categoryController: _categoryController
      );
      //_scrollController.jumpTo(0.0);
      //_history.deleteTable();
      //_favorite.deleteTable();
    });
    setDefauldLayout();
    updateScreen();
  }

  changeCategory(double i){
    Future.delayed(const Duration(seconds: 0), () {
      _categoryScrollController.animateTo(
        _categoryBarController.labelSumSize(_categoryController.categoryIndex),
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    });
    if(i % 1 == 0){
      setState(() {
        if(_categoryController.categoryIndex != i){
          _categoryController.changedCount += 1;
        }
        _categoryController.categoryIndex = i.toInt();
        _videoController.displayVideoList();
        ScrollController scrollController = _scrollControllers[_categoryController.categoryIndex];
        if(scrollController.hasClients){
          scrollController.jumpTo(_homeLayoutController.getTopMenuHeight());
        }
        selectCategory(_categoryController.categoryIndex);
      });
    }
  }

  updateVersion() async {
    setState(() {
      _versionController = _versionController;
    });
  }

  Future<void> displayNews() async {
    setDefauldLayout();
    await _videoController.displayVideoList();
    await selectCategory(_categoryController.categoryIndex);
    setState(() {
      closeYoutube();
      _videoController.displayingLoadingScreen = false;
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
      _videoController.displayingLoadingScreen = true;
      _videoController.displayVideos();
      _homeLayoutController.setForList();
      _homeLayoutController.setHeightForVideoCells();
    });
    if(!await _videoController.displayHistories()){
      displayAlert("ロードに失敗しました");
    }
    setState(() {
      _videoController.displayingLoadingScreen = false;
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
      _videoController.displayingLoadingScreen = true;
      _videoController.displayVideos();
      _homeLayoutController.setForList();
      _homeLayoutController.setHeightForVideoCells();
    });
    if(!await _videoController.displayFavorites()){
      displayAlert("ロードに失敗しました");
    }
    setState(() {
      _videoController.displayingLoadingScreen = false;
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

  void openYoutube(VideoForm video) async {
    String youtubeId = video.youtubeId;
    _homeLayoutController.displayYoutube();
    _homeLayoutController.setHeightForVideoCells();
    //最後に再生した動画を保存機能
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(Duration.zero);
    setState(() {
      _currentVideo = video;
      if(_versionController.isReleased){
        _youtubeController.load( youtubeId,startAt:0);
      }else{
        _initializeVideoPlayerFuture = _videoPlayerController.initialize();
        _videoPlayerController.pause();
        _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse('${Config.domain}/videos/${youtubeId}.mp4'))
        ..initialize().then((_) {
          setState(() {
            _videoPlayerController.play();
          });
        });
      }
      if(_scrollController.hasClients){
        _homeLayoutController.updateCellsTop(_scrollController.offset);
      }else{
        _homeLayoutController.updateCellsTop(_scrollControllers[_categoryController.categoryIndex].offset);
      }
    });
    await prefs.setString('default_youtube_id', youtubeId);
    _videoController.createHistory(video);
    //await _history.initDatabase(); 
    //List<Map<String, dynamic>> histories = await _history.all();
    //await _history.create(video);
  }

  void closeYoutube(){
    setState(() {
      _currentVideo = null;
      _homeLayoutController.hideYoutube();
      _homeLayoutController.setHeightForVideoCells();
      if(_versionController.isReleased){
        _youtubeController.pause();
      }else{
        _videoPlayerController.pause();
      }
    });
  }

  onTappedCategory(int i) async {
    if(_videoController.displayingVideos){
      print(_categoryController.categoryIndex);
      selectCategory(_categoryController.categoryIndex);
      await _videoController.displayVideoList();
      setState(() {

        _videoController = _videoController;
      });
    }else{
      _pressPageController.jumpToPage(i);
    }
  }

  Future<void> selectCategory(int categoryNum) async {
    setState(() {
      _videoController.displayVideoList();
      _homeLayoutController.displayingTextField = false;
      _videoController.searchingCategory = null;
      _videoController.videos = [];
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
    case 'downloader':
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DownLoaderPage(
          path: '/video',
          target: null,
          downloadList: [],
          mode: Mode.play,
        )),
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
  
  openSummarizer(VideoForm video){
    setState(() {
      showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
        isScrollControlled: true,
        isDismissible: true,
        context: context, 
        builder: (context) => SummarizerPage(
          video: video,
          height: _deviceHeight!,
          width: _deviceWidth!,
          onClosed:() {
            Navigator.of(context).pop();
          },
        )
      );
    });
  }

  moveToDownloaderPage(List<VideoForm> videos){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DownLoaderPage(
        path: '/video',
        target: null,
        downloadList: videos,
        mode: Mode.select,
      )),
    );
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
            case 'download':
              moveToDownloaderPage(_videoController.selection);
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
        isReleased: _versionController.isReleased,
        initialIndex: _pageController.pageIndex, 
        onTap: (int index){
                        print("ストップ");
          if(_versionController.isReleased){
            _youtubeController.pause();
          }else{
            _videoPlayerController.pause();
          }
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
      onClosesd: () => setState(() { _homeLayoutController.displayingTextField = false; }) , 
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
      searchOpened: (){ setState(() { _homeLayoutController.displayingTextField = true; });
      }
    );
  }

  Widget videoCell(BuildContext context, VideoForm video, int videoIndex, int? categoryIndex) {
    int cellId = video.id;
    double cellWidth = _deviceWidth!;
    double cellHeight = _deviceWidth! /2 /16 *9;
    List cellIds = _videoController.selection.map((map) => map.id).toList();
    return 
    Column ( 
      children: [
        VideoCell(
          video: video, 
          isSelectMode: _videoController.isSelectMode,
          isSelected: cellIds.contains(cellId),
          isReleased: _versionController.isReleased,
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
        if(categoryIndex == null || categoryIndex == _categoryController.categoryIndex)
        adDisplay(videoIndex),
      ],
    );
  }

  Widget adDisplay(int index){
    int addLength = _bannerAddsController.bannerAds.length;
    int halfAddLength = (addLength/2).toInt();
    int interval = 5;
    if (!_pageController.isHomePage()) {
      return const SizedBox();
    } else if (index % interval != 2) {
      return const SizedBox();
    } else if ((index ~/ interval) > (addLength/2 -1)) {
      return const SizedBox();
    } else if (!_versionController.isReleased) {
      return const SizedBox();
    } else {
      int adNumber = index~/interval +1;
      int groupCount = _categoryController.changedCount%2;
      int adCount = adNumber+(groupCount*halfAddLength)-1;
      BannerAd bannerAd = _bannerAddsController.bannerAds[adCount];
      bannerAd.load();
      return Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: bannerAd.size.width.toDouble(),
          height: bannerAd.size.height.toDouble(),
          child: AdWidget(ad: bannerAd),
        ),
      );
    }
  }

  launchWebView (VideoForm video){
    final Uri toLaunch = Uri(
      scheme: 'https',
      host: 'www.youtube.com',
      path: "watch",
      queryParameters: {'v': video.youtubeId}
    );
    _launched = _launchInWebViewOrVC(toLaunch);
  }

  scrollToPoint(double offset){
    Future.delayed(const Duration(seconds: 0), () {
      _scrollControllers[_categoryController.categoryIndex].animateTo(
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

  void _onChangeYoutube(){
    if(_homeLayoutController.displayingYoutubeControl != _youtubeController.value.isControlsVisible){
      setState(() {
        _homeLayoutController.displayingYoutubeControl = _youtubeController.value.isControlsVisible;
      });
    }
  }

  _onScrolls() {
    if(_scrollControllers.length <= _categoryController.categoryIndex){
      return;
    }
    ScrollController scrollController =  _scrollControllers[_categoryController.categoryIndex];
    if(!scrollController.hasClients){
      return;
    }
    final before = scrollController.position.pixels;
    final end = scrollController.position.maxScrollExtent;
    if (before == end) {
      setState(() {
      _videoController.displayingLoadingScreen = true;
      });
    }
    if (_loadController.loadCount > 0 && before > 0) {
      setState(() {
      _loadController.loadCount = 0;
      _timer?.cancel();
      });
    }
    if(_loadController.isLoading && before >= _homeLayoutController.loadAreaHeight){
      setState(() {
      _loadController.isLoading = false;
      });
    }
    if(before <= 0 && !_loadController.loadCounting){
      if(_pageController.isHomePage()){
        setState(() {
        _loadController.loadCounting = true;
        countLoad();
        });
      }
    }
    if(_loadController.loadCounting && (before > 0 || _loadController.loadCount >= _loadController.maxLoadCount)){
      setState(() {
      _loadController.loadCounting = false;
      _loadController.loadCount = 1;
      });
    }
    if(_homeLayoutController.videoCellsTop <= _homeLayoutController.getTopMenuHeight()-1 || 
    scrollController.offset < _homeLayoutController.getTopMenuHeight()){
      setState(() {
      _homeLayoutController.updateCellsTop(scrollController.offset);
      });
    }
    //FocusScope.of(context).unfocus();
  }

  void _onScroll() {
    if(!_scrollController.hasClients){
      return;
    }
    final before = _scrollController.position.pixels;
    final end = _scrollController.position.maxScrollExtent;
      if (before == end) {
    setState(() {
        _videoController.displayingLoadingScreen = true;
    });
      }
    _homeLayoutController.updateCellsTop(_scrollController.offset);
    FocusScope.of(context).unfocus();
  }

  List<MenuButton> videoButtons(BuildContext context, VideoForm video){
    bool isFavorite = _pageController.isFavoritePage();
    bool isHistory = _pageController.isHistoryPage();
    return [
      if(_versionController.isReleased)
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
      MenuButton(
        onPressed: () async {
          setState(() {
            Navigator.of(context).pop();
          });
          openSummarizer(video);
        },
        isDestractive: false,
        name: "AIの内容要約"
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
      MenuButton(
        onPressed: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DownLoaderPage(
              path: '/video',
              target: null,
              downloadList: [video],
              mode: Mode.select,
            )),
          );
        },
        isDestractive: false,
        name: "ダウンロード"
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
      _videoController.displayingAllVideos = true;
      _videoController = _videoController;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  loadVideos() async {
    if(!await _videoController.loadVideos(_pageController.getCurrentPageName(), _homeLayoutController.displayingTextField)){
      displayAlert("ロードに失敗しました");
    }
    setState(() {
      _videoController.displayingLoadingScreen = false;
      updateVideos();
    });
  }

  selectChildCategory(String name) async {
    setState(() {
      _videoController.coverVideoAndVideoList();
      _videoController.searchCategory(name);
    });
    setState(() {
      _videoController.displayingLoadingScreen = false;
      _videoController.videos = _videoController.videos;
    });
    updateVideos();
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

  Widget buttonsArea(BuildContext context){
    return 
    Container(
      width: _deviceWidth,
      height: _deviceWidth!/10,
      child:
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            DisplayButtomButton(
              height: _deviceWidth!/10,
              icon: Icons.summarize,
              label: 'AI要約',
              onPushed: () => openSummarizer(_currentVideo!)
            ),
            DisplayButtomButton(
              height: _deviceWidth!/10,
              icon: Icons.download,
              label: 'ダウンロード',
              onPushed: () => moveToDownloaderPage([_currentVideo!])
            ),
            DisplayButtomButton(
              height: _deviceWidth!/10,
              icon: Icons.favorite,
              label: 'お気に入り',
              onPushed: () async {
                if(await _videoController.createFavorite(_currentVideo!)){
                  displayAlert('追加しました');
                }else{
                  displayAlert('追加に失敗しました');
                }
              }
            ),
            DisplayButtomButton(
              height: _deviceWidth!/10,
              icon: Icons.clear,
              label: '閉じる',
              onPushed: () => closeYoutube(),
            ),
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
      _deviceWidth = MediaQuery.of(context).size.width;
      _deviceHeight = MediaQuery.of(context).size.height;
      _categoryBarController = CategoryBarController(
        width: _deviceWidth!, 
        categoryController: _categoryController
      );
      //_initializeVideoPlayerFuture = _videoPlayerController.initialize();
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
                          _videoController.displayingVideos?
                          ListView(
                            controller: _scrollController,
                            physics: const ClampingScrollPhysics(),
                            children: [
                              SizedBox(
                                width: _deviceWidth!,
                                height: _homeLayoutController.getTopMenuHeight(),
                              ),
                              for(var i=0; i<_videoController.videos.length; i++)
                                videoCell(context, _videoController.videos[i], i, null),
                            ]
                          ):
                          PageView(
                            controller: _pressPageController,
                            children: 
                              [
                              for (var j = 0; j < _videoController.videosList.length; j++)
                              ListView(
                                addAutomaticKeepAlives: true,
                                controller: _scrollControllers[j],
                                physics: const ClampingScrollPhysics(),
                                children: [
                                  SizedBox(
                                    width: _deviceWidth!,
                                    height: _homeLayoutController.getTopMenuHeight(),
                                  ),
                                  if(_currentVideo != null)
                                  buttonsArea(context),
                                  //if(_categoryController.childCategoriesList.isNotEmpty && _categoryController.childCategoriesList[j].isNotEmpty)
                                  //Container(
                                  //  height: _homeLayoutController.categoryBarHeight, // Set the height of the button row
                                  //  child: ListView.builder(
                                  //    addAutomaticKeepAlives: true,
                                  //    scrollDirection: Axis.horizontal,
                                  //    itemCount: _categoryController.childCategoriesList[j].length,
                                  //    itemBuilder: (context, index) {
                                  //      return Padding(
                                  //        padding: EdgeInsets.all(_homeLayoutController.categoryBarHeight/8),
                                  //        child: ElevatedButton(
                                  //          onPressed: () => selectChildCategory(_categoryController.childCategoriesList[j][index].name),
                                  //          style: ElevatedButton.styleFrom(
                                  //            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_homeLayoutController.categoryBarHeight/8),),
                                  //            elevation: 0,
                                  //            backgroundColor: Colors.blueGrey[50],
                                  //          ),
                                  //          child: Text(
                                  //            _categoryController.childCategoriesList[j][index].japaneseName,
                                  //            style: const TextStyle(
                                  //              color: Colors.black, // Adjust the value as needed
                                  //            )
                                  //          ),
                                  //        ),
                                  //      );
                                  //    },
                                  //  ),
                                  //),
                                  if(_videoController.displayingAllVideos && _videoController.displayingVideoList)
                                  for(var i=0; i<_videoController.videosList[j].length; i++)
                                    videoCell(context, _videoController.videosList[j][i], i, j),
                                  if(_videoController.displayingLoadingScreen)
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
                                  ),
                                ],
                              )
                            ],
                          ),
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
                          categoryBarController: _categoryBarController,
                          width: _deviceWidth!,
                          categoryController: _categoryController,
                          onSelected: (int i) => onTappedCategory(i),
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
                Stack(
                  children: <Widget>[
                  if(_versionController.isReleased)
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
                  if(_homeLayoutController.displayingYoutubeControl)
                  InkWell(
                    child: 
                    Container(
                      width: _homeLayoutController.getYoutubeDisplayWidth(context)*2/5,
                      height: _homeLayoutController.getYoutubeDisplayWidth(context)/16*5,
                      margin: EdgeInsets.only(top: _homeLayoutController.getYoutubeDisplayWidth(context)/16*(Device.isVertical(context) ? 2 : 1)),
                      child: 
                      AnimatedOpacity(
                        duration: Duration(milliseconds: _homeLayoutController.rewinded ? 0 : 500),
                        opacity: _homeLayoutController.rewinded ? 1 : 0.5,
                        child:
                        Icon(
                          Icons.chevron_left,
                          size: _homeLayoutController.getYoutubeDisplayWidth(context)/16*3,
                          color: Colors.white,
                        ),
                      )
                    ),
                    onTap: (){
                      setState(() {
                        _youtubeController.seekTo(_youtubeController.value.position - const Duration(seconds: 10));
                        _homeLayoutController.rewinded = true;  
                        Future.delayed(const Duration(milliseconds: 500), () {
                            _homeLayoutController.rewinded = false;
                        });
                      });
                    },
                  ),
                  if(_homeLayoutController.displayingYoutubeControl)
                  Align( // 赤のコンテナだけを右下に配置する
                    alignment: Alignment.topRight,
                    child: 
                    InkWell(
                      child: 
                      Container(
                        width: _homeLayoutController.getYoutubeDisplayWidth(context)*2/5,
                        height: _homeLayoutController.getYoutubeDisplayWidth(context)/16*5,
                        margin: EdgeInsets.only(top: _homeLayoutController.getYoutubeDisplayWidth(context)/16*(Device.isVertical(context) ? 2 : 1)),
                        child: 
                        AnimatedOpacity(
                          duration: Duration(milliseconds: _homeLayoutController.fastForwarded ? 0 : 500),
                          opacity: _homeLayoutController.fastForwarded ? 1 : 0.5,
                          child:
                          Icon(
                            Icons.chevron_right,
                            size: _homeLayoutController.getYoutubeDisplayWidth(context)/16*3,
                            color: Colors.white,
                          ),
                        )
                      ),
                      onTap: (){
                        setState(() {
                          _youtubeController.seekTo(_youtubeController.value.position + const Duration(seconds: 10));
                          _homeLayoutController.fastForwarded = true;  
                          Future.delayed(const Duration(milliseconds: 500), () {
                              _homeLayoutController.fastForwarded = false;
                          });
                        });
                      },
                    )
                  ),
                  if(_homeLayoutController.displayingYoutubeControl && MediaQuery.of(context).orientation == Orientation.portrait)
                  Align(
                    alignment: Alignment.topRight,
                    child: 
                    InkWell(
                      child: Container(
                        width: _homeLayoutController.youtubeCloseButtonSize,
                        height: _homeLayoutController.youtubeCloseButtonSize,
                        //color: Colors.white,
                        child: 
                        Icon(
                          Icons.clear, 
                          size: _homeLayoutController.youtubeCloseButtonSize,
                          color: Colors.white,
                        )
                      ),
                      onTap: () => closeYoutube(),
                    ),
                  ), 
                  if(!_versionController.isReleased)
                  FutureBuilder(
                    future: _initializeVideoPlayerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return  
                          Center(
                            child:
                            AspectRatio(
                          aspectRatio: _videoPlayerController.value.aspectRatio,
                          child: VideoPlayer(_videoPlayerController),
                          )
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                  if(!_versionController.isReleased)
                  InkWell(
                    child: Container(
                      width: _deviceWidth!,
                      height: _deviceWidth!/16*9,
                    ),
                    onTap: (){
                      setState(() {
                        _homeLayoutController.displayingVideoButton = !_homeLayoutController.displayingVideoButton;
                      });
                      if(_homeLayoutController.displayingVideoButton){
                        Future.delayed(const Duration(seconds: 3), () {
                          setState(() {
                              _homeLayoutController.displayingVideoButton = false;
                          });
                        });
                      }
                    },
                  ),
                  if(_homeLayoutController.displayingVideoButton && !_versionController.isReleased)
                  Positioned(
                    right: _deviceWidth!/3,
                    top: _deviceWidth!*(9/16 - 1/3)/2,
                    child: 
                    InkWell(
                      child: Container(
                        child: Icon(
                          size: _deviceWidth!/3,
                          color: Colors.white,
                          _videoPlayerController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                      onTap: (){
                        setState(() {
                          if (_videoPlayerController.value.isPlaying) {
                            _videoPlayerController.pause();
                          } else {
                            _videoPlayerController.play();
                          }
                        });
                        Future.delayed(const Duration(seconds: 2), () {
                          setState(() {
                            _homeLayoutController.displayingVideoButton = false;
                          });
                        });
                      },
                    )
                  ),
                ])
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


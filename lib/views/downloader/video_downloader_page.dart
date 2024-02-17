import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_news/helpers/page_transition.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:chewie/chewie.dart';
import 'package:video_news/consts/navigation_list_config.dart';
import 'package:video_news/controllers/video_db_controller.dart';
import 'package:video_news/controllers/page_controller.dart';
import 'package:video_news/controllers/banner_adds_controller.dart';
import 'package:video_news/controllers/directory/directory_ontroller.dart';
import 'package:video_news/controllers/downloader/downloader_controller.dart';
import 'package:video_news/views/downloader/text_editing_dialog.dart';
import 'package:video_news/views/downloader/cell.dart';
import 'package:video_news/views/bottom_menu_bar.dart';
import 'package:video_news/views/bottom_navigation_bar.dart';
import 'package:video_news/views/home_page.dart';
import 'package:video_news/models/downloader/mode.dart';
import 'package:video_news/models/video.dart';
import 'package:video_news/models/downloader/folder.dart';
import 'package:video_news/models/downloader/video_data.dart';
import 'package:video_news/models/downloader/file_type.dart';
import 'package:video_news/models/downloader/file_form.dart';
import 'package:video_news/models/downloader/path_form.dart';
import 'package:video_news/models/menu_button.dart';
import 'package:video_news/models/downloader/downloading_data.dart';
import 'package:video_news/models/direction.dart';
import 'package:video_news/consts/navigation_list_config.dart';
import 'package:http/http.dart' as http;
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';

class DownLoaderPage extends StatefulWidget {
  final String? path;
  final VideoData? target;
  final Mode mode;
  final List<VideoForm> downloadList;
  const DownLoaderPage({
    super.key,
    required this.path, 
    required this.target, 
    required this.mode, 
    required this.downloadList,
  });

  @override
  State<DownLoaderPage> createState() => _DownLoaderPageState();
}

class _DownLoaderPageState extends State<DownLoaderPage> {
  final yt = YoutubeExplode();
  final _videoForm = FileForm(type: FileType.video);
  final _imageForm = FileForm(type: FileType.image);
  VideoPlayerController _videoPlayerController = VideoPlayerController.file(
        File(''),
      );
  final PageControllerClass _pageController = PageControllerClass();
  late DirectoryController _directoryController = DirectoryController(currentPath: _currentPath);
  late final DownloaderController _downloaderController = DownloaderController(
    downloadPath: _currentPath, 
    relativeDownloadPath: widget.path!,
    onProcessed: (p)=>{
      setState((){
        //_progress = 0.5;
        _progress = p;
      })
    }
  );

  late ChewieController _chewieController;
  late String _appDirPath;
  List<VideoData> _videoDatas = [];
  List<Folder> _folders = [];
  DbController dbController = DbController();
  BannerAddsController _bannerAddsController = BannerAddsController(bannerAdCount: 1);
  String youtubeId = "";
  String fileDirectory = '';
  String _currentPath = '';
  double? _deviceWidth;
  double? _deviceHeight;
  double _progress = 0.0;
  List<double> progresses = [];
  List<DownloaderController> downloaderControllers = [];
  //List<Map<String, Map<String, dynamic>>> downloadingList = [];
  List<DownloadingData> downloadingList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = dir.path;
    _currentPath = '$path/${widget.path}';
    _directoryController = DirectoryController(currentPath: _currentPath);
    fileDirectory = (await getApplicationDocumentsDirectory()).path;
    setState(() {
      _currentPath = _currentPath;
      _pageController.pageIndex = 2;
      _deviceWidth = MediaQuery.of(context).size.width;
      _deviceHeight = MediaQuery.of(context).size.height;
      _appDirPath = dir.path;
      _videoPlayerController = VideoPlayerController.file(
        File(''),
      )..initialize().then((_) {
        _chewieController = _getChewieController(16/9);
      });
      dbController.initDatabase();
    });
    if(widget.mode == Mode.download){
      await downoloadAndTransit();
    }
    await _directoryController.updateDirectories();
    await dbController.initDatabase();
    //print("サムネ");
    //for(var data in await dbController.all()){
    //  print(data['video_path']);
    //  print(data['thumbnail_path']);
    //}
    updateFolders();
    updateVideoDatas();
  }

  buildInit() async {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    final dir = await getApplicationDocumentsDirectory();
    _appDirPath = dir.path;
  }

  downoloadAndTransit() async{
    for(var i=0; i <widget.downloadList.length; i++){
      downloadingList.add(
        DownloadingData(
          progress: 0.0,
          form: widget.downloadList[i],
          controller: 
           DownloaderController(
            relativeDownloadPath: widget.path!,
             downloadPath: _currentPath, 
             onProcessed: (p)=>{
                setState((){
                  downloadingList[i].progress = p;
                })
             }
           )
        )
      );
    }
    for(var elemnt in downloadingList){
      await elemnt.controller.download(
        elemnt.form.youtubeId, 
        FileType.video
      );
    }
    movePage( 
      DownLoaderPage(
        path: widget.path, 
        mode: Mode.play, 
        target: null, 
        downloadList: const [],
      )
    );
  }

  updateFolders() async {
    List<FileSystemEntity> folders = await _directoryController.getDirectoriesOf(null);
    folders.sort((a,b) => Folder(path: a.path).name.compareTo(Folder(path: b.path).name));//ソート
    setState(() {
      _folders = [];
      for(var folder in folders){
        _folders.add(Folder(path: folder.path.toString()));
      }
    });
  }

  updateVideoDatas() async {
    List directories = await _directoryController.getDirectoriesOf(_videoForm.extension!);
    List dataPaths = directories.map((video) => video.path).toList(); 
    dataPaths = dataPaths.map((element) {
      return element.replaceFirst('$_appDirPath/', '');
    }).toList();
    _videoDatas = [];
    for(var data in await dbController.getVideosByPaths(dataPaths)){
      VideoData videoData = VideoData.fromDb(data);
      //print(await (await FFmpegKit.execute('-i ${VideoData.fromDb(data).videoPath}')).getOutput());
      await FFprobeKit.getMediaInformation('$_appDirPath${VideoData.fromDb(data).videoPath}').then((session) async {
        final information = session.getMediaInformation();
        final stream = information!.getStreams()[0];
        videoData.duration = await Duration(seconds: double.parse(information.getDuration()!).toInt());
        videoData.aspect = stream.getWidth()!/stream.getHeight()!;
      });
      setState(() {
        _videoDatas.add(
          videoData
        );
      });
    }
  }

  _getChewieController(double aspect){
    return 
    ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: aspect,  //アスペクト比
      autoPlay: false,  //自動再生
      looping: true,  //繰り返し再生
      showControls: true,  //コントロールバーの表示（デフォルトではtrue）
      autoInitialize: true,  //widget呼び出し時に動画を読み込むかどうか
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
    );
  }

  getUniqueFileName(String title, FileType type) async {
    final fileForm = FileForm(type: type);
    String fileName = '${await _downloaderController.getArrangedFileName(title)}${fileForm.extension!}';
    List titles = await _directoryController.getFileTitlesByDirectory(type);
    var newTitle = fileName;
    for(var i = 1; titles.contains(newTitle); i++ ){
      newTitle = '${await _downloaderController.getArrangedFileName(title)}($i)${fileForm.extension!}';
    }
    return newTitle.split('.').first;
  }

  Future<String?> showEditingDialog(
    BuildContext context,
    String text,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return TextEditingDialog(
          title: "フォルダを新規作成",
          name: '',
          onEntered: (string) async {
            final newDirectory = Directory('$_currentPath/$string/');
            await newDirectory.create(recursive: true);
            updateFolders();
            Navigator.of(context).pop();
          },
        );
      },
    );
   }

  Future<String?> showRenamingDialog(
    BuildContext context,
    String name,
    ) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return TextEditingDialog(
          title: "フォルダ名を変更",
          name: name,
          onEntered: (string) async {
            var oldPath = '$_currentPath/$name/';
            var newPath = '$_currentPath/$string/';
            final oldDirectory = Directory(oldPath);
            final newDirectory = Directory(newPath);
            await oldDirectory.rename(newDirectory.path);
            for(var file in await dbController.getRecordByPartialPath(oldPath)){
              VideoData data = VideoData.fromDb(file);
              data.replaceFolder(oldPath, newPath);
              dbController.updateVideo(data.id!, data);
            }
            updateFolders();
            setState(() {
              Navigator.of(context).pop(string);
            });
          },
        );
      },
    );
  }

  List<MenuButton> videoButtons(BuildContext context, VideoData data){
    return [
      MenuButton(
        onPressed: () async {
          setState(() {
            Navigator.of(context).pop();
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DownLoaderPage(
                path: '/video', 
                mode: Mode.transfer, 
                target: data, 
                downloadList: const [],
                )
              )
          );
        },
        isDestractive: false,
        name: "移動"
      ),
      MenuButton(
        onPressed: () async {
          await dbController.delete(data.id!);
          Directory('$_appDirPath${data.videoPath}').delete(recursive: true);
          setState(() {
            updateVideoDatas();
            Navigator.of(context).pop();
          });
        },
        isDestractive: true,
        name: "削除"
      ),
    ];
  }
  List<MenuButton> folderButtons(BuildContext context, Folder folder){
    return [
      MenuButton(
        onPressed: () async {
          Navigator.of(context).pop();
          showRenamingDialog(context, folder.name);
        },
        isDestractive: false,  
        name: "名前を変更"
      ),
      MenuButton(
        onPressed: () async {
          String relativePath = folder.path.replaceAll('$_appDirPath/', '');
          await dbController.deleteByPartialPath("$relativePath/");
          await Directory(folder.path).delete(recursive: true);
          setState(() {
            updateFolders();
            Navigator.of(context).pop();
          });
        },
        isDestractive: true,  
        name: "削除"
      ),
    ];
  }

  openMenu(VideoData video){
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(video.videoPathForm.title),
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
  }

  openFolderMenu(Folder folder){
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(folder.path.split('/').last),
        //message: const Text('Message'),
        actions: <CupertinoActionSheetAction>[
          for(var button in folderButtons(context, folder))
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
  }

  backPage(StatefulWidget page){
    PageTransition.move(page, context, Direction.left);
  }

  movePage(StatefulWidget page){
    PageTransition.move(page, context, Direction.right);
  }

  String folderTitle(String path){
      return path == 'video'?
      'オフライン':
      path;
  }

  @override
  Widget build(BuildContext context) {
    buildInit();
    return Scaffold(
      appBar: AppBar(
        leadingWidth: _deviceWidth!/3,
        leading: 
        widget.path! == '/video'?
        const SizedBox():
        InkWell(
          child:
          Container(
            //color: Colors.white,
            child: 
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: _deviceWidth!/60), // Adjust the left margin as needed
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: _deviceWidth!/20,
                    color: Colors.black87,
                  ),
                ),
                Expanded(
                  child: 
                  Container(
                  padding: new EdgeInsets.only(right: 10.0),
                  child:
                    Text(folderTitle(widget.path!.split('/')[widget.path!.split('/').length-2]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: _deviceWidth!/25,
                      )
                    )
                  )
                )
              ]
            ),
          ),
          onTap: () async {
            _videoPlayerController.pause();
            backPage(DownLoaderPage(
              path: await Folder(path: _currentPath).parentRelativePath, 
              mode: widget.mode, 
              target: widget.target,
              downloadList: const [],
              )
            );
          }
        ),
        title: Text(folderTitle(widget.path!.split('/').last)),
        actions: [
          IconButton(
            onPressed: () {
              showEditingDialog(context, "aa");
            },
            icon: const Icon(
              Icons.create_new_folder,
              color: Colors.black54,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if(widget.mode == Mode.play)
            _videoPlayerController.value.isInitialized?
            AspectRatio(
              aspectRatio: 16/9,
              child: Chewie(controller: _chewieController),
            ): 
            const SizedBox.shrink(),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(0.0),
                children: <Widget>[
                  if(widget.mode == Mode.download)
                  for(var video in downloadingList)
                  DownLoaderCell(
                    cellWidth: _deviceWidth!,
                    video: video.form,
                    //downloaderController: _downloaderController,
                    progress: video.progress,
                  ),
                  for(var folder in _folders)
                  SizedBox(
                    width: _deviceWidth!/10,
                    child:
                    ListTile(
                      leading: const Icon(Icons.folder),
                      contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
                      title: 
                      Row(
                        children: [
                          Expanded(
                            child:
                            SizedBox(
                              width: _deviceWidth!*8/10,
                              child: Text(
                                folder.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                )
                            )
                          ),
                          InkWell(
                            child: 
                            SizedBox(
                              height: _deviceWidth!/10,
                              width: _deviceWidth!/10,
                              child: const Icon(Icons.tune),
                            ),
                            onTap: () => openFolderMenu(folder),
                          )
                        ],
                      ),
                      onTap: () {
                        _videoPlayerController.pause();
                        movePage(
                          DownLoaderPage(
                            path: "${widget.path!}/${folder.name}", 
                            mode: widget.mode, target: widget.target,
                            downloadList: widget.downloadList
                          )
                        );
                      },
                    ),
                  ),
                  if(widget.mode == Mode.play)
                  for(var data in _videoDatas)
                  ListTile(
                    contentPadding: const EdgeInsets.all(0.0),
                    title: Row (
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: _deviceWidth!/60),
                          margin: const EdgeInsets.all(0),
                          height: _deviceWidth!/32*9,
                          width: _deviceWidth!/2,
                          child: 
                          ClipRRect(
                            borderRadius: BorderRadius.circular(_deviceWidth!/30),
                            child: Image.file(
                              File(_appDirPath+data.thumbnailPath),
                              fit: BoxFit.cover,
                              )
                          )
                        ),
                        SizedBox(
                          height: _deviceWidth!/32*9,
                          width: _deviceWidth!/2,
                          child: 
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.all(_deviceWidth!/60),
                                margin: const EdgeInsets.all(0),
                                height: _deviceWidth!/32*6,
                                width: _deviceWidth!/2,
                                child: Text(
                                  data.videoPathForm.title,
                                  maxLines: 3,
                                  style: TextStyle(
                                    fontSize: _deviceWidth!/30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ),
                              Container(
                                padding: EdgeInsets.only(left: _deviceWidth!/60),
                                child: 
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      data.durationString,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: _deviceWidth!/30,
                                      ),
                                    ),
                                    const Expanded(child: SizedBox()),
                                    InkWell(
                                      child: 
                                      SizedBox(
                                        height: _deviceWidth!/32*3,
                                        width: _deviceWidth!/32*3,
                                        child: const Icon(Icons.more_horiz),
                                      ),
                                      onTap: () => openMenu(data),
                                    )
                                  ],
                                )
                              )
                            ],
                          )
                        )
                      ],
                    ),
                    onTap: () {
                      _videoPlayerController.pause();
                      _videoPlayerController = VideoPlayerController.file(
                          File(_appDirPath+'/'+data.videoPath),
                        )..initialize().then((_) {
                        setState(() {
                          _videoPlayerController = _videoPlayerController;
                          _chewieController = _getChewieController(data.aspect!);
                          _videoPlayerController.play();
                        });
                      });
                    },
                  ),
                ],
              )
            ),
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: _bannerAddsController.bannerAds[0].size.width.toDouble(),
                height: _bannerAddsController.bannerAds[0].size.height.toDouble(),
                child: AdWidget(ad: _bannerAddsController.bannerAds[0]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: 
      widget.mode == Mode.transfer?
      BottomMenuNavigationBar(
        initialIndex: 0,
        list: NavigationListConfig.downloaderMenuList,
        onTap: (i) async {
          switch(NavigationListConfig.downloaderMenuList[i].name){
          case 'close':
            //String path = await _directoryController.getFolderByVideo(widget.target!);
            backPage(
              DownLoaderPage(
                path: widget.path, 
                mode: Mode.play, 
                target: null,
                downloadList: const [],
              )
            );
          case 'transit':
            FileForm form = widget.target!.videoPathForm.fileForm;
            var videoTitle = widget.target!.videoPathForm.titleWithoutExtension;
            var thumbnailTitle = widget.target!.thumbnailPathForm.titleWithoutExtension;
            videoTitle = await getUniqueFileName(videoTitle, form.formType);
            thumbnailTitle = await getUniqueFileName(videoTitle, FileType.image);
            var pathDestination = "$_currentPath/$videoTitle${_videoForm.extension!}";
            var thumbnailDestination = "$_currentPath/$thumbnailTitle${_imageForm.extension!}";
            await File('$_appDirPath${widget.target!.videoPath}').rename(pathDestination);
            await File('$_appDirPath${widget.target!.thumbnailPath}').rename(thumbnailDestination);
            VideoData newVideo = widget.target!;
            newVideo.videoPath = pathDestination.replaceFirst('$_appDirPath/', '');
            newVideo.thumbnailPath = thumbnailDestination.replaceFirst('$_appDirPath/', '');
            dbController.updateVideo(widget.target!.id!, newVideo);
            movePage(
              DownLoaderPage(
              path: widget.path, 
              mode: Mode.play, 
              target: null,
              downloadList: const [],
            ));
          }
        },
      ):
      widget.mode == Mode.select?
      BottomMenuNavigationBar(
        initialIndex: 1,
        list: NavigationListConfig.selectaModeMenuList,
        onTap: (i) async {
          switch(NavigationListConfig.selectaModeMenuList[i].name){
          case 'close':
            movePage(
              DownLoaderPage(
                path: widget.path!, 
                mode: Mode.play,
                target: null,
                downloadList: const [],
              )
            );
          case 'download':
            movePage(
              DownLoaderPage(
                path: widget.path!, 
                mode: Mode.download,
                target: null,
                downloadList: widget.downloadList,
              )
            );
          }
        },
      ):
      HomeBottomNavigationBar(
        initialIndex: 3,
        onTap: (int index) {
          _videoPlayerController.pause();
        },
        isSelectMode: false
      ),

    );
  }
  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
  }
}
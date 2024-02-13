import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:chewie/chewie.dart';
import 'package:video_news/consts/navigation_list_config.dart';
import 'package:video_news/controllers/video_db_controller.dart';
import 'package:video_news/controllers/page_controller.dart';
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
import 'package:http/http.dart' as http;

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
  late VideoPlayerController _videoPlayerController;
  final PageControllerClass _pageController = PageControllerClass();
  late DirectoryController _directoryController = DirectoryController(currentPath: _currentPath);
  late final DownloaderController _downloaderController = DownloaderController(
    downloadPath: _currentPath, 
    onProcessed: (p)=>{
      setState((){
        _progress = p;
      })
    }
  );

  late ChewieController _chewieController;
  List<VideoData> _videoDatas = [];
  List<Folder> _folders = [];
  DbController dbController = DbController();
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
      _videoPlayerController = VideoPlayerController.file(
        File(''),
      )..initialize().then((_) {
        _chewieController = _getChewieController();
      });
      dbController.initDatabase();
      if(widget.mode == Mode.download){
        for(var i=0; i <widget.downloadList.length; i++){
          downloadingList.add(
            DownloadingData(
              progress: 0.0,
              form: widget.downloadList[i],
              controller: 
               DownloaderController(
                 downloadPath: _currentPath, 
                 onProcessed: (p)=>{
                    print(p),
                    setState((){
                      downloadingList[i].progress = p;
                    })
                 }
               )
            )
          );
        }
      }
      for(var elemnt in downloadingList){
        elemnt.controller.download(
          elemnt.form.youtubeId, 
          FileType.video
        );
      }
    });
    await _directoryController.updateDirectories();
    await dbController.initDatabase();
    //print("サムネ");
    //for(var data in await dbController.all()){
    //  print(data['path']);
    //  print(data['thumbnail']);
    //}
    await updateVideoDatas();
    await updateFolders();
  }

  buildInit(){
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
  }

  updateFolders() async {
    List<FileSystemEntity> folders = await _directoryController.getDirectoriesOf(null);
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
    _videoDatas = [];
    for(var data in await dbController.getVideosByPaths(dataPaths)){
      setState(() {
        _videoDatas.add(
          VideoData.fromDb(data)
        );
      });
    }
  }

  _getChewieController(){
    return 
    ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 16 / 9,  //アスペクト比
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
            print(string);
            final newDirectory = Directory('${_currentPath}/$string/');
            await newDirectory.create(recursive: true);
            setState(() {
              _directoryController.updateDirectories();
            });
            Navigator.of(context).pop();
            print("アップデート");
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
            await _directoryController.updateDirectories();
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
                path: 'video', 
                mode: Mode.transfer, 
                target: data, 
                downloadList: [],
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
          Directory(data.videoPath).delete(recursive: true);
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
          await dbController.deleteByPartialPath("${folder.path}/");
          await Directory(folder.path).delete(recursive: true);
          setState(() {
            updateFolders();
            Navigator.of(context).pop();
          });
        },
        isDestractive: true,  
        name: "削除"
      ),
      MenuButton(
        onPressed: () async {
          Navigator.of(context).pop();
          showRenamingDialog(context, folder.name);
        },
        isDestractive: false,  
        name: "名前を変更"
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
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
           Offset begin = const Offset(-1.0, 0.0);
          const Offset end = Offset.zero;
          final Animatable<Offset> tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeInOut));
          final Animation<Offset> offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  movePage(StatefulWidget page){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page)
    );
  }

  String folderTitle(String path){
      return path == 'video'?
      'フォルダ':
      path;
  }

  @override
  Widget build(BuildContext context) {
    buildInit();
    return Scaffold(
      appBar: AppBar(
        leadingWidth: _deviceWidth!/3,
        leading: 
        widget.path! == 'video'?
        const Spacer():
        InkWell(
          child:
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: _deviceWidth!/60), // Adjust the left margin as needed
                child: Icon(
                  Icons.arrow_back_ios,
                  size: _deviceWidth!/20,
                ),
              ),
              Text(folderTitle(widget.path!.split('/')[widget.path!.split('/').length-2]),
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: _deviceWidth!/25,
                )
              )
            ]
          ),
          onTap: () async {
            backPage(DownLoaderPage(
              path: await Folder(path: _currentPath).parentRelativePath, 
              mode: widget.mode, 
              target: widget.target,
              downloadList: [],
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
            icon: Icon(
              Icons.add
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //SizedBox(
            //  width: _deviceWidth!,
            //  height: _deviceHeight!/10,
            //),
            //if(widget.mode == Mode.play)
            //Column(
            //  mainAxisAlignment: MainAxisAlignment.center,
            //  children: <Widget>[
            //    TextField(
            //      decoration: const InputDecoration(
            //        hintText: 'Youtubeのid',
            //      ),
            //      onChanged: (text) {
            //        setState(() {
            //          youtubeId = text;
            //        });
            //      },
            //    ),
            //    Text(widget.path!.split('/').sublist(1).join('/')),
            //    Text('https://www.youtube.com/watch?v=$youtubeId'),
            //    TextButton(
            //      onPressed: (){
            //        setState(() {
            //         _downloaderController.download(youtubeId, FileType.video);
            //        });
            //      },
            //      child: const Text("動画ダウンロード")
            //    ),
            //  ]
            //),
            if(widget.mode == Mode.select)
            TextButton(
              onPressed: (){
                setState(() {
                 _downloaderController.download(youtubeId, FileType.video);
                  movePage(
                    DownLoaderPage(
                      path: "${widget.path!}", 
                      mode: Mode.download,
                      target: null,
                      downloadList: widget.downloadList,
                    )
                  );
                });
              },
              child: const Text("ここにダウンロード")
            ),
            if(widget.mode == Mode.transfer)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(widget.target!.videoPath),
              ]
            ),
            _videoPlayerController.value.isInitialized
            ? AspectRatio(
                aspectRatio: 16/9,
                child: Chewie(controller: _chewieController),
              )
            : const SizedBox.shrink(),
            Expanded(
              //height: _deviceHeight!/5*2,
              //width: _deviceHeight!,
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(0.0),
                children: <Widget>[
                  if(widget.mode == Mode.download)
                  for(var video in downloadingList)
                  DownLoaderCell(
                    cellHeight: _deviceHeight!/5,
                    cellWidth: _deviceWidth!,
                    //downloaderController: _downloaderController,
                    progress: video.progress,
                  ),
                  for(var folder in _folders)
                  Container(
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
                            Container(
                              width: _deviceWidth!*8/10,
                              child: Text(folder.name)
                            )
                          ),
                          InkWell(
                            child: 
                            Container(
                              height: _deviceWidth!/10,
                              width: _deviceWidth!/10,
                              child: const Icon(Icons.more_vert),
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
                    contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
                    title: Row (
                      children: [
                        Container(
                          margin: const EdgeInsets.all(0),
                          height: _deviceWidth!/32*9,
                          width: _deviceWidth!/2,
                          child: Image.file(File(data.thumbnailPath))
                        ),
                        Container(
                          margin: const EdgeInsets.all(0),
                          height: _deviceWidth!/32*9,
                          width: _deviceWidth!/3,
                          child: Text(data.videoPathForm.title)
                        ),
                        InkWell(
                          child: 
                          Container(
                            height: _deviceWidth!/32*9,
                            width: _deviceWidth!/6,
                            child: const Icon(Icons.more_vert),
                          ),
                          onTap: () => openMenu(data),
                        )
                      ],
                    ),
                    onTap: () {
                      _videoPlayerController.pause();
                      _videoPlayerController = VideoPlayerController.file(
                          File(data.videoPath),
                        )..initialize().then((_) {
                        setState(() {
                          _videoPlayerController = _videoPlayerController;
                          _chewieController = _getChewieController();
                        });
                      });
                    },
                  ),
                ],
              )
            )
          ],
        ),
      ),
      bottomNavigationBar: 
      widget.mode == Mode.transfer
      ?BottomMenuNavigationBar(
        initialIndex: 0,
        list: NavigationListConfig.downloaderMenuList,
        onTap: (i) async {
          switch(i){
          case 0:
            String path = await _directoryController.getFolderByVideo(widget.target!);
            backPage(
              DownLoaderPage(
                path: path, 
                mode: Mode.play, 
                target: null,
                downloadList: [],
              ));
          case 1:
            FileForm form = widget.target!.videoPathForm.fileForm;
            var videoTitle = widget.target!.videoPathForm.titleWithoutExtension;
            var thumbnailTitle = widget.target!.thumbnailPathForm.titleWithoutExtension;
            videoTitle = await getUniqueFileName(videoTitle, form.formType);
            thumbnailTitle = await getUniqueFileName(videoTitle, FileType.image);
            var pathDestination = "$_currentPath/$videoTitle${_videoForm.extension!}";
            var thumbnailDestination = "$_currentPath/$thumbnailTitle${_imageForm.extension!}";
            print(pathDestination);
            print(thumbnailDestination);
            await File(widget.target!.videoPath).rename(pathDestination);
            await File(widget.target!.thumbnailPath).rename(thumbnailDestination);
            VideoData newVideo = widget.target!;
            newVideo.videoPath = pathDestination;
            newVideo.thumbnailPath = thumbnailDestination;
            dbController.updateVideo(widget.target!.id!, newVideo);
            print('ファイルが移動されました。');
            movePage(
              DownLoaderPage(
              path: widget.path, 
              mode: Mode.play, 
              target: null,
              downloadList: [],
            ));
          }
        },
      ):
      HomeBottomNavigationBar(
        initialIndex: 3,
        onTap: (int index) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                initialIndex: index,
              )
            ),
          );
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
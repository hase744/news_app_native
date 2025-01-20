import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:chewie/chewie.dart';
import 'package:video_news/provider/downloader.dart';
import 'package:video_news/consts/navigation_list_config.dart';
import 'package:video_news/controllers/banner_adds_controller.dart';
import 'package:video_news/controllers/directory/directory_ontroller.dart';
import 'package:video_news/controllers/downloader/downloader_controller.dart';
import 'package:video_news/view_models/downloader_view_model.dart';
import 'package:video_news/views/downloader/cell.dart';
import 'package:video_news/views/bottom_menu_bar.dart';
import 'package:video_news/views/bottom_navigation_bar.dart';
import 'package:video_news/models/downloader/mode.dart';
import 'package:video_news/models/video.dart';
import 'package:video_news/models/downloader/video_data.dart';
import 'package:video_news/models/downloader/downloading_data.dart';

class DownLoaderPage extends ConsumerStatefulWidget {
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
  ConsumerState<DownLoaderPage> createState() => _DownLoaderPageState();
}

class _DownLoaderPageState extends ConsumerState<DownLoaderPage> {
  late DownLoaderViewModel _downLoaderViewModel = DownLoaderViewModel(ref);
  late DirectoryController _directoryController = DirectoryController(currentPath: _currentPath);

  late String _appDocumentDirPath;
  BannerAdsController _bannerAdsController = BannerAdsController(bannerAdCount: 1);
  String _currentPath = '';
  double? _deviceWidth;
  double? _deviceHeight;
  double _progress = 0.0;
  List<DownloaderController> downloaderControllers = [];
  List<DownloadingData> downloadingList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    final dir = await getApplicationDocumentsDirectory();
    _appDocumentDirPath = dir.path;
    _currentPath = '$_appDocumentDirPath/${widget.path}';
    _directoryController = DirectoryController(currentPath: _currentPath);
    _downLoaderViewModel = DownLoaderViewModel(ref);
    //final videoPlayerViewModel = ref.read(videoPlayerProvider);
    //videoPlayerViewModel.initialize('', 16/9);
    await _downLoaderViewModel.setRef(ref);
    await _downLoaderViewModel.setDefaultValue(widget.path, _currentPath, _progress, widget.downloadList);
    defineSize();
    if(widget.mode == Mode.download){
      await _downLoaderViewModel.downoloadAndTransit(context);
    }
    await _directoryController.updateDirectories();
    //print("サムネ");
    //for(var data in await dbController.all()){
    //  print(data['video_path']);
    //  print(data['thumbnail_path']);
    //  print(data['youtube_id']);
    //}
    _downLoaderViewModel.updateFolders();
    _downLoaderViewModel.updateVideoDatas();
  }

  defineSize() {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
  }

  String folderTitle(String path){
      return path == 'video'?
      'オフライン':
      path;
  }

  @override
  Widget build(BuildContext context) {
    defineSize();
    final _videoPlayerProvider = ref.watch(videoPlayerProvider);
    _videoPlayerProvider.initialize('', 16/9);
    return Scaffold(
      appBar: AppBar(
        leadingWidth: _deviceWidth!/3,
        leading: 
        widget.path! == '/video'?
        const SizedBox():
        InkWell(
          child:
          Container(
            color: Colors.white,
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
            _videoPlayerProvider.pause();
            _downLoaderViewModel.onBackPushed(context, widget.target, widget.mode);
          }
        ),
        title: Text(folderTitle(widget.path!.split('/').last)),
        actions: [
          IconButton(
            onPressed: () => _downLoaderViewModel.showEditingDialog(context, "aa"),
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
            if(widget.mode == Mode.play && _videoPlayerProvider.isInitialized)
            AspectRatio(
              aspectRatio: 16/9,
              child: Chewie(
                controller: _videoPlayerProvider.chewieController,
              ),
            ), 
            const SizedBox.shrink(),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(0.0),
                children: <Widget>[
                  if(widget.mode == Mode.download)
                  for(var video in _downLoaderViewModel.downloadingList)
                  DownLoaderCell(
                    cellWidth: _deviceWidth!,
                    video: video.form,
                    progress: video.progress,
                  ),
                  for(var folder in _downLoaderViewModel.folders)
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
                            onTap: () => _downLoaderViewModel.openFolderMenu(folder, context),
                          )
                        ],
                      ),
                      onTap: () {
                        _videoPlayerProvider.pause();
                        //_videoPlayerController.pause();
                        _downLoaderViewModel.movePage(
                          DownLoaderPage(
                            path: "${widget.path!}/${folder.name}", 
                            mode: widget.mode, target: widget.target,
                            downloadList: widget.downloadList
                          ),
                          context
                        );
                      },
                    ),
                  ),
                  if(widget.mode == Mode.play)
                  for(var data in _downLoaderViewModel.videoDatas)
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
                              File(_appDocumentDirPath+data.thumbnailPath),
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
                                      //data.createdAtString,
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
                                      onTap: () => _downLoaderViewModel.openMenu(context, data),
                                    )
                                  ],
                                )
                              )
                            ],
                          )
                        )
                      ],
                    ),
                    onTap: () => _videoPlayerProvider.play(data, '$_appDocumentDirPath/${data.videoPath}')
                  ),
                ],
              )
            ),
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: _bannerAdsController.bannerAds[0].size.width.toDouble(),
                height: _bannerAdsController.bannerAds[0].size.height.toDouble(),
                child: AdWidget(ad: _bannerAdsController.bannerAds[0]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: 
      widget.mode == Mode.copy?
      BottomMenuNavigationBar(
        initialIndex: 0,
        list: NavigationListConfig.downloaderCopyMenuList,
        onTap: (i) => _downLoaderViewModel.onMenuSelected(i, widget.target, widget.path!, context, widget.mode)
      ):
      widget.mode == Mode.transfer?
      BottomMenuNavigationBar(
        initialIndex: 0,
        list: NavigationListConfig.downloaderTransitMenuList,
        onTap: (i) => _downLoaderViewModel.onMenuSelected(i, widget.target, widget.path!, context, widget.mode)
      ):
      widget.mode == Mode.select?
      BottomMenuNavigationBar(
        initialIndex: 1,
        list: NavigationListConfig.selectaModeMenuList,
        onTap: (i) => _downLoaderViewModel.onNavigationPushed(context, i)
      ):
      HomeBottomNavigationBar(
        isReleased: true,
        initialIndex: 3,
        onTap: (int index) {
          _videoPlayerProvider.pause();
          //_videoPlayerController.pause();
        },
        isSelectMode: false
      ),

    );
  }
  @override
  void dispose() {
    super.dispose();
    //_videoPlayerController.dispose();
  }
}
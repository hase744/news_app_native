import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_news/helpers/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:video_news/provider/downloader.dart';
import 'package:video_news/consts/navigation_list_config.dart';
import 'package:video_news/controllers/video_db_controller.dart';
import 'package:video_news/controllers/directory/directory_ontroller.dart';
import 'package:video_news/controllers/downloader/downloader_controller.dart';
import 'package:video_news/views/downloader/text_editing_dialog.dart';
import 'package:video_news/views/downloader/video_downloader_page.dart';
import 'package:video_news/models/downloader/mode.dart';
import 'package:video_news/view_models/video_player_view_model.dart';
import 'package:video_news/models/video.dart';
import 'package:video_news/models/downloader/folder.dart';
import 'package:video_news/models/downloader/video_data.dart';
import 'package:video_news/models/downloader/file_type.dart';
import 'package:video_news/models/downloader/file_form.dart';
import 'package:video_news/models/menu_button.dart';
import 'package:video_news/models/downloader/downloading_data.dart';
import 'package:video_news/models/direction.dart';
import 'package:video_news/models/navigation_item.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';

class DownLoaderViewModel extends ChangeNotifier {
  late WidgetRef _ref;
  DownLoaderViewModel(this._ref);
  setRef(WidgetRef ref){
    _ref = ref;
  }

  final _videoForm = FileForm(type: FileType.video);
  final _imageForm = FileForm(type: FileType.image);

  DbController dbController = DbController();
  String dirPath = '';
  List<DownloaderController> downloaderControllers = [];
  String? get relativePath => _ref.watch(relativePathProvider);
  String get currentPath => _ref.watch(currentPathProvider);
  List<VideoForm> get downloadList => _ref.watch(downloadListProvider);
  List<DownloadingData> get downloadingList => _ref.watch(downloadingListProvider);
  List<VideoData> get videoDatas => _ref.watch(videoDatasProvider);
  List<Folder> get folders => _ref.watch(foldersProvider);
  late DirectoryController _directoryController = DirectoryController(currentPath: currentPath);
  VideoPlayerViewModel get videoPlayerViewModel {
    return _ref.read(videoPlayerProvider);
  }
  late final DownloaderController _downloaderController = DownloaderController(
    downloadPath: currentPath, 
    relativeDownloadPath: currentPath,
    onProcessed: (p)=>{}
  );

  //widget.path: appDirPath, _currentPath:currentPath, fileDirectory, _progress, widget.downloadList
  setDefaultValue(String? relativePath, String currentPath, List<VideoForm> downloadList) async {
    final dir = await getApplicationDocumentsDirectory();
    dirPath = dir.path;
    _ref.watch(relativePathProvider.notifier).state = relativePath;
    _ref.watch(currentPathProvider.notifier).state = currentPath;
    _ref.watch(downloadListProvider.notifier).state = downloadList;
    _ref.watch(videoDatasProvider.notifier).state = videoDatas;
    await _directoryController.updateDirectories();
  }
  
  updateFolders() async {
    _directoryController = DirectoryController(currentPath: currentPath);
    List<FileSystemEntity> _folders = await _directoryController.getDirectoriesOf(null);
    _folders.sort((a,b) => Folder(path: a.path).name.compareTo(Folder(path: b.path).name));//ソート
    _ref.watch(foldersProvider.notifier).state = [];
    for(var folder in _folders){
      folders.add(Folder(path: folder.path.toString()));
    }
    _ref.watch(foldersProvider.notifier).state = [...folders];
  }

  updateVideoDatas() async {
    List directories = await _directoryController.getDirectoriesOf(_videoForm.extension!);
    List dataPaths = directories.map((video) => video.path).toList(); 
    dataPaths = dataPaths.map((element) {
      return element.replaceFirst('$dirPath/', '');
    }).toList();
    _ref.watch(videoDatasProvider.notifier).state = [];
    for(var data in await dbController.getVideosByPaths(dataPaths)){
      VideoData videoData = VideoData.fromDb(data);
      await FFprobeKit.getMediaInformation('$dirPath${VideoData.fromDb(data).videoPath}').then((session) async {
        final information = session.getMediaInformation();
        final stream = information!.getStreams()[0];
        videoData.duration = await Duration(seconds: double.parse(information.getDuration()!).toInt());
        videoData.aspect = stream.getWidth()!/stream.getHeight()!;
      });
      videoDatas.add(
        videoData
      );
    _ref.watch(videoDatasProvider.notifier).state = [...videoDatas];
    }
    _ref.watch(videoDatasProvider.notifier).state = [...videoDatas];
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
            final newDirectory = Directory('$currentPath/$string/');
            await newDirectory.create(recursive: true);
            updateFolders();
            Navigator.of(context).pop();
          },
        );
      },
    );
   }

  downoloadAndTransit(BuildContext context) async{
    for(var i=0; i <downloadList.length; i++){
      downloadingList.add(
        DownloadingData(
          progress: 0.0,
          form: downloadList[i],
          controller: 
          DownloaderController(
            relativeDownloadPath: relativePath!,
            downloadPath: currentPath, 
            onProcessed: (p)=>{
              downloadingList[i].progress = p,
              _ref.watch(downloadingListProvider.notifier).state = [...downloadingList]
            }
          )
        )
      );
      _ref.watch(downloadingListProvider.notifier).state = [...downloadingList];
    }

    for(var elemnt in downloadingList){
      await elemnt.controller.download(
        FileType.video,
        elemnt.form
      );
    }
    movePage(
      DownLoaderPage(
        path: relativePath!, 
        mode: Mode.play, 
        target: null, 
        downloadList: const [],
      ),
      context
    );
  }

  openFolderMenu(Folder folder, BuildContext context){
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

  onBackPushed(BuildContext context, VideoData? target, Mode mode) async {
    backPage(
      DownLoaderPage(
        path: await Folder(path: currentPath).parentRelativePath, 
        mode: mode, 
        target: target,
        downloadList: const [],
      ),
      context
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
            var oldPath = '$currentPath/$name/';
            var newPath = '$currentPath/$string/';
            final oldDirectory = Directory(oldPath);
            final newDirectory = Directory(newPath);
            await oldDirectory.rename(newDirectory.path);
            for(var file in await dbController.getRecordByPartialPath(oldPath)){
              VideoData data = VideoData.fromDb(file);
              data.replaceFolder(oldPath, newPath);
              dbController.updateVideo(data.id!, data);
            }
            updateFolders();
            Navigator.of(context).pop(string);
          },
        );
      },
    );
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
          String _relativePath = folder.path.replaceAll('$relativePath/', '');
          await dbController.deleteByPartialPath("$_relativePath/");
          await Directory(folder.path).delete(recursive: true);
          updateFolders();
            Navigator.of(context).pop();
        },
        isDestractive: true,  
        name: "削除"
      ),
    ];
  }

  onNavigationPushed(BuildContext context, int i) async {
    switch(NavigationListConfig.selectaModeMenuList[i].name){
    case 'close':
      movePage(
        DownLoaderPage(
          path: relativePath, 
          mode: Mode.play,
          target: null,
          downloadList: const [],
        ),
        context
      );
    case 'download':
      movePage(
        DownLoaderPage(
          path: relativePath, 
          mode: Mode.download,
          target: null,
          downloadList: downloadList,
        ),
        context
      );
    }
  }

  List<MenuButton> videoButtons(BuildContext context, VideoData data){
    return [
      MenuButton(
        onPressed: () async {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => 
              ProviderScope(child: 
                DownLoaderPage(
                  path: '/video', 
                  mode: Mode.transfer, 
                  target: data, 
                  downloadList: const [],
                  )
                )
              )
          );
        },
        isDestractive: false,
        name: "移動"
      ),
      MenuButton(
        onPressed: () async {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => 
              ProviderScope(child: 
                DownLoaderPage(
                  path: '/video', 
                  mode: Mode.copy, 
                  target: data, 
                  downloadList: const [],
                  )
                )
              )
          );
        },
        isDestractive: false,
        name: "コピー"
      ),
      MenuButton(
        onPressed: () async {
          await dbController.delete(data.id!);
          await Directory('$dirPath${data.videoPath}').delete(recursive: true);
          updateVideoDatas();
          Navigator.of(context).pop();
        },
        isDestractive: true,
        name: "削除"
      ),
    ];
  }

  openMenu(BuildContext context, VideoData video){
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

  onMenuSelected(int i, VideoData? target, String path, BuildContext context, Mode mode) async {
    target = target!;
    List<NavigationItem>? menuList;
    switch(mode){
      case Mode.copy:
        menuList = NavigationListConfig.downloaderCopyMenuList;
      case Mode.transfer:
        menuList = NavigationListConfig.downloaderTransitMenuList;
      default:
        menuList = [];
    }
    FileForm form = target.videoPathForm.fileForm;
    var videoTitle = target.videoPathForm.titleWithoutExtension;
    var thumbnailTitle = target.thumbnailPathForm.titleWithoutExtension;
    videoTitle = await getUniqueFileName(videoTitle, form.formType);
    thumbnailTitle = await getUniqueFileName(videoTitle, FileType.image);
    var pathDestination = "$currentPath/$videoTitle${_videoForm.extension!}";
    var thumbnailDestination = "$currentPath/$thumbnailTitle${_imageForm.extension!}";
    switch(menuList[i].name){
    case 'close':
      backPage(
        DownLoaderPage(
          path: path, 
          mode: Mode.play, 
          target: null,
          downloadList: const [],
        ),
        context
      );
    case 'transit':
      await File('$dirPath${target.videoPath}').rename(pathDestination);
      await File('$dirPath${target.thumbnailPath}').rename(thumbnailDestination);
      VideoData newVideo = target;
      newVideo.videoPath = pathDestination.replaceFirst('$dirPath/', '');
      newVideo.thumbnailPath = thumbnailDestination.replaceFirst('$dirPath/', '');
      dbController.updateVideo(target.id!, newVideo);
      movePage(
        DownLoaderPage(
          path: path, 
          mode: Mode.play, 
          target: null,
          downloadList: const [],
        ),
        context
      );
    case 'copy':
      await File('$dirPath${target.videoPath}').copy(pathDestination);
      await File('$dirPath${target.thumbnailPath}').copy(thumbnailDestination);
      VideoData newVideo = target;
      newVideo.videoPath = pathDestination.replaceFirst('$dirPath/', '');
      newVideo.thumbnailPath = thumbnailDestination.replaceFirst('$dirPath/', '');
      dbController.create(newVideo);
      movePage(
        DownLoaderPage(
          path: path, 
          mode: Mode.play, 
          target: null,
          downloadList: const [],
        ),
        context
      );
    }
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

  backPage(ConsumerStatefulWidget page, BuildContext context){
    PageTransition.move(ProviderScope(child: page), context, Direction.left);
  }

  movePage(ConsumerStatefulWidget page, BuildContext context){
    PageTransition.move(ProviderScope(child: page), context, Direction.right);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
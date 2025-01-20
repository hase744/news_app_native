import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_news/models/video.dart';
import 'package:video_news/models/channel.dart';
import 'package:video_news/models/downloader/mode.dart';
import 'package:video_news/controllers/channel_controller.dart';
import 'package:video_news/models/downloader/downloading_data.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:video_news/models/downloader/folder.dart';
import 'package:video_news/view_models/video_player_view_model.dart';
import 'package:video_news/models/downloader/video_data.dart';
StateProvider<String?> relativePathProvider = StateProvider<String?>(
  (ref) {
    return null;
  }
);
StateProvider<String> currentPathProvider = StateProvider<String>(
  (ref) {
    return '';
  }
);
StateProvider<String> dirPathProvider = StateProvider<String>(
  (ref) {
    return '';
  }
);
StateProvider<String> pathProvider = StateProvider<String>(
  (ref) {
    return '';
  }
);
StateProvider<String> fileDirectoryProvider = StateProvider<String>(
  (ref) {
    return '';
  }
);
StateProvider<double> progressProvider = StateProvider<double>(
  (ref) {
    return 0.0;
  }
);
StateProvider<Mode> modeProvider = StateProvider<Mode>(
  (ref) {
    return Mode.play;
  }
);
StateProvider<List<VideoForm>> downloadListProvider = StateProvider<List<VideoForm>>(
  (ref) {
    return [];
  }
);
StateProvider<List<DownloadingData>> downloadingListProvider = StateProvider<List<DownloadingData>>(
  (ref) {
    return [];
  }
);
StateProvider<List<Folder>> foldersProvider = StateProvider<List<Folder>>(
  (ref) {
    return [];
  }
);
StateProvider<List<VideoData>> videoDatasProvider = StateProvider<List<VideoData>>(
  (ref) {
    return [];
  }
);
ChangeNotifierProvider<VideoPlayerViewModel> videoPlayerProvider = ChangeNotifierProvider((ref) => VideoPlayerViewModel());
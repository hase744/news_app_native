import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:video_news/models/downloader/video_data.dart';

class VideoPlayerViewModel extends ChangeNotifier {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  bool isInitialized = false;
  ChewieController get chewieController => _chewieController;

  Future<void> initialize(String filePath, double aspectRatio) async {
    _videoPlayerController = VideoPlayerController.file(File(filePath));
    await _videoPlayerController.initialize();
    _chewieController = _getChewieController(aspectRatio);
    isInitialized = _videoPlayerController.value.isInitialized;
    notifyListeners(); // 初期化完了を通知
  }

  // 再生
  void play(VideoData data, String path) {
    _videoPlayerController = VideoPlayerController.file(
        File(path),
    )..initialize().then((_) {
      _chewieController = _getChewieController(data.aspect!);
      _videoPlayerController.play();
      isInitialized = _videoPlayerController.value.isInitialized;
      notifyListeners();
    });
  }

  void pause() {
    _videoPlayerController.pause();
    notifyListeners();
  }

  ChewieController _getChewieController(double aspect) {
    return ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: aspect, // アスペクト比
      autoPlay: false, // 自動再生
      looping: true, // 繰り返し再生
      showControls: true, // コントロールバーの表示
      autoInitialize: true, // 自動初期化
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
    );
  }

  @override
  void dispose() {
    _chewieController.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }
}

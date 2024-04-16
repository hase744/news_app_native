// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:video_news/controllers/video_controller.dart';
import 'package:video_news/controllers/version_controller.dart';
import 'package:video_news/views/home_page.dart';
import 'package:video_news/models/downloader/mode.dart';
import 'package:video_news/views/categories/category_default_page.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:video_news/views/downloader/video_downloader_page.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});
  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  double? _deviceWidth;
  String _authStatus = 'Unknown';
  String uuid = '';
  VersionController _versionController = VersionController();
  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _deviceWidth = MediaQuery.of(context).size.width;
    });
  }

  init() async {
    await _versionController.initialize();
    await initPlugin(context);
    fetchData();
  }

  Future<void> initPlugin(context) async {
    TrackingStatus status = await AppTrackingTransparency.trackingAuthorizationStatus;
    setState(() => _authStatus = '$status');
    if (status == TrackingStatus.notDetermined) {
      await showCustomTrackingDialog(context);
      await Future.delayed(const Duration(milliseconds: 200));
      final TrackingStatus status =
          await AppTrackingTransparency.requestTrackingAuthorization();
      setState(() => _authStatus = '$status');
    }

    uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    setState(() {
      uuid = uuid;
    });
  }

  Future<void> showCustomTrackingDialog(BuildContext context) async => await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('ご利用者様へ'),
      content: const Text(
        '端末のトラッキングを許可することで、あなたのお気に入りや履歴をクラウド上に保存できるようになります。\n\n'
        'また、あなたに最適化された広告を表示することができるようになります。\n\n'
        'ご協力をお願い申し上げます。',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('次へ'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    double titleSize = _deviceWidth! / 1.5 / 'NEWSNIPPET'.length;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'NEWSNIPPET',
              style: TextStyle(fontSize: titleSize),
            ),
            SizedBox(
              height: _deviceWidth! / 20,
              width: _deviceWidth!,
            ),
            SizedBox(
              width: _deviceWidth! / 2,
              child: const LinearProgressIndicator(
                color: Colors.blue,
                backgroundColor: Colors.grey,
              ),
            )
          ],
        ),
      )
    );
  }

  displayDialog(context, dynamic e) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "ロードに失敗しました。\nリロードしますか？",
            style: TextStyle(
              fontSize: 20,
              color: Colors.black87
            ),
            ),
          content: Text(
            e.toString(),
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black45
            ),
            ),
          actions: [
            if(_versionController.isReleased)
            Builder(builder: (context) {
              return TextButton(
                child: const Text("オフラインに移動"),
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DownLoaderPage(
                      path: '/video',
                      target: null,
                      downloadList: [],
                      mode: Mode.play,
                    )),
                  );
                }
              );
            }),
            Builder(builder: (context) {
              return TextButton(
                child: const Text("はい"),
                onPressed: (){
                  fetchData();
                  //MaterialPageRoute(builder: (context) => PreFirstPage());
                  Navigator.pop(context);
                }
              );
            }),
          ],
        );
      },
    );
  }

  Future<void> fetchData() async {
    VideoController videoController = VideoController();
    VersionController versionController = VersionController();

    try {
      if(!(await videoController.accessVideos())){throw Exception('Failed to load data');};
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      final prefs = await SharedPreferences.getInstance();
      String defaultYoutubeId = prefs.getString('default_youtube_id') ?? '';
      await prefs.setString('default_youtube_id', defaultYoutubeId);
      String? categoryOrder = await prefs.getString('category_order');
      print("順番");
      print(categoryOrder);
      Navigator.pushReplacement(
        context,
        [null, '[]'].contains(categoryOrder)
          ? MaterialPageRoute(builder: (context) => CategoryDefault())
          : MaterialPageRoute(builder: (context) => const HomePage(initialIndex: 0)),
      );

    } catch (e) {
      displayDialog(context, e);
      throw Exception('Failed to load data');
    }
    versionController.update();
  }
}

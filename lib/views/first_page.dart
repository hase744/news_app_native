import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_news/views/home_page.dart';
import 'package:flutter/services.dart';
import 'package:video_news/controllers/video_controller.dart';
import 'package:video_news/views/category_select.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});
  @override
  State<FirstPage> createState() => _FirstPageState();
}


class _FirstPageState extends State<FirstPage> {
  double? _deviceWidth;
  String _authStatus = 'Unknown';
  String uuid = '';
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    init();
  }

  init() async {
    setState(() {
    _deviceWidth = MediaQuery.of(context).size.width;
    });
    await initPlugin(context);
    fetchData();
  }

  Future<void> initPlugin(context) async {
    TrackingStatus status = await AppTrackingTransparency.trackingAuthorizationStatus;
    setState(() => _authStatus = '$status');
    if (status == TrackingStatus.notDetermined) {
      await showCustomTrackingDialog(context);
      await Future.delayed(const Duration(milliseconds: 200));
      final TrackingStatus status = await AppTrackingTransparency.requestTrackingAuthorization();
      setState(() => _authStatus = '$status');
    }

    uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    setState(() {
      uuid = uuid;
    });
  }

  Future<void> showCustomTrackingDialog(BuildContext context) async =>
      await showDialog<void>(
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
    return Scaffold(
      body: 
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'NEWSNIPPET',
              style: TextStyle(
                fontSize: _deviceWidth! /'NEWSNIPPET'.length/2
              ),
            ),
          ],
        ),
      )
    );
  }

  Future<void> fetchData() async {
    VideoController videoController = VideoController();

    if (await videoController.accessVideos()) {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      final prefs = await SharedPreferences.getInstance();
      String defaultYoutubeId = prefs.getString('default_youtube_id') ?? '4b6DuHGcltI';
      await prefs.setString('default_youtube_id', defaultYoutubeId);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        prefs.getString('categoryOrder') == null 
          ? MaterialPageRoute(builder: (context) =>CategorySelect()) 
          : MaterialPageRoute(builder: (context) =>const HomePage(initialIndex: 0,)),
      );
    } else {
      throw Exception('Failed to load data');
    }
  }
}

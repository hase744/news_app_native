import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_news/views/home_page.dart';
import 'package:flutter/services.dart';
import 'package:video_news/controllers/access_controller.dart';
import 'package:video_news/controllers/video_controller.dart';
import 'package:video_news/controllers/category_controller.dart';
import 'package:video_news/views/category_select.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key, required this.title});
  final String title;

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  double? _deviceWidth, _deviceHeight;
  @override
  void initState() {
    super.initState();
    fetchData();
    init();
  }

  init() async {
    setState(() {
    _deviceWidth = MediaQuery.of(context).size.width;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: 
      Container(
        //color: Colors.red,
        child: 
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'NEWSNIPPET',
                style: TextStyle(
                  fontSize: 15
                ),
              ),
            ],
          ),
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
      //await prefs.remove('categoryOrder');
      Navigator.pushReplacement(
        context,
        prefs.getString('categoryOrder') == null 
          ? MaterialPageRoute(builder: (context) =>CategorySelect()) 
          : MaterialPageRoute(builder: (context) =>HomePage(initialIndex: 0,)),
      );
    } else {
      throw Exception('Failed to load data');
    }
  }
}

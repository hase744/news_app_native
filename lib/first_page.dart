import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'package:flutter/services.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key, required this.title});

  final String title;

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  void initState() {
    super.initState();
    saveLayout();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("${MediaQuery.of(context).orientation}"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Video News',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveLayout() async {
    double _deviceWidth = MediaQuery.of(context).size.width;
    double _deviceHeight = MediaQuery.of(context).size.height;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('device_width', _deviceWidth);
    await prefs.setDouble('device_height', _deviceHeight);
  }

  Future<void> fetchData() async {
    //final url = 'http://10.0.2.2:3000/categories/index.json';
    final url = 'http://18.178.58.191/categories/index.json';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      final data = response.body;
      final prefs = await SharedPreferences.getInstance();
      String defaultYoutubeId = prefs.getString('default_youtube_id') ?? '4b6DuHGcltI';
          await prefs.setString('default_youtube_id', defaultYoutubeId);
          await prefs.setString('presses', data);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>HomePage()),
          );
    } else {
      throw Exception('Failed to load data');
    }
  }
}

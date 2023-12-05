import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

class HtmlPage extends StatefulWidget {
  const HtmlPage({Key? key, required this.url, required this.title}) : super(key: key);
  final String url;
  final String title;
  @override
  _HtmlPageState createState() => _HtmlPageState();
}

class _HtmlPageState extends State<HtmlPage> {
  Future<String> _fetchPrivacyPolicy() async {
    final response = await http.get(Uri.parse(widget.url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load privacy policy');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: _fetchPrivacyPolicy(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
                        color: Colors.blue,
                      ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return SingleChildScrollView(
              child: Html(data: snapshot.data),
            );
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebWindow extends StatefulWidget {
  const WebWindow({super.key, required this.youtubeId});

  final String youtubeId;
  @override
  State<WebWindow> createState() => _WebWindowState();
}

class _WebWindowState extends State<WebWindow> {
  /// WebViewControllerオブジェクト
  late final WebViewController controller;

  /// 初期状態を設定
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(
      Uri.parse("https://www.youtube.com/watch?v=${widget.youtubeId}"),
    );
  }

  /// アプリのUIを構築
  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
        controller: controller,
      );
  }
}


import 'package:flutter/material.dart';
import 'category_adder_page.dart';
import 'category_order_page.dart';
import 'package:settings_ui/settings_ui.dart';
import 'home_page.dart';
import '../helpers/page_transition.dart';
import 'package:video_news/views/bottom_navigation_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_news/views/pdf_page.dart';
import 'package:video_news/consts/config.dart';
import 'dart:io';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final categorySetting = CategoryOrder();
  double? _deviceHeight;
  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
  final PageTransition _pageTransition = PageTransition();
  String remotePDFpath = "";
  String domain = Config.domain;

  @override
  void initState() {
    super.initState();
    //init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access the context here to get the device height.
    _deviceHeight = MediaQuery.of(context).size.height;
  }

  void movePage(StatefulWidget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          // 表示する画面のWidget
          return page;
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const Offset begin = Offset(1.0, 0.0); // 右から左
          // final Offset begin = Offset(-1.0, 0.0); // 左から右
          const Offset end = Offset.zero;
          final Animatable<Offset> tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeInOut));
          final Animation<Offset> offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  launchWebView(String id) {
    final Uri toLaunch = Uri(
      scheme: 'https',
      host: 'drive.google.com',
      path: "file/d/$id",
    );
    launchUrl(toLaunch, mode: LaunchMode.inAppWebView);
  }

  SettingsTile settingTile(String title, Icon? icon, StatefulWidget widget) {
    return 
    icon == null ?
    SettingsTile.navigation(
      title: Platform.isIOS
        ? Text(title)
        : Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey,
            ),
          ),
        ),
        child: Text(title),
      ),
      onPressed: (context) => _pageTransition.movePage(
        widget, context, true
      )
    )
    :SettingsTile.navigation(
      leading: icon,
      title: Platform.isIOS
        ? Text(title)
        : Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey,
            ),
          ),
        ),
        child: Text(title),
      ),
      onPressed: (context) => _pageTransition.movePage(
        widget, context, true
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Opacity(opacity: 0, child: Icon(Icons.arrow_back)),
        title: const Text('設定'),
      ),
      body: 
      Container(
        color: Colors.white,
        child: 
        SettingsList(
          platform: Platform.isIOS ? DevicePlatform.iOS : DevicePlatform.android,
          sections: [
            SettingsSection(
              title: const Text('カテゴリー'),
              tiles: <SettingsTile>[
                settingTile(
                  'カテゴリー並び替え', 
                  const Icon(Icons.format_list_numbered), 
                  const CategoryOrder()
                ),
                settingTile(
                  'カテゴリー追加', 
                  const Icon(Icons.format_list_bulleted_add), 
                  const AddCategoyPage(title: "設定")
                ),
              ],
            ),
            SettingsSection(
              title: const Text('このアプリについて'),
              tiles: <SettingsTile>[
                settingTile(
                  'プライバシーポリシー',
                  null ,
                  PdfPage(url: '$domain/uploads/pdf_file/file/1/privacy.pdf',
                  title: 'プライバシーポリシー')
                ),
                settingTile('ニュースメディアの連絡先情報',
                  null,
                  PdfPage(url: '$domain/uploads/pdf_file/file/1/privacy.pdf',
                  title: '連絡先情報')
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNavigationBar(
        initialIndex: 3,
        onTap: (int index) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                initialIndex: index,
              )
            ),
          );
        },
        isSelectMode: false),
    );
  }
}

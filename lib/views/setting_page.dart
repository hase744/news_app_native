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

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage>  {
  final categorySetting = CategoryOrder();
  double? _deviceHeight;
  final ButtonStyle style = ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
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

  void movePage(StatefulWidget page){
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

  launchWebView (String id){
    final Uri toLaunch = Uri(
      scheme: 'https',
      host: 'drive.google.com',
      path: "file/d/$id",
    );
    launchUrl(toLaunch, mode: LaunchMode.inAppWebView);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Opacity(
          opacity: 0,
          child: Icon(Icons.arrow_back)
        ),
        title: const Text('設定'),
      ),
      body:SettingsList(
        platform: DevicePlatform.iOS,
        sections: [
          SettingsSection(
            title: const Text('カテゴリー'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.format_list_numbered),
                title: const Text('カテゴリー並び変え'),
                onPressed: (context) => _pageTransition.movePage(const CategoryOrder(), context, true)
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.format_list_bulleted_add),
                title: const Text('カテゴリー追加'),
                onPressed: (context) => _pageTransition.movePage(const AddCategoyPage(title:"設定"), context, true)
              ),
            ],
          ),
          SettingsSection(
            title: const Text('このアプリについて'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                title: const Text('プライバシーポリシー'),
                onPressed:(context) => _pageTransition.movePage(
                  PdfPage(
                    url: '$domain/uploads/pdf_file/file/1/privacy.pdf',
                    title: 'プライバシーポリシー'
                  ),
                  context, 
                  true
                  ),//launchWebView('1PgEtfqTtfMca055Poaa5yO4B_mwcxalP')
              ),
              SettingsTile.navigation(
                title: const Text('ニュースメディアの連絡先情報'),
                onPressed: (context) => _pageTransition.movePage(
                  PdfPage(
                    url: '$domain/uploads/pdf_file/file/1/privacy.pdf',
                    title: 'プライバシーポリシー'
                  ),
                  context, 
                  true
                  ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: HomeBottomNavigationBar(
        initialIndex: 3, 
        onTap: (int index){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>HomePage(initialIndex: index,)),
          );
        },
        isSelectMode: false
      ),
    );
  }
}
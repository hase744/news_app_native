import 'package:flutter/material.dart';
import 'add_category.dart';
import 'category_setting.dart';
import 'package:settings_ui/settings_ui.dart';
import 'home_page.dart';
import 'page_transition.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage>  {
  var category_setting = CategorySetting();
  double? _deviceHeight;
  final ButtonStyle style = ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
  PageTransition _pageTransition = PageTransition();
  
  @override
  void initState() {
    super.initState();
    print("イニシャライズ");
    //init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access the context here to get the device height.
    _deviceHeight = MediaQuery.of(context).size.height;
    print("高さ");
    print(_deviceHeight!);
  }

  Future<void> _launchSetting() async {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: category_setting,
          height: _deviceHeight!*0.8,
        );
        }
      );
  }

  void movePage(StatefulWidget page){
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          // 表示する画面のWidget
          return page;
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final Offset begin = Offset(1.0, 0.0); // 右から左
          // final Offset begin = Offset(-1.0, 0.0); // 左から右
          final Offset end = Offset.zero;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Add your back button functionality here
            _pageTransition.movePage(HomePage(), context, false);
          },
        ),
        title: Text('設定'),
      ),
      body:SettingsList(
      platform: DevicePlatform.iOS,
      sections: [
        SettingsSection(
          title: const Text('カテゴリー設定'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.format_list_numbered),
              title: const Text('カテゴリー並び変え'),
              onPressed: (context) => _pageTransition.movePage(CategorySetting(), context, true)
            ),
            SettingsTile.navigation(
              leading: const Icon(Icons.format_list_bulleted_add),
              title: const Text('カテゴリー追加'),
              onPressed: (context) => _pageTransition.movePage(AddCategoyPage(title:"設定"), context, true)
            ),
          ],
        ),
      ],
    )
    );
  }
}
import 'package:flutter/material.dart';
import 'package:video_news/models/navigation_item.dart';
import 'package:video_news/models/downloader/mode.dart';
import 'package:video_news/views/home_page.dart';
import 'package:video_news/views/setting_page.dart';
import 'package:video_news/views/downloader/video_downloader_page.dart';
import 'package:video_news/controllers/version_controller.dart';
class NavigationListConfig{
  static List<NavigationItem> homeMenuList = [
    NavigationItem(
      name:"close", 
      item: const BottomNavigationBarItem(icon: Icon(Icons.close), label: '戻る'),
      page: null
      ),
    NavigationItem(
      name:"favorite", 
      item: const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'お気に入りに追加'),
      page: null
      ),
    NavigationItem(
      name:"download", 
      item: const BottomNavigationBarItem(icon: Icon(Icons.download), label: 'ダウンロード'),
      page: null
      )
  ];


  static List<NavigationItem> fakeHomeMenuList = [
    NavigationItem(
      name:"close", 
      item: const BottomNavigationBarItem(icon: Icon(Icons.close), label: '戻る'),
      page: null
      ),
    NavigationItem(
      name:"favorite", 
      item: const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'お気に入りに追加'),
      page: null
      ),
  ];

  static List<NavigationItem> favoriteMenuList = [
    NavigationItem(
      name:"close", 
      item: const BottomNavigationBarItem(icon: Icon(Icons.close), label: '戻る'),
      page: null
      ),
    NavigationItem(
      name:"delete", 
      item: const BottomNavigationBarItem(icon: Icon(Icons.delete), label: 'お気に入りから削除'),
      page: null
      )
  ];

  static List<NavigationItem> historyMenuList = [
    NavigationItem(
      name:"close", 
      item: const BottomNavigationBarItem(icon: Icon(Icons.close), label: '戻る'),
      page: null
      ),
    NavigationItem(
      name:"delete", 
      item: const BottomNavigationBarItem(icon: Icon(Icons.delete), label: '履歴から削除'),
      page: null
      )
  ];

  static List<NavigationItem> pageList = [
    NavigationItem(
      name: 'home',
      item: const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
      page: HomePage(initialIndex: 0)
    ),
    NavigationItem(
      name: 'favorite',
      item: const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'お気に入り'),
      page: HomePage(initialIndex: 1)
    ),
    NavigationItem(
      name: 'history',
      item: const BottomNavigationBarItem(icon: Icon(Icons.history), label: '履歴'),
      page: HomePage(initialIndex: 2)
    ),
    NavigationItem(
      name: 'downloader',
      item: const BottomNavigationBarItem(icon: Icon(Icons.download), label: 'オフライン'),
      page: const DownLoaderPage(
          path: '/video',
          target: null,
          downloadList: [],
          mode: Mode.play,
        )
    ),
    NavigationItem(
      name: 'setting',
      item: const BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
      page: SettingPage()
    ),
  ];

  static List<NavigationItem> fakePageList = [
    NavigationItem(
      name: 'home',
      item: const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
      page: HomePage(initialIndex: 0)
    ),
    NavigationItem(
      name: 'favorite',
      item: const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'お気に入り'),
      page: HomePage(initialIndex: 1)
    ),
    NavigationItem(
      name: 'history',
      item: const BottomNavigationBarItem(icon: Icon(Icons.history), label: '履歴'),
      page: HomePage(initialIndex: 2)
    ),
    NavigationItem(
      name: 'setting',
      item: const BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
      page: SettingPage()
    ),
  ];

  static List<NavigationItem> selectaModeMenuList = [
    NavigationItem(
      name:"close", 
      item: const BottomNavigationBarItem(icon: Icon(Icons.close), label: '閉じる'),
      page: null
      ),
    NavigationItem(
      name:"download", 
      item: const BottomNavigationBarItem(icon: Icon(Icons.download), label: 'ここにダウンロード'),
      page: null
      )
  ];

  static List<NavigationItem> downloaderMenuList = [
    NavigationItem(
      name:"close", 
      item: const BottomNavigationBarItem(icon: Icon(Icons.close), label: '閉じる'),
      page: null
      ),
    NavigationItem(
      name:"transit", 
      item: const BottomNavigationBarItem(icon: Icon(Icons.drive_file_move), label: 'ここに移動'),
      page: null
      )
  ];
}
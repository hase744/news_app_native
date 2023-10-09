import 'package:flutter/material.dart';
import 'package:video_news/models/navigation_item.dart';
class NavigationListConfig{
  static List<NavigationItem> homeMenuList = [
    NavigationItem(
      name:"close", 
      item: const BottomNavigationBarItem(icon: Icon(Icons.close), label: '戻る')
      ),
    NavigationItem(
      name:"favorite", 
      item: const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'お気に入りに追加')
      )
  ];

  static List<NavigationItem> favoriteMenuList = [
    NavigationItem(
      name:"close", 
      item: const BottomNavigationBarItem(icon: Icon(Icons.close), label: '戻る')
      ),
    NavigationItem(
      name:"delete", 
      item: const BottomNavigationBarItem(icon: Icon(Icons.delete), label: 'お気に入りから削除')
      )
  ];

  static List<NavigationItem> pageList = [
    NavigationItem(
      name: 'home',
      item: const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
    ),
    NavigationItem(
      name: 'favorite',
      item: const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'お気に入り'),
    ),
    NavigationItem(
      name: 'history',
      item: const BottomNavigationBarItem(icon: Icon(Icons.history), label: '履歴'),
    ),
    NavigationItem(
      name: 'setting',
      item: const BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
    ),
  ];
}
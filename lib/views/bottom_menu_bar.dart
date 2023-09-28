import 'package:flutter/material.dart';
import 'package:video_news/home_page.dart';
import 'package:video_news/models/navigation_item.dart';
import 'package:video_news/consts/navigation_list_config.dart';

class BottomMenuNavigationBar extends StatelessWidget {
  final int initialIndex;
  final Function(int) onTap;
  final GlobalKey _bottomNavigationKey = GlobalKey();
  List<NavigationItem> list = NavigationListConfig.menuList;

  BottomMenuNavigationBar({
    required this.initialIndex,
    required this.onTap,
  });

  double getBottomNavigationBarHeight() {
    final RenderBox renderBox = _bottomNavigationKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.size.height;
  }

  String getButtonName(index){
      return list[index].name;
   }

  @override
  Widget build(BuildContext context) {
    return 
    BottomNavigationBar(
      selectedItemColor: Colors.grey,
      currentIndex: initialIndex,
      onTap: onTap,
      items:list.map((navItem) => navItem.item).toList(),
      type: BottomNavigationBarType.fixed,
      key: _bottomNavigationKey,
    );
  }
}

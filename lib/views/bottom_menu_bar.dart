import 'package:flutter/material.dart';
import 'package:video_news/views/home_page.dart';
import 'package:video_news/models/navigation_item.dart';
import 'package:video_news/consts/navigation_list_config.dart';

class BottomMenuNavigationBar extends StatelessWidget {
  final int initialIndex;
  late final Function(int) onTap;
  final GlobalKey _bottomNavigationKey = GlobalKey();
  List<NavigationItem> list;

  BottomMenuNavigationBar({
    required this.initialIndex,
    required this.onTap,
    required this.list
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
    List<BottomNavigationBarItem> items = list.map((navItem) => navItem.item).toList();
    return 
    BottomNavigationBar(
      selectedItemColor: Colors.grey,
      currentIndex: initialIndex,
      onTap: onTap,
      items:items,
      type: BottomNavigationBarType.fixed,
      key: _bottomNavigationKey,
    );
  }
}

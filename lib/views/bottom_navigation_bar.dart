import 'package:flutter/material.dart';
import 'package:video_news/helpers/page_transition.dart';
import 'package:video_news/models/navigation_item.dart';
import 'package:video_news/models/direction.dart';
import 'package:video_news/consts/navigation_list_config.dart';

class HomeBottomNavigationBar extends StatelessWidget {
  final int initialIndex;
  final Function(int) onTap;
  final GlobalKey _bottomNavigationKey = GlobalKey();
  bool isSelectMode;
  List<NavigationItem> navigationList = NavigationListConfig.pageList;

  HomeBottomNavigationBar({
    required this.initialIndex,
    required this.onTap,
    required this.isSelectMode
  });

  String getButtonName(index){
      return navigationList[index].name;
   }

  double getBottomNavigationBarHeight() {
    final RenderBox renderBox = _bottomNavigationKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.size.height;
  }

  @override
  Widget build(BuildContext context) {
    return 
    BottomNavigationBar(
      selectedItemColor: Colors.blue,
      currentIndex: initialIndex,
      onTap: (i){
        if(
          navigationList[i].page != null){
          PageTransition.move(
            navigationList[i].page,
            context,
            initialIndex < i ? Direction.right :Direction.left
          );
        }else{
          onTap(i);
        }
      },
      items: navigationList.map((navItem) => navItem.item).toList(),
      type: BottomNavigationBarType.fixed,
      key: _bottomNavigationKey,
    );
  }
}

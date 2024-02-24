import 'package:flutter/material.dart';
import 'package:video_news/helpers/page_transition.dart';
import 'package:video_news/models/navigation_item.dart';
import 'package:video_news/models/direction.dart';
import 'package:video_news/consts/navigation_list_config.dart';
import 'package:video_news/controllers/version_controller.dart';


class HomeBottomNavigationBar extends StatelessWidget {
  final int initialIndex;
  final Function(int) onTap;
  final GlobalKey _bottomNavigationKey = GlobalKey();
  bool isSelectMode;
  bool isReleased;
  VersionController _versionController = VersionController();
  late List<NavigationItem> navigationList = isReleased ? NavigationListConfig.pageList: NavigationListConfig.fakePageList;
  HomeBottomNavigationBar({
    required this.initialIndex,
    required this.onTap,
    required this.isSelectMode,
    required this.isReleased
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
        onTap(i);
        if(navigationList[i].page != null){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => navigationList[i].page
            ),
          );
        }
      },
      items: navigationList.map((navItem) => navItem.item).toList(),
      type: BottomNavigationBarType.fixed,
      key: _bottomNavigationKey,
    );
  }
}

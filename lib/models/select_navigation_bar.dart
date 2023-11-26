import 'package:flutter/material.dart';

final class SelectBottomNavigationBar extends StatelessWidget {
  final int initialIndex;
  final Function(int) onTap;
  final GlobalKey _bottomNavigationKey = GlobalKey();
  final bool isSelectMode;
  SelectBottomNavigationBar({
    super.key,
    required this.initialIndex,
    required this.onTap,
    required this.isSelectMode
  });

  final List<Map<dynamic, dynamic>> pageMap = [
    {
      "name": 'home',
      "item": const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
    },
    {
      "name": 'favorite',
      "item": const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'お気に入り'),
    },
    {
      "name": 'history',
      "item": const BottomNavigationBarItem(icon: Icon(Icons.history), label: '履歴'),
    },
    {
      "name": 'setting',
      "item": const BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
    },
  ];

  final List<Map<dynamic, dynamic>> selectMap = [
    {
      "name": 'close',
      "item": const BottomNavigationBarItem(icon: Icon(Icons.close), label: '戻る'),
    },
    {
      "name": 'favorite',
      "item": const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'お気に入りに追加'),
    },
  ];

  String getButtonName(index){
      return pageMap[index]['name'];
   }

  double getBottomNavigationBarHeight() {
    final RenderBox renderBox = _bottomNavigationKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.size.height;
  }

  @override
  Widget build(BuildContext context) {
    return 
    BottomNavigationBar(
      selectedItemColor: isSelectMode ? Colors.red :Colors.blue,
      currentIndex: initialIndex,
      onTap: onTap,
      items: isSelectMode ? 
       selectMap.map<BottomNavigationBarItem>((map) => map["item"]).toList() 
       :  pageMap.map<BottomNavigationBarItem>((map) => map["item"]).toList(),
      type: BottomNavigationBarType.fixed,
      key: _bottomNavigationKey,
    );
  }
}

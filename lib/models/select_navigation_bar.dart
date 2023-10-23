import 'package:flutter/material.dart';

class SelectBottomNavigationBar extends StatelessWidget {
  final int initialIndex;
  final Function(int) onTap;
  final GlobalKey _bottomNavigationKey = GlobalKey();
  bool isSelectMode;
  List<Map<dynamic, dynamic>> pageMap = [
    {
      "name": 'home',
      "item": BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
    },
    {
      "name": 'favorite',
      "item": BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'お気に入り'),
    },
    {
      "name": 'history',
      "item": BottomNavigationBarItem(icon: Icon(Icons.history), label: '履歴'),
    },
    {
      "name": 'setting',
      "item": BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
    },
  ];

  List<Map<dynamic, dynamic>> selectMap = [
    {
      "name": 'close',
      "item": BottomNavigationBarItem(icon: Icon(Icons.close), label: '戻る'),
    },
    {
      "name": 'favorite',
      "item": BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'お気に入りに追加'),
    },
  ];

  SelectBottomNavigationBar({
    required this.initialIndex,
    required this.onTap,
    required this.isSelectMode
  });

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

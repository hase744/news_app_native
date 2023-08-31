import 'package:flutter/material.dart';
import 'package:video_news/home_page.dart';

class HomeBottomNavigationBar extends StatefulWidget {
  final int initialIndex;
  double height;

  HomeBottomNavigationBar({Key? key, this.initialIndex = 0, this.height = 56.0}) : super(key: key);

  @override
  _HomeBottomNavigationBarState createState() => _HomeBottomNavigationBarState();
}

class _HomeBottomNavigationBarState extends State<HomeBottomNavigationBar> {
  int currentIndex = 1;
  double currntHeight = 0.0;
  final List<Map<int, Widget>> screens = [
    {1:HomePage()},
    {1:HomePage()},
    {1:HomePage()},
    {1:HomePage()},
  ];

  List<Map<dynamic, dynamic>> mixedMap = [
    {
    "num": 0,
    "page": HomePage(),
    "item":BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム')
    },
    {
    "num": 1,
    "page": HomePage(),
    "item":BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'お気に入り')
    },
    {
    "num": 2,
    "page": HomePage(),
    "item":BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'お知らせ')
    },
    {
    "num": 3,
    "page": HomePage(),
    "item":BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定')
    },
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    // BottomNavigationBar の高さを取得し、変数に格納
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final currntHeight = renderBox.size.height;
      setState(() {
        this.currntHeight = currntHeight;
      });
    });
  }

  double get height => currntHeight;

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> itemList = mixedMap.map((map) => map["item"]).toList()
    .whereType<BottomNavigationBarItem>() // BottomNavigationBarItem型の要素のみ抽出
    .toList();
    return BottomNavigationBar(
      selectedItemColor: Colors.blue,
      currentIndex: currentIndex,
      onTap: (index) {
        setState(() {
          currentIndex = index;
          MaterialPageRoute(builder: (context) => HomePage());
        });
      },
      items: itemList,
      type: BottomNavigationBarType.fixed,
    );
  }
}

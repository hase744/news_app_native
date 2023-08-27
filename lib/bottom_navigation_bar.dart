import 'package:flutter/material.dart';

class HomeBottomNavigationBar extends StatefulWidget {
  final int initialIndex;

  HomeBottomNavigationBar({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _HomeBottomNavigationBarState createState() => _HomeBottomNavigationBarState();
}

class _HomeBottomNavigationBarState extends State<HomeBottomNavigationBar> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.blue,
      currentIndex: currentIndex,
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'お気に入り'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'お知らせ'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
      ],
      type: BottomNavigationBarType.fixed,
    );
  }
}

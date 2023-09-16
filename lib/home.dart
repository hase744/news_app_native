import 'package:flutter/material.dart';
import 'main.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  List sports = ['野球','サッカー','テニス','バスケ', '剣道','柔道','水泳','卓球'];
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0, // 最初に表示するタブ
      length: 8, // タブの数
      child: Scaffold(
        appBar: AppBar(
          title: TextButton(
            onPressed: () {
              //Navigator.pushReplacement(
              //  context,
              //  MaterialPageRoute(builder: (context) => const MyHomePage()),
              //);
            },
            child: const Text(
              "ページ遷移",
              style: TextStyle(color: Colors.white),
            ),
          ),
          //bottom: const TabBar(
          //  isScrollable: true, // スクロールを有効化
          //  tabs: <Widget>[
          //    Tab(text: '野球'),
          //    Tab(text: 'サッカー'),
          //    Tab(text: 'テニス'),
          //    Tab(text: 'バスケ'),
          //    Tab(text: '剣道'),
          //    Tab(text: '柔道'),
          //    Tab(text: '水泳'),
          //    Tab(text: '卓球'),
          //  ],
          //),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
               _headerSection(),
              _tabSection(),
               _headerSection(),
            ];
          },
          body: TabBarView(
            children: <Widget>[
              for (var title in sports)
              ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Center(
                    child: Text(
                      title + index.toString(),
                      style: const TextStyle(
                        fontSize: 100,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//header部分
Widget _headerSection() {
  return SliverList(
    delegate: SliverChildListDelegate(
      [
        Container(
          color: Colors.orangeAccent,
          height: 100,
          child: const Center(
            child: Text('headerSection'),
          ),
        ),
      ],
    ),
  );
}

//TabBar部分
Widget _tabSection() {
  return  SliverPersistentHeader(
    pinned: true,
    delegate: _StickyTabBarDelegate(
      tabBar:
      TabBar(
        isScrollable: true,
              unselectedLabelColor: Colors.grey,
              unselectedLabelStyle: TextStyle(fontSize: 12.0),
              labelColor: Colors.black,
              labelStyle: TextStyle(fontSize: 16.0),
              indicatorColor: Colors.blue,
            //isScrollable: true, // スクロールを有効化
            tabs: <Widget>[
              Container(
                child: Text("野球"),
              ),
              //Text("data"),
              Tab(text: '野球'),
              Tab(text: 'サッカー'),
              Tab(text: 'テニス'),
              Tab(text: 'バスケ'),
              Tab(text: '剣道'),
              Tab(text: '柔道'),
              Tab(text: '水泳'),
              Tab(text: '卓球'),
            ],
            //indicatorColor: Colors.blue,
          ),
    ),
  );
}

//SliverPersistentHeaderDelegateを継承したTabBarを作る
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabBarDelegate({required this.tabBar});

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_news/models/home_layout.dart';
class TopNavigation extends StatelessWidget{
  HomeLayout homeLayout;
  String loadText;
  double width;
  TextEditingController controller;
  Function(String) onSearched;
  final VoidCallback onClosesd;
  final VoidCallback menuOpened;
  final VoidCallback searchOpened;

  TopNavigation({
    required this.homeLayout,
    required this.loadText,
    required this.width,
    required this.controller,
    required this.onSearched,
    required this.onClosesd,
    required this.menuOpened,
    required this.searchOpened
  });

@override
Widget build(BuildContext context){
  return 
    Column(
      children: [
      Container(
        height: homeLayout.loadAreaHeight,
        alignment: Alignment.bottomCenter,
        color: Colors.white,
        child: 
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(loadText),
              if(homeLayout.loadCounting && homeLayout.loadCount < homeLayout.maxLoadCount)
              Container(
                height: homeLayout.loadAreaHeight/4,
                width: homeLayout.loadAreaHeight/4,
                child: 
                CircularProgressIndicator(
                  value: homeLayout.loadCount/homeLayout.maxLoadCount,
                  color: Colors.grey,
                ),
              )
            ]
          )
        )
      ),
      Container(
        height: homeLayout.searchAreaHeight,
        alignment: Alignment.centerRight,
        color: Colors.white,
        child: 
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if(homeLayout.displaySearch)
            Container(
              color: Colors.white,
              width: width,
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'キーワードで検索',
                  prefixIcon: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new),
                    onPressed: onClosesd
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                    },
                  ),
                ),
                onSubmitted: onSearched,
              ),
            ),
            if(!homeLayout.displaySearch)
            IconButton(
              onPressed: searchOpened,
              icon: Icon(Icons.search)
            ),
            if(!homeLayout.displaySearch)
            SizedBox(
              width: homeLayout.searchAreaHeight,
              child:
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.blue,),
                onPressed: menuOpened
              )
            )
          ],
        ),
      )
    ]
  );
  }
}
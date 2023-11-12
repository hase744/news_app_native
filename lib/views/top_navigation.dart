import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_news/controllers/home_layout_controller.dart';
import 'package:video_news/controllers/load_controller.dart';
class TopNavigation extends StatelessWidget{
  HomeLayoutController homeLayoutController;
  LoadController loadController;
  double width;
  TextEditingController controller;
  Function(String) onSearched;
  final VoidCallback onClosesd;
  final VoidCallback menuOpened;
  final VoidCallback searchOpened;
  // ignore: annotate_overrides, overridden_fields
  final Key? key;

  TopNavigation({
    required this.homeLayoutController,
    required this.loadController,
    required this.width,
    required this.controller,
    required this.onSearched,
    required this.onClosesd,
    required this.menuOpened,
    required this.searchOpened,
    this.key,
  }) : super(key: key);

@override
Widget build(BuildContext context){
  return 
    Column(
      children: [
      Container(
        height: homeLayoutController.loadAreaHeight,
        alignment: Alignment.bottomCenter,
        color: Colors.white,
        child: 
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(loadController.getLoadText()),
              if(loadController.loadCounting && loadController.loadCount < loadController.maxLoadCount)
              SizedBox(
                height: homeLayoutController.loadAreaHeight/4,
                width: homeLayoutController.loadAreaHeight/4,
                child: 
                CircularProgressIndicator(
                  value: loadController.loadCount/loadController.maxLoadCount,
                  color: Colors.grey,
                ),
              )
            ]
          )
        )
      ),
      Container(
        height: homeLayoutController.searchAreaHeight,
        alignment: Alignment.centerRight,
        color: Colors.white,
        child: 
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if(homeLayoutController.displaySearch)
            Container(
              color: Colors.white,
              width: width,
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'キーワードで検索',
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: onClosesd
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                    },
                  ),
                ),
                onSubmitted: onSearched,
              ),
            ),
            if(!homeLayoutController.displaySearch)
            IconButton(
              onPressed: searchOpened,
              icon: const Icon(Icons.search)
            ),
            if(!homeLayoutController.displaySearch)
            SizedBox(
              width: homeLayoutController.searchAreaHeight,
              child:
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey,),
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
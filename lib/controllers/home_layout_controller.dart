import 'package:flutter/material.dart';
class HomeLayoutController  {
  double barHeight = 0;
  double deviceWidth = 0;
  double innerHeight = 0;
  double deviceHeight = 0;
  bool isPortrait = true;
  bool isLoading = false;
  bool canLoad = false;
  bool displaySearch = false;
  double youtubePadding = 0.07;

  int loadCount = 1;
  int maxLoadCount = 20;
  bool loadCounting = false;
  
  //deviceWidthに対し高さの割合
  double categoryBarRatio = 1/10;
  double searchAreaRatio = 1/10;
  double loadAreaRatio = 1/5;
  double youtubeDisplayRatio = 9/16;
  double youtubeCloseButtonRatio = 1/15;

  double appBarHeight = 40;
  late double topMenuRatio = searchAreaRatio + loadAreaRatio;
  late double categoryBarHeight = deviceWidth*categoryBarRatio;
  late double categoryBarLineHeight = 5;
  //late double menu_area = deviceWidth/5;
  late double searchAreaHeight = deviceWidth*searchAreaRatio;
  late double loadAreaHeight = deviceWidth*loadAreaRatio;
  late double youtubeDisplayHeight = deviceWidth*youtubeDisplayRatio;
  late double youtubeDisplayWidth = deviceWidth;
  late double youtubeDisplayTop = 0;
  late double youtubeDisplayLeft = 0;
  late double bottomNavigationBarHeight = barHeight;
  late double alertHeight = 0;
  late double pressHeight = 0;
  late double cellsHeight = 0;
  late double videoCellsTop = deviceWidth*topMenuRatio; //menu_areaと同じ値
  late double youtubeCloseButtonSize = deviceWidth*youtubeCloseButtonRatio;
  late bool ishome = false;
  
  HomeLayoutController({
    required this.deviceWidth,
    required this.deviceHeight,
    required this.barHeight,
    required this.innerHeight,
    required this.appBarHeight,
  });

  setForDefault(){
    categoryBarHeight = 0;
    categoryBarLineHeight = 0;
    youtubeDisplayHeight = 0;
  }

  setForList(){
    categoryBarHeight = 0;
    categoryBarLineHeight = 0;
    youtubeDisplayHeight = 0;
    loadAreaHeight = 0;
  }

  double getTopMenuHeight(){
    return searchAreaHeight + loadAreaHeight;
  }
  
  double getbottomSpaceHeight(int i){
    cellsHeight = deviceHeight 
    - appBarHeight 
    - searchAreaHeight
    - youtubeDisplayHeight
    - bottomNavigationBarHeight;
    double cellsReplaceSpace = (cellsHeight - i*deviceWidth/32*9).clamp(0.0, cellsHeight);
    return cellsReplaceSpace;
  }
  
  getYoutubeDisplayWidth(context){
    //画面が縦向きである
    if(MediaQuery.of(context).orientation == Orientation.portrait){
      if(youtubeDisplayWidth > 0){ //ディスプレイが開いている
        return deviceWidth;
      }else{
        return 0;
      }
    }{//画面が横向きである
      //return (deviceWidth *(1 - youtubePadding*2))/youtubeDisplayRatio;
      return deviceHeight;
    }
  }

  updateCellsTop(double scrollTop){//menuが見える時以外offsetは0にする
    videoCellsTop = scrollTop.clamp(0.0, getTopMenuHeight());
  }

  getYoutubeDisplayHeight(context){
    //画面が縦向きである
    if(MediaQuery.of(context).orientation == Orientation.portrait){
      if(youtubeDisplayWidth > 0){ //ディスプレイが開いている
        return deviceWidth*youtubeDisplayRatio;
      }else{
        return 0;
      }
    }{//画面が横向きである
      //return deviceWidth *(1 - youtubePadding*2);
      return deviceWidth;
    }
  }
  
  getAlertTop(){
    return listViewTop() + searchAreaHeight - categoryBarHeight;
  }

  categoryBar(){
    return categoryBarHeight;
  }

  Offset youtubePlayerOffset(context){
    if(MediaQuery.of(context).orientation == Orientation.portrait){//縦向き
      youtubeDisplayTop = appBarHeight + getTopMenuHeight() + categoryBarHeight + categoryBarLineHeight - videoCellsTop;
      if(youtubeDisplayLeft != deviceWidth){//youtubeが開いている
        youtubeDisplayLeft = 0;
      }
      return Offset(youtubeDisplayLeft,  youtubeDisplayTop);
    }{//横向き
      youtubeDisplayTop = deviceWidth * youtubePadding;
      youtubeDisplayLeft = (deviceHeight - deviceWidth/youtubeDisplayRatio)/2 + deviceWidth/youtubeDisplayRatio*youtubePadding;
      youtubeDisplayTop = 0;
      youtubeDisplayLeft = 0;
      return Offset(youtubeDisplayLeft,  youtubeDisplayTop);
    }
  }

  Offset youtubeCloseOffset(context){
    if(MediaQuery.of(context).orientation == Orientation.portrait){//縦向き
      youtubeDisplayTop = appBarHeight + getTopMenuHeight() + categoryBarHeight + categoryBarLineHeight - videoCellsTop + youtubeDisplayHeight;
      if(youtubeDisplayLeft != deviceWidth){//youtubeが開いている
        youtubeDisplayLeft = deviceWidth - youtubeCloseButtonSize;
      }
      return Offset(youtubeDisplayLeft,  youtubeDisplayTop);
    }{
      return Offset(deviceHeight,  deviceWidth);
    }
  }

  Offset categorybarOffset(){
    return Offset(0, getTopMenuHeight() - videoCellsTop) ;
  }
   Offset getTopMenuOffset(){
    return Offset(0, - videoCellsTop.clamp(0.0, loadAreaHeight));
   }

  setHeightForVideoCells(){
    pressHeight = 0;
    pressHeight = innerHeight
     - appBarHeight
     - categoryBarHeight
     - categoryBarLineHeight
     - loadAreaHeight
     - searchAreaHeight
     - youtubeDisplayHeight
     - bottomNavigationBarHeight
     - alertHeight
     - pressHeight
     - 2;
  }

  displayYoutube(){
    youtubeDisplayLeft = 0;
    youtubeDisplayHeight = deviceWidth*youtubeDisplayRatio;
    youtubeDisplayWidth = deviceWidth;
  }

  hideYoutube(){
    youtubeDisplayLeft = deviceWidth;
    youtubeDisplayHeight = 0;
  }

  getInnerScrollHeight(){
    double height = appBarHeight + categoryBarHeight + categoryBarLineHeight + youtubeDisplayHeight + pressHeight;
    return height - getTopMenuHeight();
  }

  listViewTop(){
    return categoryBarHeight + categoryBarLineHeight + youtubeDisplayHeight;
  }
}
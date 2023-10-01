import 'package:flutter/material.dart';
class HomeLayout  {
  double barHeight = 0;
  double deviceWidth = 0;
  double _number = 0;
  double innerHeight = 0;
  double deviceHeight = 0;
  bool isPortrait = true;
  bool isLoading = false;
  double youtubePadding = 0.07;

  //deviceWidthに対し高さの割合
  double categoryBarRatio = 1/10;
  double searchAreaRatio = 1/10;
  double loadAreaRatio = 1/5;
  double youtubeDisplayRatio = 9/16;
  late double topMenuRatio = searchAreaRatio + loadAreaRatio;

  late double appBarHeight = 40;
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
  late double videoCellsOffset = deviceWidth*topMenuRatio; //menu_areaと同じ値
  late bool ishome = false;
  double get number => _number;
  
  HomeLayout({
    required this.deviceWidth,
    required this.deviceHeight,
    required this.barHeight,
    required this.innerHeight,
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
  
  getYoutubeDisplayWidth(context){
    //画面が縦向きである
    if(MediaQuery.of(context).orientation == Orientation.portrait){
      if(youtubeDisplayWidth > 0){ //ディスプレイが開いている
        return deviceWidth;
      }else{
        return 0;
      }
    }{//画面が横向きである
      return (deviceWidth *(1 - youtubePadding*2))/youtubeDisplayRatio;
    }
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
      return deviceWidth *(1 - youtubePadding*2);
    }
  }
  

  categoryBar(){
    return categoryBarHeight;
  }

  Offset youtubePlayerOffset(context){
    if(MediaQuery.of(context).orientation == Orientation.portrait){//縦向き
      youtubeDisplayTop = appBarHeight + getTopMenuHeight() + categoryBarHeight + categoryBarLineHeight - videoCellsOffset;
      if(youtubeDisplayLeft != deviceWidth){//youtubeが開いている
        youtubeDisplayLeft = 0;
      }
      return Offset(youtubeDisplayLeft,  youtubeDisplayTop);
    }{//横向き
      youtubeDisplayTop = deviceWidth * youtubePadding;
      youtubeDisplayLeft = (deviceHeight - deviceWidth/youtubeDisplayRatio)/2 + deviceWidth/youtubeDisplayRatio*youtubePadding;
      return Offset(youtubeDisplayLeft,  youtubeDisplayTop);
    }
  }

  Offset categorybarOffset(){
    return Offset(0, getTopMenuHeight() - videoCellsOffset) ;
  }
   Offset getTopMenuOffset(){
    return Offset(0, - videoCellsOffset.clamp(0.0, loadAreaHeight));
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
    print("隠す");
  }

  getInnerScrollHeight(){
    double height = appBarHeight + categoryBarHeight + categoryBarLineHeight + youtubeDisplayHeight + pressHeight;
    if(ishome){
      return height;
    }else{
      return height - getTopMenuHeight();
    }
  }

  listViewTop(){
    return categoryBarHeight + categoryBarLineHeight + youtubeDisplayHeight;
  }

  // Setter
  set name(String s) {
    if (s.length > 0 && s.length < 11) {
    } else {
      print('$s:文字数を1文字以上10文字以下にしてください。');
    }
  }
}
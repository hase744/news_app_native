import 'package:flutter/material.dart';
class LayoutHeight  {
  double barHeight = 0;
  double deviceWidth = 0;
  double _number = 0;
  double innerHeight = 0;
  double deviceHeight = 0;
  bool isPortrait = true;
  double youtubePadding = 0.07;
  late double app_bar = 40;
  late double category_bar = deviceWidth/10;
  late double category_bar_line =5;
  //late double menu_area = deviceWidth/5;
  late double search_area = deviceWidth/10;
  late double load_area = deviceWidth/10;
  late double youtubeDisplayHeight = deviceWidth/16*9;
  late double youtubeDisplayWidth = deviceWidth;
  late double youtubeDisplayTop = 0;
  late double youtubeDisplayLeft = 0;
  late double bottom_nabigation_bar = barHeight;
  late double alert = 0;
  late double news_cells = 0;
  late double videoCellsOffset = deviceWidth/5; //menu_areaと同じ値
  late bool ishome = false;
  double get number => _number;
  
  LayoutHeight({
    required this.deviceWidth,
    required this.deviceHeight,
    required this.barHeight,
    required this.innerHeight,
  });

  setForDefault(){
    category_bar = 0;
    category_bar_line = 0;
    youtubeDisplayHeight = 0;
  }

  setForList(){
    category_bar = 0;
    category_bar_line = 0;
    youtubeDisplayHeight = 0;
    load_area = 0;
  }

  double getTopMenuHeight(){
    return search_area + load_area;
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
      return (deviceWidth *(1 - youtubePadding*2))/9*16;
    }
  }

  getYoutubeDisplayHeight(context){
    //画面が縦向きである
    if(MediaQuery.of(context).orientation == Orientation.portrait){
      if(youtubeDisplayWidth > 0){ //ディスプレイが開いている
        return deviceWidth*9/16;
      }else{
        return 0;
      }
    }{//画面が横向きである
      return deviceWidth *(1 - youtubePadding*2);
    }
  }
  

  categoryBar(){
    return category_bar;
  }

  Offset youtubePlayerOffset(context){
    if(MediaQuery.of(context).orientation == Orientation.portrait){//縦向き
      youtubeDisplayTop = app_bar + getTopMenuHeight() + category_bar + category_bar_line - videoCellsOffset;
      if(youtubeDisplayLeft != deviceWidth){//youtubeが開いている
        youtubeDisplayLeft = 0;
      }
      return Offset(youtubeDisplayLeft,  youtubeDisplayTop);
    }{//横向き
      youtubeDisplayTop = deviceWidth * youtubePadding;
      youtubeDisplayLeft = (deviceHeight - deviceWidth/9*16)/2 + deviceWidth/9*16*youtubePadding;
      return Offset(youtubeDisplayLeft,  youtubeDisplayTop);
    }
  }

  Offset categorybarOffset(){
    return Offset(0, getTopMenuHeight() - videoCellsOffset) ;
  }
   Offset getTopMenuOffset(){
    return Offset(0, - videoCellsOffset.clamp(0.0, load_area));
   }

  setHeightForVideoCells(){
    news_cells = 0;
    news_cells = innerHeight
     - app_bar
     - category_bar
     - category_bar_line
     - load_area
     - search_area
     - youtubeDisplayHeight
     - bottom_nabigation_bar
     - alert
     - news_cells
     - 2;
  }

  displayYoutube(){
    youtubeDisplayLeft = 0;
    youtubeDisplayHeight = deviceWidth/16*9;
    youtubeDisplayWidth = deviceWidth;
  }

  hideYoutube(){
    youtubeDisplayLeft = deviceWidth;
    youtubeDisplayHeight = 0;
    print("隠す");
  }

  getInnerScrollHeight(){
    double height = app_bar + category_bar + category_bar_line + youtubeDisplayHeight + news_cells;
    if(ishome){
      return height;
    }else{
      return height - getTopMenuHeight();
    }
  }

  listViewTop(){
    return category_bar + category_bar_line + youtubeDisplayHeight;
  }

  // Setter
  set name(String s) {
    if (s.length > 0 && s.length < 11) {
    } else {
      print('$s:文字数を1文字以上10文字以下にしてください。');
    }
  }
}
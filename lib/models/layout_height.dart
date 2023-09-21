import 'package:flutter/material.dart';
class LayoutHeight  {
  double barHeight = 0;
  double deviceWidth = 0;
  double _number = 0;
  double innerHeight = 0;
  double deviceHeight = 0;
  bool isPortrait = true;
  late double app_bar = 40;
  late double category_bar = deviceWidth/10;
  late double category_bar_line =5;
  late double menu_area = deviceWidth/10;
  late double youtubeDisplayHieght = deviceWidth/16*9;
  late double youtubeDisplayWidth = deviceWidth;
  late double youtubeDisplayTop = 0;
  late double youtubeDisplayLeft = 0;
  late double bottom_nabigation_bar = barHeight;
  late double alert = 0;
  late double news_cells = 0;
  late double scrollOffset = deviceWidth/10; //menu_areaと同じ値
  late bool ishome = false;
  double get number => _number;


  // Getter
  //double get number => number;
  
  LayoutHeight({
    required this.deviceWidth,
    required this.deviceHeight,
    required this.barHeight,
    required this.innerHeight,
  });

  setForDefault(){
    category_bar = 0;
    category_bar_line = 0;
    youtubeDisplayHieght = 0;
  }

  setYoutubeOrientation(){
  //  if(isPortrait){
  //    print("縦むき");
  //  displayYoutube();
  //  }else{
  //    print("横むき");
  //  youtubeDisplayWidth = deviceWidth/9*16;
  //  youtubeDisplayHieght = deviceWidth;
  //  }
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
      return deviceHeight;
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
      return deviceWidth;
    }
  }
  

  categoryBar(){
    return category_bar;
  }

  double menuArea(){
    return menu_area;
  }

  Offset youtubePlayerOffset(context){
    double left = 0;
    if(youtubeDisplayHieght > 0){
      left = deviceWidth; 
    }
    if(MediaQuery.of(context).orientation == Orientation.portrait){
      youtubeDisplayTop = app_bar + menu_area + category_bar + category_bar_line - scrollOffset;
      return Offset(youtubeDisplayLeft,  app_bar + menu_area + category_bar + category_bar_line - scrollOffset);
    }{
      return const Offset(0,  0);
    }
  }

  Offset categorybarOffset(){
    return Offset(0, menu_area - scrollOffset) ;
  }

  setForNewsCellsHeight(){
    news_cells = 0;
    news_cells = innerHeight
     - app_bar
     - category_bar
     - category_bar_line
     - menu_area
     - youtubeDisplayHieght
     - bottom_nabigation_bar
     - alert
     - news_cells
     - 2;
  }

  displayYoutube(){
    print("ディスプレイ");
    youtubeDisplayLeft = 0;
    youtubeDisplayHieght = deviceWidth/16*9;
    youtubeDisplayWidth = deviceWidth;
  }

  hideYoutube(){
    youtubeDisplayLeft = deviceWidth;
    youtubeDisplayHieght = 0;
  }

  getInnerScrollHeight(){
    double height = app_bar + category_bar + category_bar_line + youtubeDisplayHieght + news_cells;
    if(ishome){
      return height;
    }else{
      return height - menu_area;
    }
  }

  // Setter
  set name(String s) {
    if (s.length > 0 && s.length < 11) {
    } else {
      print('$s:文字数を1文字以上10文字以下にしてください。');
    }
  }
}
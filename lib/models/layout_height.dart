import 'package:flutter/material.dart';
class LayoutHeight  {
  double barHeight = 0;
  double deviceWidth = 0;
  double _number = 0;
  double innerHeight = 0;
  late double app_bar = 40;
  late double category_bar = deviceWidth/10;
  late double category_bar_line =5;
  late double menu_area = deviceWidth/10;
  late double youtube_display = deviceWidth/16*9;
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
    required this.barHeight,
    required this.innerHeight,
  });

  setForDefault(){
    category_bar = 0;
    category_bar_line = 0;
    youtube_display = 0;
  }

  categoryBar(){
    return category_bar;
  }

  double menuArea(){
    return menu_area;
  }

  Offset youtubePlayerOffset(){
    return Offset(0,  menu_area + category_bar + category_bar_line - scrollOffset);
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
     - youtube_display
     - bottom_nabigation_bar
     - alert
     - news_cells
     - 2;
  }

  displayYoutube(){
    youtube_display = deviceWidth/16*9;
  }

  hideYoutube(){
     youtube_display = 0;
  }

  getInnerScrollHeight(){
    double height = app_bar + category_bar + category_bar_line + youtube_display + news_cells;
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
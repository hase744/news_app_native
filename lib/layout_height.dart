import 'package:flutter/material.dart';
class LayoutHeight  {
  double _barHeight = 0;
  double _deviceWidth = 0;
  double _number = 0;
  late double app_bar = 40;
  late double category_bar =_deviceWidth!/10;
  late double category_bar_line =5;
  late double menu_area =_deviceWidth!/10;
  late double youtube_display =_deviceWidth!/16*9;
  late double bottom_nabigation_bar = _barHeight;
  late double alert = 0;

  // Getter
  double get number => _number;

  // Setter
  set name(String s) {
    if (s.length > 0 && s.length < 11) {
    } else {
      print('$s:文字数を1文字以上10文字以下にしてください。');
    }
  }
}
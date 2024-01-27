import 'package:flutter/material.dart';
class Device{
  static isVertical(BuildContext context){
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
}
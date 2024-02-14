import 'package:flutter/material.dart';
class NavigationItem{
  String name;
  BottomNavigationBarItem item;
  dynamic page;
  NavigationItem({
    required this.name,
    required this.page,
    required this.item
  });
}
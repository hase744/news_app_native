import 'package:flutter/material.dart';
class MenuButton{
  String name = '';
  bool isDestractive;
  VoidCallback onPressed;

  MenuButton({
    required this.onPressed,
    required this.name,
    required this.isDestractive
  });
}
import 'package:flutter/material.dart';
class MenuButton{
  String name = '';
  VoidCallback onPressed;

  MenuButton({
    required this.onPressed,
    required this.name
  });
}
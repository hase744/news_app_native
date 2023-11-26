import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Alert extends StatelessWidget {
  String text = "";
  double height = 0.0;
  double width= 0.0;
  
  Alert({
    super.key,
    required this.text,
    required this.height,
    required this.width
  });

  Future getWidth() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('device_width') ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    //final width = await getWidth();
    return Container(
      height: height,
      width: width,
      color: Colors.orange,
      child: Text(
        text, 
        style: 
        const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}
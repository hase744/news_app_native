import 'package:flutter/material.dart';
import 'package:video_news/models/press.dart';
import 'package:video_news/models/menu_button.dart';
class ModalWindow extends StatelessWidget  {
  double windowWidth = 0;
  List<MenuButton> buttons = [];

  ModalWindow({
    required this.windowWidth,
    required this.buttons
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        //mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for(final button in buttons)
            TextButton(
              child: Container(
                width: windowWidth,
                child: Center(
                  child:Text(
                  button.name,
                  style: TextStyle(
                      fontSize: windowWidth!/15,
                      color: Colors.grey
                    ),
                  )
                ),
              ),
              style: OutlinedButton.styleFrom(
                primary: Colors.black,
              ),
              onPressed: button.onPressed
            ),
          ]
        ),
        height: 500,
        alignment: Alignment.center,
        width: double.infinity,
        decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 20,
          )
        ],
      ),
    );
  }
}
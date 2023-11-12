import 'package:flutter/material.dart';
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
      height: 500,
        alignment: Alignment.center,
        width: double.infinity,
        decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 20,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        //mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for(final button in buttons)
            TextButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              onPressed: button.onPressed,
              child: SizedBox(
                width: windowWidth,
                child: Center(
                  child:Text(
                  button.name,
                  style: TextStyle(
                      fontSize: windowWidth/15,
                      color: Colors.grey
                    ),
                  )
                ),
              )
            ),
          ]
        ),
    );
  }
}
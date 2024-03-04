import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class DisplayButtomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final double height;
  VoidCallback onPushed;

  DisplayButtomButton({
    required this.icon, 
    required this.label,
    required this.height,
    required this.onPushed
    });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(height/10),
      height: height,
      child: 
      InkWell(
        highlightColor:Colors.black26,
        borderRadius: BorderRadius.circular(height),
        onTap: onPushed,
        child:  
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: height/3,
            vertical: 2
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(height),
          ),
          child:
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(right: height/10),
                child:
                Icon(
                  icon,
                  size: height/2,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: height/3,
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          )
        )
      )
    );
  }
}
// ignore_for_file: overridden_fields

import 'package:flutter/material.dart';
import 'package:video_news/controllers/category_controller.dart';
import 'package:video_news/controllers/category_bar_controller.dart';
class CategoryBar extends StatelessWidget {
  final double barHeight;
  final double lineHeight;
  final double width;
  final CategoryController categoryController;
  late CategoryBarController categoryBarController;
  final ScrollController controller;
  Function(int) onSelected;
  // ignore: annotate_overrides
  final Key? key;

  List<Color> colors = [
   const Color.fromRGBO(250, 100, 100, 1),
   const Color.fromRGBO(250, 140, 60, 1),
   const Color.fromRGBO(0, 200, 110, 1),
   const Color.fromRGBO(90, 145, 255, 1),
   const Color.fromRGBO(200, 90, 255, 1),
  ];

  CategoryBar({
    required this.barHeight,
    required this.lineHeight,
    required this.width,
    required this.categoryController,
    required this.categoryBarController,
    required this.onSelected,
    required this.controller,
    this.key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final width = await getWidth();
    double radiusSize = width/5/15;
    return 
    Container(
      alignment: Alignment.center,
      child: 
      Column(
        children: [
          SizedBox(
            width: width,
            height: barHeight,
            child: 
            ListView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              children: [
                for (var i = 0; i < categoryController.categories.length; i++)
                Stack(
                  alignment: Alignment.bottomCenter,
                  //mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      color: categoryController.categoryIndex < i ? colors[(i-1) % colors.length] : colors[(i+1) % colors.length],
                      width: categoryBarController.lablSize(i),
                      //width: width / 5,
                      height: radiusSize
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: 
                        BorderRadius.only(
                          topLeft: Radius.circular(radiusSize),
                          topRight: Radius.circular(radiusSize),
                          bottomLeft: i > categoryController.categoryIndex ? Radius.circular(radiusSize) : const Radius.circular(0),
                          bottomRight: i < categoryController.categoryIndex ? Radius.circular(radiusSize) : const Radius.circular(0),
                        ),
                        color: colors[i % colors.length],
                      ),
                      width: categoryBarController.lablSize(i),
                      height: categoryController.categoryIndex == i ? barHeight : barHeight*0.9,
                      padding: const EdgeInsets.all(0),
                      margin: const EdgeInsets.all(0),
                      child: TextButton(
                        onPressed: () => onSelected(i),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(0), // ボタンの内側の余白
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0), // 角丸の半径
                          ),
                        ),
                        child: 
                        Text(
                          categoryController.categories[i].japaneseName,
                          style: TextStyle(
                            fontSize: categoryBarController.categoryTextSize(i),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ]
                )
              ],
            )
          ),
          Container(
            color: colors[categoryController.categoryIndex%5],
            width: width,
            height: lineHeight,
          ),
        ],
      )
    );
  }
}
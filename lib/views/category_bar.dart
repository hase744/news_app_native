import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_news/controllers/category_controller.dart';
class CategoryBar extends StatelessWidget {
  double barHeight;
  double lineHeight;
  double width;
  CategoryController categoryController;
  ScrollController controller;
  Function(int) onSelected;
  List<Color> colors = [
   const Color.fromRGBO(250, 100, 100, 1),
   const Color.fromRGBO(250, 140, 60, 1),
   const Color.fromRGBO(0, 200, 110, 1),
   const Color.fromRGBO(90, 145, 255, 1),
   const Color.fromRGBO(185, 90, 255, 1),
  ];

  CategoryBar({
    required this.barHeight,
    required this.lineHeight,
    required this.width,
    required this.categoryController,
    required this.onSelected,
    required this.controller
  });

  double categoryTextSize(int textCount) {
    double fontSize = 0;
    if(textCount < 4){
      fontSize = width/20;
    }else if(textCount == 4){
      fontSize = width/20 - 1;
    }else{
      fontSize = width/5/textCount;
    }
    return fontSize.clamp(0.0, width/25) -1;
  }

  @override
  Widget build(BuildContext context) {
    //final width = await getWidth();
    double radiusSize = width/5/20;
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
                    Container(
                      child: 
                      Stack(
                        alignment: Alignment.bottomCenter,
                        //mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            color: categoryController.categoryIndex < i ? colors[(i-1) % colors.length] : colors[(i+1) % colors.length],
                            width: width / 5,
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
                            width: width / 5,
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
                                  fontSize: categoryTextSize(categoryController.categories[i].japaneseName.length),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ]
                      ),
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
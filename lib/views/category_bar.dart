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
   const Color.fromRGBO(90, 255, 110, 1),
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

  double fontSize(int text_count) {
    double fontSize = 0;
    if(text_count < 4){
      fontSize = width/20;
    }else{
      fontSize = width/5/text_count;
    }
    return fontSize -1;
  }

  @override
  Widget build(BuildContext context) {
    //final width = await getWidth();
    return 
    Container(
        alignment: Alignment.center,
        child: 
          Column(
            children: [
              Container(
                width: width,
                height: barHeight,
                child: 
                ListView(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  physics: ClampingScrollPhysics(),
                  children: [
                    for (var i = 0; i < categoryController.categories.length; i++)
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: 
                              categoryController.categoryIndex == i ?
                              const BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5),
                              )
                              :const BorderRadius.only(),
                              color: colors[i % colors.length],
                            ),
                            width: width / 5,
                            height: categoryController.categoryIndex == i ? barHeight : barHeight*0.9,
                            padding: EdgeInsets.all(0),
                            margin: EdgeInsets.all(0),
                            child: TextButton(
                              child: 
                              Text(
                                categoryController.categories[i].japaneseName,
                                style: TextStyle(
                                  fontSize: fontSize(categoryController.categories[i].japaneseName.length),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () => onSelected(i),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.all(0), // ボタンの内側の余白
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0), // 角丸の半径
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
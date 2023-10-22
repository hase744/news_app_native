import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_news/setting_page.dart';
import 'package:video_news/page_transition.dart';
import 'package:video_news/controllers/category_controller.dart';
import 'package:video_news/models/category.dart';

class CategorySetting extends StatefulWidget {



  _CategorySetting createState() => _CategorySetting();
}

class _CategorySetting extends State<CategorySetting>  {
  PageTransition _pageTransition = PageTransition();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.red,
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color.fromRGBO(255,251,255, 1),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () {
              _pageTransition.movePage(SettingPage(), context, false);
            },
          ),
          title: Text('カテゴリー並び替え',style: TextStyle(color: Colors.black)),
        ),
        body: 
          //Flexible(
          //  child:
            Container(
              color: Color.fromRGBO(242, 242, 247, 1),
              child: 
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text("ドラッグ&ドロップで並び替え"),
                  Flexible(
                    child:Container(
                      color: Color.fromRGBO(242, 242, 247, 1),
                      child: const ReorderableExample(),)
                  )
                ]
              )
      
            )
          //)
      ),
    );
  }
}

class ReorderableExample extends StatefulWidget {
  const ReorderableExample({super.key});

  @override
  State<ReorderableExample> createState() => _ReorderableExampleState();
}

class _ReorderableExampleState extends State<ReorderableExample> {
  double? _deviceHeight;
  CategoryController categoryController = CategoryController();

  @override
  void initState() {
    super.initState();
    init();
  }
  void init() async {
      categoryController = await CategoryController();
    setState(() {
      categoryController = CategoryController();
      _deviceHeight = MediaQuery.of(context).size.height;
    });
  }
  
  countCategory()async{
  }

  @override
  Widget build(BuildContext context) {
    final List<Card> cards = <Card>[
      for (int index = 0; index < categoryController.categories.length; index += 1)
        Card(
          key: Key('$index'),
          color: Colors.white,
          child: SizedBox(
            height: 40,
            child: Center(
              child: Container(
                alignment: Alignment.centerLeft,
                child: 
                //SingleChildScrollView(
                //  scrollDirection: Axis.horizontal,
                  //child: 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: 
                        IconButton(
                          icon:   categoryController.categories[index].isDeleting ?
                          const Icon(Icons.add_circle, color: Colors.red)
                          :const Icon(Icons.do_not_disturb_on, color: Colors.red),
                          onPressed: () {
                            setState(() {
                                categoryController.categories[index].isDeleting = ! categoryController.categories[index].isDeleting;
                            });
                          },
                        ),
                      ),
                      Container(
                        child: Text('${categoryController.categories[index].japaneseName}')
                      ),
                      Spacer(),
                      Container(
                        child: Icon(Icons.dehaze_sharp, color: Colors.grey)
                      ),
                      if( categoryController.categories[index].isDeleting)
                      Container(
                        alignment: Alignment.centerRight,
                        color: Colors.red,
                        child: 
                        TextButton(
                          onPressed: () { 
                            setState(() {
                            categoryController.delete(index);
                            });
                           },
                          child: Text('削除'),
                        ),
                      ),
                    ]
                  )
                )
              //)
            ),
          ),
        ),
      ];

    Widget proxyDecorator(
        Widget child, int index, Animation<double> animation) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          final double animValue = Curves.easeInOut.transform(animation.value);
          final double elevation = lerpDouble(0, 6, animValue)!;
          return Material(
            elevation: elevation,
            color: Colors.red,
            shadowColor: Colors.blue,
            child: child,
          );
        },
        child: child,
      );
    }

    return ReorderableListView(
      children: cards,
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          Category category = categoryController.categories.removeAt(oldIndex);
          categoryController.categories.insert(newIndex, category);
          categoryController.saveOrder();
          
        });
      },
      
    );
  }
}

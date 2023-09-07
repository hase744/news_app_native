import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_news/setting_page.dart';
import 'page_transition.dart';

class CategorySetting extends StatefulWidget {
  //const CategorySetting({super.key});
  List _press = [];
  
  categoryOrder() async {
    final prefs = await SharedPreferences.getInstance();
    String? _currentPress = await prefs.getString('presses');
    List _pressParams = json.decode(_currentPress!);
    List<Map<String, dynamic>> _perssParams = _pressParams.map((item) {
      return {"name": item["name"], "japanese_name": item["japanese_name"]};
    }).toList();
    //await prefs.remove('categoryOrder');
    String _categoriesOrder = await prefs.getString('categoryOrder') ?? json.encode(_perssParams);
    List _categoryParams = json.decode(_categoriesOrder);
    List newOrder =  [];
    List newPresses = [];
    List unMatchedPresses = [];
    _categoryParams.asMap().forEach((int i, category) {
      bool foundMatch = false;
      _pressParams.asMap().forEach((int j, press) {
          //print("$i, $j");
        if(press['name']  == category['name']){
          //print(press);
          //print(category);
          newOrder.add(category);
          newPresses.add(press);
          foundMatch;
          //print("return");
          return;
        }
        if(!foundMatch){
          unMatchedPresses.add(category);
        }
      });
    });
    for(var item in unMatchedPresses){
      
    }

    return newOrder;
  }
  Future<List> getPressOrder() async {
    final prefs = await SharedPreferences.getInstance();
    //await prefs.remove('categoryOrder');
    String? _currentPress = await prefs.getString('presses');
    List _pressParams = json.decode(_currentPress!);
    List<Map<String, dynamic>> _perssParams = _pressParams.map((item) {
      return {"name": item["name"], "japanese_name": item["japanese_name"]};
    }).toList();
    String _categoriesOrder = await prefs.getString('categoryOrder') ?? json.encode(_perssParams);
    List _categoryParams = json.decode(_categoriesOrder);
    List newPersses = [];

    for (var category in _categoryParams ) {
      for (var press in _pressParams ) {
        if(category['name'] == press['name']){
          newPersses.add(press);
        }
      }
    }
    return newPersses;
  }


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
  List _presses = [];
  double? _deviceHeight;
  List  _deleteSetting = [];

  @override
  void initState() {
    super.initState();
    init();
  }
  void init() async {
    final prefs = await SharedPreferences.getInstance();
    CategorySetting categorySetting = CategorySetting();
    List _press = await categorySetting.categoryOrder();
    setState(() {
      print(_press);
      _presses = _press;
      _deviceHeight = MediaQuery.of(context).size.height;
      _deleteSetting = _presses.map((press) => {'name':press["name"], 'delete': false}).toList();
    });
  }

  void updateCategoryOrder() async  {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> _categoryOrder = _presses.map((item) {
      return {"name": item["name"], "japanese_name": item["japanese_name"]};
    }).toList();
    await prefs.setString('categoryOrder',json.encode(_categoryOrder));
  }

  void deleteCategory(String name) async  {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> _categoryOrder = _presses.map((item) {
      return {"name": item["name"], "japanese_name": item["japanese_name"]};
    }).toList();
    int index = 0;
    for (var item in _categoryOrder) {
      if(item['name'] == name){
        index = _categoryOrder.indexOf(item);
      }
    }
    setState(() {
      _presses.removeAt(index);
      _categoryOrder.removeAt(index);
      _deleteSetting.removeAt(index);
    });
    await prefs.setString('categoryOrder',json.encode(_categoryOrder));
  }

  @override
  Widget build(BuildContext context) {
    final List<Card> cards = <Card>[
      for (int index = 0; index < _presses.length; index += 1)
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
                          icon:   _deleteSetting[index]['delete'] ?
                          const Icon(Icons.add_circle, color: Colors.red)
                          :const Icon(Icons.do_not_disturb_on, color: Colors.red),
                          onPressed: () {
                            setState(() {
                                _deleteSetting[index]['delete'] = ! _deleteSetting[index]['delete'];
                            });
                          },
                        ),
                      ),
                      Container(
                        child: Text('${_presses[index]['japanese_name']}')
                      ),
                      Spacer(),
                      Container(
                        child: Icon(Icons.dehaze_sharp, color: Colors.grey)
                      ),
                      if( _deleteSetting[index]['delete'])
                      Container(
                        alignment: Alignment.centerRight,
                        color: Colors.red,
                        child: 
                        TextButton(
                          onPressed: () { 
                            deleteCategory(_presses[index]['name']);
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
      //padding: const EdgeInsets.symmetric(horizontal: 40),
      //proxyDecorator: proxyDecorator,
      children: cards,
      onReorder: (int oldIndex, int newIndex) {
          print("並び替え");
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final Map category = _presses.removeAt(oldIndex);
          _presses.insert(newIndex, category);
          updateCategoryOrder();
        });
      },
      
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_news/setting_page.dart';

class CategorySetting extends StatefulWidget {
  //const CategorySetting({super.key});
  List _press = [];
  
  categoryOrder() async {
    final prefs = await SharedPreferences.getInstance();
    String? _currentPress = await prefs.getString('presses');
    List _pressParams = json.decode(_currentPress!);
    List<Map<String, dynamic>> _perssNames = _pressParams.map((item) {
      return {"name": item["name"], "japanese_name": item["japanese_name"]};
    }).toList();
    //await prefs.remove('categoryOrder');
    String _categoriesOrder = await prefs.getString('categoryOrder') ?? json.encode(_perssNames);
    List _categoryParams = json.decode(_categoriesOrder);
    List newOrder =  [];
    List newPresses = [];
    List unMatchedPresses = [];
    _categoryParams.asMap().forEach((int i, press) {
      bool foundMatch = false;
      _pressParams.asMap().forEach((int j, category) {
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
          unMatchedPresses.add(press);
        }
      });
    });

    return newOrder;
  }
  Future<List> getPressOrder() async {
    final prefs = await SharedPreferences.getInstance();
    String? _currentPress = await prefs.getString('presses');
    List _pressParams = json.decode(_currentPress!);
    List<Map<String, dynamic>> _perssNames = _pressParams.map((item) {
      return {"name": item["name"], "japanese_name": item["japanese_name"]};
    }).toList();
    String _categoriesOrder = await prefs.getString('categoryOrder') ?? json.encode(_perssNames);
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
              // Add your back button functionality here
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SettingPage()),
              );
            },
          ),
          title: Text('カテゴリー並び替え',style: TextStyle(color: Colors.black)),
        ),
        body: Container(
          color: Color.fromRGBO(242, 242, 247, 1),
          child: const ReorderableExample(),
        )
        //const ReorderableExample(),
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
  final List<int> _items = List<int>.generate(50, (int index) => index);
  List _pesses = [];

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
      _pesses = _press;
    });
  }

  void updateCategoryOrder(List<Map<String, dynamic>> categoryNames) async  {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('categoryOrder',json.encode(categoryNames));
  }

  @override
  Widget build(BuildContext context) {
    final List<Card> cards = <Card>[
      for (int index = 0; index < _pesses.length; index += 1)
        Card(
          key: Key('$index'),
          color: Colors.white,
          child: SizedBox(
            height: 40,
            child: Center(
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text('${_pesses[index]['japanese_name']}'),
              )
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
      padding: const EdgeInsets.symmetric(horizontal: 40),
      //proxyDecorator: proxyDecorator,
      children: cards,
      onReorder: (int oldIndex, int newIndex) {
          print("並び替え");
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final Map category = _pesses.removeAt(oldIndex);
          _pesses.insert(newIndex, category);
          List<Map<String, dynamic>> _categoryOrder = _pesses.map((item) {
            return {"name": item["name"], "japanese_name": item["japanese_name"]};
          }).toList();
          print(_categoryOrder);
          updateCategoryOrder(_categoryOrder);
        });
      },
      
    );
  }
}

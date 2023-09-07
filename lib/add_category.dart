import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'setting_page.dart';
import 'category_setting.dart';
import 'dart:convert';
import 'page_transition.dart';

class AddCategoyPage extends StatefulWidget {
  const AddCategoyPage({super.key, required this.title});

  final String title;

  @override
  State<AddCategoyPage> createState() => _AddCategoyPageState();
}

class _AddCategoyPageState extends State<AddCategoyPage> {
  List _categories = [];
  List _pressParams = [];
  List _unChosedCategories = [];
  PageTransition _pageTransition = PageTransition();
  double? _deviceHeight, _deviceWidth;
  @override
  void initState() {
    super.initState();;
    init();
  }

  void init() async {
    final prefs = await SharedPreferences.getInstance();
    CategorySetting categorySetting = CategorySetting();

    List _category = await categorySetting.categoryOrder();
    String? _currentPress = await prefs.getString('presses');
    PageTransition _pageTransition  = PageTransition();

    _pressParams = json.decode(_currentPress!);
    setState(() {
      //print(_category);
      _categories = _category;
      _deviceHeight = MediaQuery.of(context).size.height;
      _deviceWidth = MediaQuery.of(context).size.width;
      for(var i=0; i<_pressParams.length; i++){
        Map press = _pressParams[i];
        bool rooping = true;
        for(var j=0; j<_categories.length; j++){
          //print(_categories[i]);
          print("$i, $j");
          if(press['name'] == _categories[j]['name']){
            print('return');
            rooping = false;
          };

          if(j+1 == _categories.length && rooping){
            print('追加');
            _unChosedCategories.add({'name':press['name'], 'japanese_name':press['japanese_name'], 'is_added':false});
          }
        }
      }
    });
  }
  
  void addCategory(String name) async  {
    final prefs = await SharedPreferences.getInstance();
    Map press = _pressParams.firstWhere((element) => element["name"] == name);
    Map category_param = {'name':press['name'], 'japanese_name':press['japanese_name']};
    _categories.add(category_param);
    await prefs.setString('categoryOrder',  json.encode(_categories));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          title: Text('カテゴリー追加',style: TextStyle(color: Colors.black)),
        ),
      body: 
      Container(
        color: Color.fromRGBO(242, 242, 247, 1),
        child: 
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              if(_unChosedCategories.length > 0)
              Text("追加ボタンからカテゴリーを追加"),
              if(_unChosedCategories.length == 0)
              Text(
                "追加可能なカテゴリーはありません",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey
                ),
              ),
              Flexible(
              child: 
              ListView.builder(
                itemCount: _unChosedCategories.length,
                itemBuilder: (context, index) {
                  final category = _unChosedCategories[index];
                  return 
                  Container(
                    width: _deviceWidth! - 2,
                    height: 50,
                    color: Colors.white,
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category['japanese_name'],
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Spacer(),
                          Container(
                            child: _unChosedCategories[index]['is_added'] ?
                              IconButton(
                                icon:  Icon(Icons.check_circle, color: Colors.green) ,
                                onPressed: () {
                                  setState(() {
                                    //_unChosedCategories[index]['is_added'] = !_unChosedCategories[index]['is_added'];
                                  });
                                },
                              ):
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _unChosedCategories[index]['is_added'] = !_unChosedCategories[index]['is_added'];
                                  addCategory(category['name']);
                                });
                              },
                              child: 
                                Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red),
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.red
                                  ),
                                  child: 
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                    Text(
                                      "追加",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    const Icon(Icons.add_circle, color: Colors.white),
                                  ]
                                ),
                                
                              )
                              
                            )
                          ),
                          
                        ]
                      ),
                    );
                  },
                ),
              ),
            ]
          )
        )
      )
    );
  }
}

import 'package:flutter/material.dart';
import 'setting_page.dart';
import 'page_transition.dart';
import 'package:video_news/controllers/category_controller.dart';

class AddCategoyPage extends StatefulWidget {
  const AddCategoyPage({super.key, required this.title});

  final String title;

  @override
  State<AddCategoyPage> createState() => _AddCategoyPageState();
}

class _AddCategoyPageState extends State<AddCategoyPage> {
  PageTransition _pageTransition = PageTransition();
    CategoryController _categoryController = CategoryController();
  double? _deviceHeight, _deviceWidth;
  @override
  void initState() {
    super.initState();;
    init();
  }

  void init() async {
    CategoryController categoryController = await CategoryController();
    setState(() {
      _categoryController = categoryController;
      _deviceHeight = MediaQuery.of(context).size.height;
      _deviceWidth = MediaQuery.of(context).size.width;
    });
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
              if(_categoryController.unusedCategories.length > 0)
              Text("追加ボタンからカテゴリーを追加"),
              if(_categoryController.unusedCategories.length == 0)
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
                itemCount: _categoryController.unusedCategories.length,
                itemBuilder: (context, index) {
                  final category = _categoryController.unusedCategories[index];
                  return 
                  Container(
                    width: _deviceWidth! - 2,
                    height: 50,
                    color: Colors.white,
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category.japaneseName,
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Spacer(),
                          Container(
                            child: _categoryController.unusedCategories[index].isAdded ?
                              IconButton(
                                icon:  Icon(Icons.check_circle, color: Colors.green) ,
                                onPressed: () {
                                  setState(() {
                                    //_categoryController.unusedCategories[index]['is_added'] = !_categoryController.unusedCategories[index]['is_added'];
                                  });
                                },
                              ):
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _categoryController.unusedCategories[index].isAdded = !_categoryController.unusedCategories[index].isAdded;
                                  //addCategory(category.name);
                                  _categoryController.add(_categoryController.unusedCategories[index]);
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

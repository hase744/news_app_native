import 'package:flutter/material.dart';
import 'package:video_news/controllers/category_controller.dart';

class AddCategoyPage extends StatefulWidget {
  const AddCategoyPage({super.key, required this.title});

  final String title;

  @override
  State<AddCategoyPage> createState() => _AddCategoyPageState();
}

class _AddCategoyPageState extends State<AddCategoyPage> {
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
        backgroundColor: const Color.fromRGBO(255,251,255, 1),
        title: const Text('カテゴリー追加',style: TextStyle(color: Colors.black)),
      ),
      body: 
      Container(
        color: const Color.fromRGBO(242, 242, 247, 1),
        child: 
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              if(_categoryController.unusedCategories.isNotEmpty)
              const Text("追加ボタンからカテゴリーを追加"),
              if(_categoryController.unusedCategories.isEmpty)
              const Text(
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
                            " ${category.emoji} ${category.japaneseName}",
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            child: _categoryController.unusedCategories[index].isAdded ?
                              IconButton(
                                icon:  const Icon(Icons.check_circle, color: Colors.green) ,
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
                                  const Row(
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
                                    Icon(Icons.add_circle, color: Colors.white),
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

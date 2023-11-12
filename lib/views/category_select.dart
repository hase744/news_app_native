import 'package:flutter/material.dart';
import 'package:video_news/controllers/category_controller.dart';
import 'package:video_news/models/category.dart';
import 'package:video_news/views/home_page.dart';
class CategorySelect extends StatefulWidget {
  @override
  _CategorySelectState createState() => _CategorySelectState();
}
class _CategorySelectState extends State<CategorySelect>  {
  CategoryController _categoryController = CategoryController();
  List selectedCategories = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    CategoryController categoryController = await CategoryController();
    setCategory(categoryController);
  }
  
  setCategory(CategoryController categoryController){
     setState(() {
      _categoryController = categoryController;
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    double modalHeight = deviceHeight *0.9;
    List categorySelectionNames = _categoryController.selection.map((c){return c.name;}).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
                "興味のあるカテゴリーを選択",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
      ),
      body: 
      Container(
        height:  modalHeight,
        width: deviceWidth,
        color: Colors.white,
        alignment: Alignment.topLeft,
        child: 
        SingleChildScrollView(
          child: 
          Column(
            children: <Widget>[
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child:
                Wrap(
                  spacing: 15.0,
                  runSpacing: 10.0,
                  children: List<Widget>.generate(
                    _categoryController.categories.length,
                    (int index) {
                      Category category = _categoryController.categories[index];
                      return 
                      ChoiceChip(
                        label: Text(
                          "${category.emoji}${category.japaneseName}",
                            style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        selected:  categorySelectionNames.contains(category.name),
                        onSelected: (bool selected) {
                          int selectionIndex = categorySelectionNames.indexOf(category.name);
                          setState(() {
                            if(selectionIndex == -1){
                              _categoryController.selection.add(category);
                            }else{
                              _categoryController.selection.removeAt(selectionIndex);
                            }
                          });
                        },
                      );
                    },
                  ).toList(),
                )
              ),
              Center(
                //color: Colors.red,
                //width: deviceWidth,
                child:
                  SizedBox(
                  width: deviceWidth/3,
                  child: 
                  ElevatedButton(
                    onPressed: () {
                      _categoryController.saveSelection();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) =>const HomePage(initialIndex: 0,)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                        '次へ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                )
              )
            ],
          ),
        )
      ),
    );
  }
}
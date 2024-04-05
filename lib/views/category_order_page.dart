import 'package:flutter/material.dart';
import 'package:video_news/consts/colors.dart';
import 'package:video_news/controllers/category_controller.dart';
import 'package:video_news/models/category.dart';
import 'package:video_news/view_models/category_view_model.dart';

class CategoryOrder extends StatefulWidget {
  const CategoryOrder({Key? key}) : super(key: key);
  @override
  CategoryOrderState createState() => CategoryOrderState();
}

class CategoryOrderState extends State<CategoryOrder>  {
  @override
  Widget build(BuildContext context) {
    return
    Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromRGBO(255,251,255, 1),
        title: const Text('カテゴリー並び替え',style: TextStyle(color: Colors.black)),
      ),
      body: 
      Container(
        color: ColorConfig.settingBackground,
        child: 
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text("ドラッグ&ドロップで並び替え"),
            Flexible(
              child:Container(
                color: ColorConfig.settingBackground,
                child: const ReorderableExample(),
              )
            )
          ]
        )
      )
    );
  }
}

class ReorderableExample extends StatefulWidget {
  const ReorderableExample({super.key});

  @override
  State<ReorderableExample> createState() => _ReorderableExampleState();
}

class _ReorderableExampleState extends State<ReorderableExample> {
  CategoryController categoryController = CategoryController();
  //CategoryViewModel _categoryViewModel = CategoryViewModel();

  @override
  void initState() {
    super.initState();
    init();
  }
  void init() async {
    //_categoryViewModel.setRef(ref);
    categoryController = await CategoryController();
    setState(() {
      categoryController = CategoryController();
    });
  }
  
  countCategory()async{
  }

  @override
  Widget build(BuildContext context) {
    //List<Category> categories = _categoryViewModel.unusedCategories;
    final List<Card> cards = <Card>[
      for (int index = 0; index < categoryController.categories.length; index += 1)
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        margin:  EdgeInsets.all(0),
        key: Key('$index'),
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: 
              BorderSide(
                color: ColorConfig.settingBorder,
                width: 0.5,
              ),
            ),
          ),
          height: 40,
          child: Center(
            child: Container(
              alignment: Alignment.centerLeft,
              child: 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon:   categoryController.categories[index].isDeleting! ?
                    const Icon(Icons.add_circle, color: Colors.red):
                    const Icon(Icons.do_not_disturb_on, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        categoryController.categories[index] = categoryController.categories[index].copyWith(isDeleting: ! categoryController.categories[index].isDeleting!);
                          //categoryController.categories[index].isDeleting = ! categoryController.categories[index].isDeleting;
                      });
                    },
                  ),
                  Text('${categoryController.categories[index].emoji} ${categoryController.categories[index].japaneseName}'),
                  const Spacer(),
                  const Icon(Icons.dehaze_sharp, color: Colors.grey),
                  if(categoryController.categories[index].isDeleting!)
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
                      child: const Text(
                        '削除',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ]
              )
            )
          ),
        ),
      ),
    ];
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

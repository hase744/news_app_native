import 'package:flutter/material.dart';
import 'package:video_news/controllers/category_controller.dart';
import 'package:video_news/models/category.dart';

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
        color: const Color.fromRGBO(242, 242, 247, 1),
        child: 
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text("ドラッグ&ドロップで並び替え"),
            Flexible(
              child:Container(
                color: const Color.fromRGBO(242, 242, 247, 1),
                child: const ReorderableExample(),)
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

  @override
  void initState() {
    super.initState();
    init();
  }
  void init() async {
    categoryController = await CategoryController();
    setState(() {
      categoryController = CategoryController();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  Text('${categoryController.categories[index].emoji} ${categoryController.categories[index].japaneseName}'),
                  const Spacer(),
                  const Icon(Icons.dehaze_sharp, color: Colors.grey),
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
                      child: const Text('削除'),
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

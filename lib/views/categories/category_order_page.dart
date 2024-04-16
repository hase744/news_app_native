import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_news/consts/colors.dart';
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

class ReorderableExample extends ConsumerStatefulWidget {
  const ReorderableExample({super.key});

  @override
  ConsumerState<ReorderableExample> createState() => _ReorderableExampleState();
}

class _ReorderableExampleState extends ConsumerState<ReorderableExample> {
  final _categoryViewModel = CategoryViewModel();
  double? _deviceWidth;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    _categoryViewModel.setRef(ref);
  }

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    List<Category> categories = _categoryViewModel.savedCategories;
    final List<Card> cards = <Card>[
      for (int index = 0; index < categories.length; index += 1)
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
          height: _deviceWidth!/10,
          child: Center(
            child: Container(
              alignment: Alignment.centerLeft,
              child: 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: categories[index].isDeleting! ?
                    const Icon(Icons.add_circle, color: Colors.red):
                    const Icon(Icons.do_not_disturb_on, color: Colors.red),
                    onPressed: () {
                      _categoryViewModel.onDeletePushed(index);
                    },
                  ),
                  if([null, ''].contains(categories[index].imageUrl))
                  Container(
                    height: _deviceWidth!/10,
                    width: _deviceWidth!/20,
                    margin: EdgeInsets.only(right: _deviceWidth!/80),
                    child: 
                    Center(
                      child: 
                      Text(
                        categories[index].emoji,
                        style: TextStyle(
                          fontSize:  _deviceWidth!/25
                        ),
                      )
                    ),
                  ),
                  if(![null, ''].contains(categories[index].imageUrl))
                  Container(
                    height: _deviceWidth!/20,
                    width: _deviceWidth!/20,
                    margin: EdgeInsets.only(right: _deviceWidth!/80),
                    child: 
                    Center(
                      child: 
                      ClipRRect(
                        borderRadius: BorderRadius.circular(_deviceWidth!),
                        child:
                        Image.network(categories[index].imageUrl!)
                      )
                    )
                  ),
                  Container(
                    height: _deviceWidth!/10,
                    child: 
                    Center(
                      child: 
                      Text(
                        '${categories[index].japaneseName}',
                        style: TextStyle(
                          fontSize:  _deviceWidth!/25
                        ),
                      )
                    ),
                    //margin: EdgeInsets.only(right: _deviceWidth!/80),
                  ),
                  const Spacer(),
                  Container(
                    child: Icon(Icons.dehaze_sharp, color: Colors.grey),
                    margin: EdgeInsets.only(right: _deviceWidth!/80),
                  ),
                  if(categories[index].isDeleting!)
                  Container(
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    child: 
                    TextButton(
                      onPressed: () { 
                          _categoryViewModel.onDeleted(index);
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
        _categoryViewModel.onReordered(oldIndex, newIndex);
      },
      
    );
  }
}

import 'package:flutter/material.dart';
import 'package:video_news/consts/colors.dart';
import 'package:video_news/controllers/category_controller.dart';
import 'package:video_news/view_models/category_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_news/models/category.dart';
import 'dart:io';

class AddCategoyPage extends ConsumerStatefulWidget {
  const AddCategoyPage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<AddCategoyPage> createState() => _AddCategoyPageState();
}

class _AddCategoyPageState extends ConsumerState<AddCategoyPage> {
    CategoryController _categoryController = CategoryController();
  double? _deviceHeight, _deviceWidth;
  CategoryViewModel _categoryViewModel = CategoryViewModel();
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    _categoryViewModel.setRef(ref);
    CategoryController categoryController = await CategoryController();
    //_ref.watch(categoryListProvider.notifier).state = categoryController.unusedCategories;
    setState(() {
      _categoryController = categoryController;
      _deviceHeight = MediaQuery.of(context).size.height;
      _deviceWidth = MediaQuery.of(context).size.width;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    List<Category> categories = _categoryViewModel.unusedCategories;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromRGBO(255,251,255, 1),
        title:  Text('カテゴリー追加',style: TextStyle(color: Colors.black)),
      ),
      body: 
      Container(
        color: const Color.fromRGBO(242, 242, 247, 1),
        child: 
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              if(categories.isNotEmpty)
              const Text("追加ボタンからカテゴリーを追加"),
              if(categories.isEmpty)
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
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return 
                    Container(
                      width: _deviceWidth! - 2,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: 
                          BorderSide(
                            color: ColorConfig.settingBorder,
                            width: 0.5,
                          ),
                        ),
                        color: Colors.white,
                      ),
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: _deviceWidth!/20,
                            margin: EdgeInsets.symmetric(horizontal: _deviceWidth!/80),
                            child: 
                            Center(
                              child: 
                              Text(category.emoji,
                                style: TextStyle(
                                  fontSize: _deviceWidth!/20,
                                ),
                              )
                            )
                          ),
                          Text(
                            category.japaneseName,
                            style: TextStyle(
                              fontSize: _deviceWidth!/20,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            child: categories[index].isAdded! ?
                            Container(
                              margin: EdgeInsets.only(right: _deviceWidth!/80),
                              child:
                              const Icon(
                                Icons.check_circle, 
                                color: Colors.green
                              )
                            ):
                            InkWell(
                              onTap: (){
                                _categoryViewModel.onAdded(index);
                                _categoryViewModel = _categoryViewModel;
                              },
                              child: 
                              Container(
                                margin: EdgeInsets.only(right: _deviceWidth!/80),
                                padding: EdgeInsets.symmetric(horizontal: _deviceWidth!/80, vertical: _deviceWidth!/320),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.blue
                                ),
                                child: 
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.add_circle, color: Colors.blue[200]),
                                    SizedBox(width: _deviceWidth!/80),
                                    Text(
                                      "追加",
                                      style: TextStyle(
                                        fontSize: _deviceWidth!/30,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
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

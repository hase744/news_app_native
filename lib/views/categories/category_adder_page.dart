import 'package:flutter/material.dart';
import 'package:video_news/consts/colors.dart';
import 'package:video_news/controllers/category_controller.dart';
import 'package:video_news/view_models/category_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_news/models/category.dart';
import 'package:video_news/views/categories/category_cell.dart';
import 'dart:io';

class AddCategoyPage extends ConsumerStatefulWidget {
  const AddCategoyPage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<AddCategoyPage> createState() => _AddCategoyPageState();
}

class _AddCategoyPageState extends ConsumerState<AddCategoyPage> {
  double? _deviceHeight, _deviceWidth;
  CategoryViewModel _categoryViewModel = CategoryViewModel();
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    _categoryViewModel.setRef(ref);
    setState(() {
      _deviceHeight = MediaQuery.of(context).size.height;
      _deviceWidth = MediaQuery.of(context).size.width;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
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
                    CategoryCell(
                      category: category, 
                      width: _deviceWidth!, 
                      onAdded: (){
                        _categoryViewModel.onAdded(index);
                        _categoryViewModel = _categoryViewModel;
                      }, 
                      onDeleted: (){},
                      isOriginal: false, 
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

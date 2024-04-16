import 'package:flutter/material.dart';
import 'package:video_news/controllers/version_controller.dart';
import 'package:video_news/view_models/alert_view_model.dart';
import 'package:video_news/views/alert.dart';
import 'package:video_news/views/categories/category_edit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_news/view_models/category_view_model.dart';
import 'package:video_news/views/categories/category_cell.dart';

class CategoryOriginal extends ConsumerStatefulWidget {
  @override
  ConsumerState<CategoryOriginal> createState() => _CategoryOriginalState();
}

class _CategoryOriginalState extends ConsumerState<CategoryOriginal> {
  VersionController _versionController = VersionController();
  CategoryViewModel _categoryViewModel = CategoryViewModel();
  AlertViewModel _alertViewModel = AlertViewModel();
  ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _versionController.initialize();
    _alertViewModel.setRef(ref);
    init();
  }

  init() async {
    await _categoryViewModel.setRef(ref);
    _categoryViewModel.setOriginal();
  }

  @override
  Widget build(BuildContext context) {
    double _deviceWidth = MediaQuery.of(context).size.width;
    double _deviceHeight = MediaQuery.of(context).size.height;
    List categories = _categoryViewModel.categories;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromRGBO(255,251,255, 1),
        title: const Text('作成',style: TextStyle(color: Colors.black)),
      ),
      body: 
      Center(
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("＋ボタンからカテゴリーを追加"),
            Expanded(
              child: 
              Stack(
                children: [
                  ListView.builder(
                    itemCount: _categoryViewModel.categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return
                      CategoryCell(
                        category: category, 
                        width: _deviceWidth, 
                        onAdded: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => 
                              ProviderScope(child: CategoryEditPage(category: category))),
                          );
                        }, 
                        onDeleted: () => _categoryViewModel.onDestroyed(context, category, super.widget),
                        isOriginal: true, 
                      );
                    }
                  ),
                  if(_alertViewModel.alert != null)
                  Alert(
                    text: _alertViewModel.alert!,
                    width:  _deviceWidth,
                    height: _deviceWidth/20,
                  ),
                ],
              ),
            )
          ]
        )
      ),
      floatingActionButton:
      FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => 
              ProviderScope(child: CategoryEditPage(category: null))),
          );
        },
        child: new Icon(Icons.add),
      ),
    );
  }
}
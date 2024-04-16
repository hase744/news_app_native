import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_news/controllers/video_controller.dart';
import 'package:video_news/provider/category.dart';
import 'package:video_news/controllers/category_controller.dart';
import 'package:video_news/models/category.dart';
import 'package:video_news/consts/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class CategoryViewModel{
  late WidgetRef _ref;
  final _categoryController = CategoryController();

  setRef(WidgetRef ref) async {
    this._ref = ref;
  }
  setOriginal(){
    _ref.watch(categoryListProvider.notifier).state = [..._categoryController.originalCategories];
  }
  List<Category> get categories => _ref.watch(categoryListProvider);
  List<Category> get unusedCategories => _ref.watch(unusedCategoryProvider).when(
    error: (err, _) => [],
    loading: () => _ref.watch(categoryListProvider.notifier).state,
    data: (data) => data,
  );
  List<Category> get savedCategories => _ref.watch(savedCategoryProvider).when(
    error: (err, _) => [],
    loading: () => _ref.watch(categoryListProvider.notifier).state,
    data: (data) => data,
  );
  //List<Category> get originalCategories => _ref.watch(originalCategoryProvider).when(
  //  error: (err, _) => [],
  //  loading: () => _ref.watch(categoryListProvider.notifier).state,
  //  data: (data) => data,
  //);
  onAdded(int i) async {
    await _categoryController.addFromIndex(i);
    _ref.watch(categoryListProvider.notifier).state = [..._categoryController.unusedCategories];//配列はこうしないと更新されない
  }

  onDeleted(int i) async {
    _categoryController.delete(i);
    _ref.watch(categoryListProvider.notifier).state = [..._categoryController.categories];
  }
  onSaved() async {
    _categoryController.saveOrder();
    _ref.watch(categoryListProvider.notifier).state = [..._categoryController.categories];
  }
  onReordered(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    Category category = _categoryController.categories.removeAt(oldIndex);
    _categoryController.categories.insert(newIndex, category);
    _categoryController.saveOrder();
    _ref.watch(categoryListProvider.notifier).state = [..._categoryController.categories];
  }
  onDeletePushed(int index){
    Category category = _categoryController.categories[index];
    _categoryController.categories[index] = category.copyWith(isDeleting: !category.isDeleting!);
    _ref.watch(categoryListProvider.notifier).state = [..._categoryController.categories];
  }

  onDestroyed(BuildContext context, Category category, Widget widget){
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("チャンネルを削除しますか？"),
          actions: [
            CupertinoDialogAction(
              child: Text('削除'),
              isDestructiveAction: true,
              onPressed: () async {
                var text = '';
                if(await _categoryController.destroy(category)){
                  VideoController videoController = VideoController();
                  videoController.accessVideos();
                  int index = _categoryController.originalCategories.indexWhere((element) => element.name == category.name);
                  _categoryController.originalCategories.removeAt(index);
                  index = _categoryController.categories.indexWhere((element) => element.name == category.name);
                  _categoryController.delete(index);
                  _ref.watch(categoryListProvider.notifier).state = [..._categoryController.originalCategories];
                  text = "削除しました";
                }else{
                  text = "削除に失敗しました";
                };
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(text),
                  ),
                );
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: Text('キャンセル'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      }
    );
  }

  onSearched(String word) async {
    final url = '${Config.domain}/${word}/search_channel.json';
    final response = await http.get(Uri.parse(url));
    List channels = json.decode(response.body);
    channels.forEach((channel){
      channel.fromJson(channel);
    });
  }
}
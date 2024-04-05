import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_news/provider/category.dart';
import 'package:video_news/controllers/category_controller.dart';
import 'package:video_news/models/category.dart';
import 'dart:io';
import 'dart:math';
class CategoryViewModel{
  late WidgetRef _ref;
  final _categoryController = CategoryController();

  void setRef(WidgetRef ref){
    this._ref = ref;
  }
  List<Category> get unusedCategories => _ref.watch(unusedCategoryProvider).when(
    error: (err, _) => [], //エラー時
    loading: () => [], //読み込み時
    data: (data) => data, //データ受け取り時
  );

  List<Category> get savedCategories => _ref.watch(savedCategoryProvider).when(
    error: (err, _) => [], //エラー時
    loading: () => [], //読み込み時
    data: (data) => data, //データ受け取り時
  );

  onAdded(int i) async {
    await _categoryController.add(i);
    _ref.watch(categoryListProvider.notifier).state = _categoryController.unusedCategories.map((c) => c).toList();
  }
}
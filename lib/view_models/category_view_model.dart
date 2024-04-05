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
    error: (err, _) => [],
    loading: () => _ref.watch(categoryListProvider.notifier).state,
    data: (data) => data,
  );
  List<Category> get savedCategories => _ref.watch(savedCategoryProvider).when(
    error: (err, _) => [],
    loading: () => _ref.watch(categoryListProvider.notifier).state,
    data: (data) => data,
  );

  onAdded(int i) async {
    await _categoryController.add(i);
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
}
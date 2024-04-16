import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_news/models/category.dart';
import 'package:video_news/controllers/category_controller.dart';
StateProvider<List<Category>> categoryListProvider = StateProvider<List<Category>>(
  (ref) {
    return [];
  }
);

StateProvider<Category?> categoryProvider = StateProvider<Category?>(
  (ref) {
    return null;
  }
);

FutureProvider<List<Category>> unusedCategoryProvider = FutureProvider<List<Category>>(
  (ref) async {
    List<Category> categories = ref.watch(categoryListProvider);
    if(categories.isEmpty){
      var controller = CategoryController();
      return  controller.unusedCategories;
    }else{
      return categories;
    }
  }
);

FutureProvider<List<Category>> savedCategoryProvider = FutureProvider<List<Category>>(
  (ref) async {
    List<Category> categories = ref.watch(categoryListProvider);
    if(categories.isEmpty){
      var controller = CategoryController();
      return  controller.categories;
    }else{
      return categories;
    }
  }
);
FutureProvider<List<Category>> originalCategoryProvider = FutureProvider<List<Category>>(
  (ref) async {
    List<Category> categories = ref.watch(categoryListProvider);
    if(categories.isEmpty){
      var controller = await CategoryController();
      return  controller.originalCategories;
    }else{
      return categories;
    }
  }
);
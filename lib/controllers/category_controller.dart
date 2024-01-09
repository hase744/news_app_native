import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:video_news/models/category.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_news/consts/config.dart';
import 'dart:convert';

class CategoryController {
  List<Category> categories = [];
  List<Category> selection = [];
  List<Category> unusedCategories = [];
  int categoryIndex = 0;
  late Category currentCategory = categories[categoryIndex];

  CategoryController() {
    setSavedCategory();
    setUnusedCategory();
  }

  update(i) {
    categoryIndex = i;
  }

  Future<List> getCurrentPress() async {
    //await prefs.remove('category_order');
    final prefs = await SharedPreferences.getInstance();
    String? currentPress = prefs.getString('presses');
    List pressParams = json.decode(currentPress!);
    return pressParams;
  }

  Future<List> getCategoriesData() async {
    var response = await http.get(Uri.parse("${Config.domain}/categories.json"));
    var categoryParams = await json.decode(response.body);
    return categoryParams;
  }

  Future<List<Map<String, dynamic>>> getCurrentCategories() async {
    List pressParams = await getCurrentPress();
    List<Map<String, dynamic>> pressMaps = pressParams.map((item) {
      return {
        "name": item["name"],
        "japanese_name": item["japanese_name"],
        "emoji": item["emoji"],
        "is_default": item["is_default"] == true,
      };
    }).toList();
    return pressMaps;
  }

  Future<List> getSavedOrder() async {
    //await prefs.remove('category_order');
    final prefs = await SharedPreferences.getInstance();
    String? categoriesOrder = prefs.getString('category_order');
    List<dynamic> categoryParams = categoriesOrder == null
        ? await getCurrentCategories()
        : json.decode(categoriesOrder);
    return categoryParams;
  }

  updateNames() async {
    List pressParams = await getCurrentPress();
    for (var i = 0; i < categories.length; i++) {
      String name = categories[i].name;
      if (pressParams.any((c) => c['name'] == name)) {
        Map category = pressParams.firstWhere((c) => c['name'] == name);
        categories[i].japaneseName = category['japanese_name'];
        categories[i].emoji = category['emoji'];
      } else {
        categories.removeAt(i);
      }
    }
    saveOrder();
  }

  Future<List> getRearrangedPress() async {
    await updateNames();
    List pressParams = await getCurrentPress();
    List categoryParams = await getSavedOrder();
    List videosList = [];
    for (var category in categoryParams) {
      Map matchedPress = pressParams.firstWhere((c) => c['name'] == category['name']);
      print(matchedPress['press']);
      try {
      print(json.decode(matchedPress['press']));
        videosList.add(json.decode(matchedPress['press']));
      } catch (e) {
        videosList.add(matchedPress['press']);
      }
    }
    return videosList;
  }

  setSavedCategory() async {
    List categoryParams = await getSavedOrder();
    for (var category in categoryParams) {
      categories.add(Category.fromMap(category));
    }
  }

  setUnusedCategory() async {
    List savedParams = await getSavedOrder();
    List<dynamic> currentVideos = await getCurrentPress();
    for (var category in currentVideos) {
      List matchedCategories =
          savedParams.where((c) => c['name'] == category['name']).toList();
      if (matchedCategories.isEmpty) {
        unusedCategories.add(Category.fromMap(category));
      }
    }
  }

  void saveOrder() async {
    List<Map<String, dynamic>> categoryMaps =
        categories.map((c) => c.toMap()).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('category_order', json.encode(categoryMaps.toList()));
  }

  void delete(int index) async {
    categories.removeAt(index);
    saveOrder();
  }

  void add(Category category) async {
    categories.add(category);
    saveOrder();
  }

  saveSelection() async {
    await getCategoriesData();
    List selectionNames = selection.map((c) {
      return c.name;
    }).toList();
    List<dynamic> currentCategories = await getCategoriesData();
    for (var category in currentCategories) {
      if (!selectionNames.contains(category['name']) &&
          category['is_default']) {
        unusedCategories.add(Category.fromMap(category));
      }
    }
    selection.addAll(unusedCategories);
    List<dynamic> categoryMaps = selection.map((c) => c.toMap()).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('category_order', json.encode(categoryMaps));
  }
}

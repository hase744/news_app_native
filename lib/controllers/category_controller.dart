import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:video_news/controllers/video_controller.dart';
import 'package:video_news/models/category.dart';
import 'package:video_news/models/channel.dart';
import 'package:video_news/controllers/uuid_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_news/consts/config.dart';
import 'dart:convert';

class CategoryController {
  List<Category> categories = [];
  List<Category> defaultCategories = [];
  List<List<Category>> childCategoriesList = [];
  List<Category> selection = [];
  List<Category> unusedCategories = [];
  List<Category> formalCategories = [];
  List<Category> originalCategories = [];
  int categoryIndex = 0;
  int changedCount = 0;
  late Category currentCategory = categories[categoryIndex];

  CategoryController() {
    setSavedCategory();
    setUnusedCategory();
    setDeraultCategory();
    setFormalCategory();
    setOriginalCategory();
  }

  Future<List> getCurrentPress() async {
    final prefs = await SharedPreferences.getInstance();
    //await prefs.remove('category_order');
    String? currentPress = prefs.getString('presses');
    List pressParams = json.decode(currentPress!);
    return pressParams;
  }

  Future<List> getCategoriesData() async {
    var response =
        await http.get(Uri.parse("${Config.domain}/categories.json"));
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
        "is_formal": item["is_formal"] == true,
      };
    }).toList();
    return pressMaps;
  }

  Future<List> getSavedOrder() async {
    //await prefs.remove('category_order');
    final prefs = await SharedPreferences.getInstance();
    String? categoryOrder = prefs.getString('category_order');
    List<dynamic> categoryParams = [null, '[]'].contains(categoryOrder)
        ? await getCurrentCategories()
        : json.decode(categoryOrder!);
    return categoryParams;
  }

  updateNames() async {
    List pressParams = await getCurrentPress();
    for (var i = 0; i < categories.length; i++) {
      String name = categories[i].name;
      if (pressParams.any((c) => c['name'] == name)) {
        Map category = pressParams.firstWhere((c) => c['name'] == name);
        categories[i] = categories[i].copyWith(
          japaneseName: category['japanese_name'],
          emoji: category['emoji']
          );
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
      try {
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
      categories.add(Category.fromJson(category));
    }
  }

  setFormalCategory() async {
    final prefs = await SharedPreferences.getInstance();
    //await prefs.remove('category_order');
    String? currentPress = prefs.getString('presses');
    List pressParams = json.decode(currentPress!);
    pressParams = pressParams.where((c) => c['is_formal'] == true).toList();
    formalCategories = pressParams.map((p) => Category.fromJson(p)).toList();
  }

  setOriginalCategory() async {
    final prefs = await SharedPreferences.getInstance();
    //await prefs.remove('category_order');
    String? currentPress = prefs.getString('presses');
    List pressParams = json.decode(currentPress!);
    pressParams = pressParams.where((c) => c['is_original'] == true).toList();
    originalCategories = pressParams.map((p) => Category.fromJson(p)).toList();
  }

  setDeraultCategory() async {
    List categoryParams = await getSavedOrder();
    for (var categoryParam in categoryParams) {
      Category category = Category.fromJson(categoryParam);
      if (category.isDefault && category.isFormal) {
        defaultCategories.add(category);
      }
    }
  }

  setUnusedCategory() async {
    List savedParams = await getSavedOrder();
    List<dynamic> currentCategories = await getCurrentPress();
    List<dynamic> formalCategories = currentCategories.where((c) => c['is_formal'] == true).toList();
    print("セット ${savedParams.length}/${formalCategories.length} ");
    formalCategories.forEach((category) {
      bool isCategoryMatched = savedParams.any((c) => c['name'] == category['name']);
      if (!isCategoryMatched) {
        unusedCategories.add(Category.fromJson(category));
        //print(category['name']);
      }
    });
  }

  void saveOrder() async {
    List<Map<String, dynamic>> categoryMaps = categories.map((c) => c.toJson()).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('category_order', json.encode(categoryMaps.toList()));
  }

  void delete(int index) async {
    categories.removeAt(index);
    saveOrder();
  }

  Future<void> addFromIndex(int i) async {
    Category category = unusedCategories[i];
    unusedCategories[i] = unusedCategories[i].copyWith(isAdded: true);
    categories.add(category);
    saveOrder();
  }

  Future<void> addFromCategory(Category category) async {
    categories.add(category);
    saveOrder();
  }

  saveSelection() async {
    List selectionNames = selection.map((c) {
      return c.name;
    }).toList();
    List<dynamic> currentCategories = await getCategoriesData();
    List<dynamic> defaultCategories = currentCategories.where((c) => c['is_default'] && c['is_formal']).toList();
    List<Category> categories = [];
    for (var category in defaultCategories) {
      if (!selectionNames.contains(category['name'])) {
        categories.add(Category.fromJson(category));
      }
    }
    selection.addAll(categories);
    List<dynamic> categoryMaps = selection.map((c) => c.toJson()).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('category_order', json.encode(categoryMaps));
  }

  Future<bool> create(List<Channel> channels, Category category) async {
    UuidController uuidController = UuidController();
    String jsonData = jsonEncode(
      {
        'uuid': await uuidController.getUuid(),
        'youtube_ids': channels.map((c) => c.youtubeId).toList(),
        'category': category.toJson(),
        'is_formal': true,
      }
    );
    String requestUrl = "${Config.domain}/user/categories";
    final response = await http.post(
      Uri.parse(requestUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonData,
    );
    if(response.statusCode == 200){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> update(List<Channel> channels, Category category) async {
    UuidController uuidController = UuidController();
    String jsonData = jsonEncode(
      {
        'uuid': uuidController.getUuid(),
        'youtubeIds': channels.map((c) => c.youtubeId),
        'category': category.toJson()
      }
    );
    String requestUrl = "${Config.domain}/categories";
    final response = await http.post(
      Uri.parse(requestUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonData,
    );
    if(response.statusCode == 200){
      return true;
    }else{
      return false;
    }
  }

  insertAllChildCategories() async {
    List<dynamic> currentCategories = await getCurrentPress();
    List<dynamic> savedCategories = await getSavedOrder();
    List<Category> childCategories = [];
    childCategoriesList = [];
    for(var index = 0; index < savedCategories.length; index++ ){
      String currentCategoryName = savedCategories[index]['name'];
      Map currentCategory =
          currentCategories.firstWhere((c) => c['name'] == currentCategoryName);
      List<dynamic> childCategoryNames = currentCategory['child_categories'];
      childCategories = [];
      for (var press in await getCurrentPress()) {
        if (childCategoryNames.contains(press['name'])) {
          childCategories.add(Category.fromJson(press));
        }
      }
      childCategoriesList.add(childCategories);
    }
  }

  Future<bool> destroy(Category category) async {
    UuidController uuidController = UuidController();
    String jsonData = jsonEncode(
      {
        'uuid': await uuidController.getUuid(),
        'category': category.toJson(),
      }
    );
    String requestUrl = "${Config.domain}/user/categories";
    final response = await http.delete(
      Uri.parse(requestUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonData,
    );
    if(response.statusCode == 204){
      return true;
    }else{
      return false;
    }
  }

  Future<List> getChannlsOf(Category category) async {
    List presses = await getCurrentPress();
    Map press = presses.firstWhere((element) => element['name'] == category.name);
    List videos = press['videos'];
    List<Channel> channels = videos.map((e) => Channel.fromJson({
      'name': e['name'],
      'image_url': e['image_url'],
      'channel_id': e['channel_id'],
      'channel_youtube_id': e['channel_youtube_id'],
      }
    )).toList();
    return channels;
  }
}

import 'package:video_news/models/category.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
class CategoryController{
  List<Category> categories = [];
  List<Category> unusedCategories = [];
  int categoryIndex = 0;
  late Category currentCategory = categories[categoryIndex];

  CategoryController() {
    setSavedCategory();
    setUnusedCategory();
  }

  Future<List> getCurrentPress() async {
    final prefs = await SharedPreferences.getInstance();
    //await prefs.remove('categoryOrder');
    String? currentPress = prefs.getString('presses');
    List pressParams = json.decode(currentPress!);
    return pressParams;
  }

  Future<List<Map<String, dynamic>>> getCurrentVideos() async {
    List pressParams = await getCurrentPress();
    List<Map<String, dynamic>> pressMaps = pressParams.map((item) {
      return {"name": item["name"], "japanese_name": item["japanese_name"]};
    }).toList();
    return pressMaps;
  }

  Future<List> getSavedOrder() async {
    final prefs = await SharedPreferences.getInstance();
    //await prefs.remove('categoryOrder');
    String categoriesOrder = prefs.getString('categoryOrder') ?? json.encode(getCurrentVideos());
    List categoryParams = json.decode(categoriesOrder);
    return categoryParams;
  }

  categoryOrder() async {
    List<Map<String, dynamic>> pressMaps = await getCurrentVideos();
    List categoryParams = await getSavedOrder();
    List newOrder =  [];
    List newPresses = [];
    categoryParams.asMap().forEach((int i, category) {
      pressMaps.asMap().forEach((int j, press) {
        if(press['name']  == category['name']){
          newOrder.add(category);
          newPresses.add(press);
          return;
        }
      });
    });
    return newOrder;
  }

  Future<List> getPressOrder() async {
    List pressParams = await getCurrentPress();
    List categoryParams = await getSavedOrder();
    List newPersses = [];

    for (var category in categoryParams ) {
      for (var press in pressParams ) {
        if(category['name'] == press['name']){
          newPersses.add(press);
        }
      }
    }
    return newPersses;
  }

  setSavedCategory() async {
    List categoryParams = await getSavedOrder();
    for (var category in categoryParams ) {
      categories.add(
        Category(
          name: category['name'], 
          japaneseName: category['japanese_name']
        )
      );
    }
  }

  setUnusedCategory() async {
    List savedParams = await getSavedOrder();
    List<dynamic> currentVideos = await getCurrentPress();
    for(var category in currentVideos ){
      List matchedCategories = savedParams.where((c) => c['name'] == category['name']).toList();
      if(matchedCategories.length ==  0){
        unusedCategories.add(
          Category(
            name: category['name'], 
            japaneseName: category['japanese_name']
          )
        );
      }
    }
  }

  void updateCategoryOrder() async  {
    List<Map<String, dynamic>> categoryMaps = [];
    for(var i=0; i<categories.length; i++){
      Map<String, dynamic> categoryMap = {};
      categoryMap['name'] = categories[i].name;
      categoryMap['japanese_name'] = categories[i].japaneseName;
      categoryMaps.add(categoryMap);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('categoryOrder',json.encode(categoryMaps.toList()));
  }

  void delete(int index) async  {
    List<Map<String, dynamic>> categoryMaps = [];
    categories.removeAt(index);
    for(var i=0; i<categories.length; i++){
      Map<String, dynamic> categoryMap = {};
      categoryMap['name'] = categories[i].name;
      categoryMap['japanese_name'] = categories[i].japaneseName;
      categoryMaps.add(categoryMap);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('categoryOrder',json.encode(categoryMaps));
  }

  void add(Category category) async  {
    final prefs = await SharedPreferences.getInstance();
    List<dynamic> categoryMaps = await getPressOrder();
    Map category_param = {'name':category.name, 'japanese_name':category.japaneseName};
    categoryMaps.add(category_param);
    await prefs.setString('categoryOrder',json.encode(categoryMaps));
  }
}
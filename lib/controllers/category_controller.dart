import 'package:video_news/models/category.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
class CategoryController{
  List<Category> categories = [];
  List<Category> selection = [];
  List<Category> unusedCategories = [];
  int categoryIndex = 0;
  late Category currentCategory = categories[categoryIndex];

  CategoryController() {
    setSavedCategory();
    setUnusedCategory();
  }

  update(i){
    categoryIndex = i;
  }

  Future<List> getCurrentPress() async {
    //await prefs.remove('categoryOrder');
    final prefs = await SharedPreferences.getInstance();
    String? currentPress = prefs.getString('presses');
    List pressParams = json.decode(currentPress!);
    return pressParams;
  }

  Future<List<Map<String, dynamic>>> getCurrentCategories() async {
    List pressParams = await getCurrentPress();
    List<Map<String, dynamic>> pressMaps = pressParams.map((item) {
      return {"name": item["name"], "japanese_name": item["japanese_name"]};
    }).toList();
    return pressMaps;
  }

  Future<List> getSavedOrder() async {
    //await prefs.remove('categoryOrder');
    final prefs = await SharedPreferences.getInstance();
    String? categoriesOrder = prefs.getString('categoryOrder');
    List<dynamic> categoryParams = categoriesOrder == null 
      ? await getCurrentCategories()
      : json.decode(categoriesOrder);
    return categoryParams;
  }

  Future<List> getRearrangedPress() async {
    List pressParams = await getCurrentPress();
    List categoryParams = await getSavedOrder();
    List videosList = [];
    for(var i=0; i<categoryParams.length; i++){
      String name = categoryParams[i]['name'];
      if(pressParams.any((c) => c['name'] == name)) {
        Map matchedPress = pressParams.firstWhere((c) => c['name'] == name);
        videosList.add(json.decode(matchedPress['press']));
      } else {
        delete(i);
      }
    }
    return videosList;
  }

  setSavedCategory() async {
    List categoryParams = await getSavedOrder();
    for (var category in categoryParams ) {
      categories.add(Category.fromMap(category));
    }
  }

  setUnusedCategory() async {
    List savedParams = await getSavedOrder();
    List<dynamic> currentVideos = await getCurrentPress();
    for(var category in currentVideos ){
      List matchedCategories = savedParams.where((c) => c['name'] == category['name']).toList();
      if(matchedCategories.isEmpty){
        unusedCategories.add(Category.fromMap(category));
      }
    }
  }

  void saveOrder() async  {
    List<Map<String, dynamic>> categoryMaps = categories.map((c) => c.toMap()).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('categoryOrder',json.encode(categoryMaps.toList()));
  }

  void delete(int index) async  {
    categories.removeAt(index);
    saveOrder();
  }

  void add(Category category) async  {
    categories.add(category);
    saveOrder();
  }

  void saveSelection() async {
    List selectionNames = selection.map((c){return c.name;}).toList();
    List<dynamic> currentCategories = await getCurrentPress();
    for(var category in currentCategories ){
      if(!selectionNames.contains(category['name'])){
        unusedCategories.add(Category.fromMap(category));
      }
    }
    selection.addAll(unusedCategories);
    List<dynamic> categoryMaps = selection.map((c) => c.toMap()).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('categoryOrder',json.encode(categoryMaps));
  }
}
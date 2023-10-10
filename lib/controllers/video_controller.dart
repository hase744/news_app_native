import 'package:video_news/controllers/category_controller.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:video_news/controllers/uuid_controller.dart';
import 'package:video_news/consts/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoController{
  late List videosList = [];
  late List videos = [];
  List<Map> selection = [];
  List selectedVideos = [];
  int videoLength = 20;
  bool displayLoadingScreen = true;
  String searchWord = '';
  late int videoCount = videoLength;
  CategoryController categoryController = CategoryController();
  UuidController uuidController = UuidController();
  late final domain = Config.domain;

  setVideosList() async {
    videosList = await getMyVideos();
  }
  
  getMyVideos() async {
    List pressParams = await categoryController.getCurrentPress();
    List categoryParams = await categoryController.getSavedOrder();
    List myVideosList = [];

    for (var category in categoryParams ) {
      for (var press in pressParams ) {
        if(category['name'] == press['name']){
          List myVideos = [];
          for(var video in json.decode(press['press'])){
            myVideos.add(video);
          }
          myVideosList.add(myVideos);
        }
      }
    }
    return myVideosList;
  }

  Future<void> resetVideoCount() async {
    displayLoadingScreen = false;
    videoCount =  videoLength;
    if (videoCount > videos.length) {
      videoCount = videos.length;
    }
  }

  selectVideo(Map video){
    int index = selection.indexWhere((map) => map["youtube_id"] == video['youtube_id']);
    if(index != -1){
      selection.removeAt(index);
    }else{
      selection.add(video);
    }
  }

  changeVideos(int index){
    print("変更 : $index");
    print(videosList[index]);
    videos = videosList[index];
  }

  loadVideos(String pageName, bool searching)async{
    int pageCount = ((videoCount + videoLength)/videoLength).ceil();
    switch(pageName) {
      case 'favorite':
        if(searching){
          List searchingVideos = json.decode(await searchFavorites(searchWord, pageCount));
          videos.addAll(searchingVideos);
        }
        break;
      case 'home':
        if(searching){
          List searchingVideos = json.decode(await searchVideos(searchWord, pageCount));
          videos.addAll(searchingVideos);
        }
      default:
        break;
    }
    videoCount += videoLength;
    if (videoCount > videos.length) { //ロード過多
      videoCount = videos.length;
      if(displayLoadingScreen){
        displayLoadingScreen = false;
      }
    }
  }

  accessVideos() async {
    String url = '$domain/categories/index.json';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('presses', response.body);
      return true;
    } else {
      return false;
    }
  }

  updateVideos(int categoryNumber) async {
    if(await accessVideos()) {
      videosList = await categoryController.getPressOrder();
      videos = videosList[categoryNumber];
      return true;
    }else{
      return false;
    }
  }

  search(String word, String pageName) async {
    searchWord = word;
    switch(pageName) {
      case 'favorite':
        videos = await json.decode(await searchFavorites(searchWord, 1));
        break;
      case 'home':
        videos = await json.decode(await searchVideos(searchWord, 1));
      default:
        break;
    }
    videoCount = videos.length;
  }

  Future<bool> displayFavorites() async {
    String url = '$domain/user/favorites.json?uuid=${await uuidController.getUuid()}';
    final response = await http.get(Uri.parse(url));
    //print("status : ${response.statusCode}");
    if(response.statusCode == 200){
      videos = json.decode(response.body);
      return true;
    }else{
      return false;
    }
  }

  Future <bool> createFavorite(Map video) async {
    String url = "$domain/user/favorites.json?uuid=${await uuidController.getUuid()}&video_id=${video['id']}";
    final response = await http.post(Uri.parse(url));
    return response.statusCode == 200;
  }

  Future <bool> createSelectedFavorite() async {
    List youtubeIds = selection.map((map) => map["id"]).toList();
    final queryString = youtubeIds.map((id) => 'video_ids[]=$id').join('&');
    String url = "$domain/user/favorites/create_multiple.json?uuid=${await uuidController.getUuid()}&$queryString";
    final response = await http.post(Uri.parse(url));
    return response.statusCode == 200;
  }

  Future <bool> deleteFavorite(Map video) async {
    String url = "$domain/user/favorites/${video['id']}.json?uuid=${await uuidController.getUuid()}";
    final response = await http.delete(Uri.parse(url));
    return response.statusCode == 200;
  }

  Future <bool> deleteAllFavorite() async {
    String url = "$domain/user/favorites/delete_all.json?uuid=${await uuidController.getUuid()}";
    final response = await http.delete(Uri.parse(url));
    return response.statusCode == 200;
  }

  Future <bool> deleteSelectedFavorite() async {
    List favoriteIds = selection.map((map) => map["id"]).toList();
    final queryString = favoriteIds.map((id) => 'ids[]=$id').join('&');
    String url = "$domain/user/favorites/delete_multiple.json?uuid=${await uuidController.getUuid()}&$queryString";
    final response = await http.delete(Uri.parse(url));
    return response.statusCode == 200;
  }

  searchVideos(String word, int page) async {
    String url = '$domain/videos.json?word=$word&page=$page';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  }

  searchFavorites(String word, int page) async {
    String url = '$domain/user/favorites/search.json?word=$word&uuid=${await uuidController.getUuid()}&page=$page';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
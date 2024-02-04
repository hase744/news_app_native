import 'package:video_news/controllers/category_controller.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:video_news/controllers/uuid_controller.dart';
import 'package:video_news/controllers/version_controller.dart';
import 'package:video_news/consts/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_news/models/video.dart';

class VideoController{
  late List<List<Video>> videosList = [];
  late List<Video> videos = [];
  List<Video> selection = [];
  int videoLength = 20;
  bool displayingLoadingScreen = true;
  bool displayingVideoList = true;
  bool displayingVideos = true;
  bool displayingAllVideos = true;
  bool isSelectMode = false;
  String searchingWord = '';
  String? searchingCategory;
  CategoryController categoryController = CategoryController();
  VersionController versionController = VersionController();
  UuidController uuidController = UuidController();
  late final domain = Config.domain;

  setVideosList() async {
    videosList = await listsToModels();
  }
  
  displayVideos(){
    displayingAllVideos = true;
    displayingVideoList = false;
    displayingVideos = true;
  }
  displayVideoList(){
    displayingAllVideos = true;
    displayingVideoList = true;
    displayingVideos = false;
  }
  coverVideoAndVideoList(){
    displayingLoadingScreen = true;
    displayingAllVideos = false;
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

  selectVideo(Video video){
    int index = selection.indexWhere((map) => map.id == video.id);
    if(index != -1){
      selection.removeAt(index);
    }else{
      selection.add(video);
    }
  }
  
  disableSelectMode(){
    isSelectMode = false;
    selection = [];
  }

  ableSelectMode(){
    isSelectMode = true;
  }

  changeVideos(int index){
    displayingLoadingScreen = false;
    videos = videosList[index];
  }

  loadVideos(String pageName, bool searching) async {
    int pageCount = ((videos.length + videoLength)/videoLength).ceil();
    bool loadSucced = true;
    if(searching){
      final response = await getSearchedVideos(searchingWord, pageCount, pageName);
      if(response.statusCode == 200){
        videos.addAll(await jsonToModels(response.body));
      }else{
        loadSucced = false;
      }
    }else if(searchingCategory != null){
      final response = await getCategoryVideos(searchingCategory!, pageCount);
      if(response.statusCode == 200){
        videos.addAll(await jsonToModels(response.body));
      }else{
        loadSucced = false;
      }
    }else{
      switch(pageName) {
      case 'favorite':
        final response = await getFavorites(pageCount);
        if(response.statusCode == 200){
          videos.addAll(await jsonToModels(response.body));
        }else{
          loadSucced = false;
        }
        break;
      case 'history':
        final response = await getHistories(pageCount);
        if(response.statusCode == 200){
          videos.addAll(await jsonToModels(response.body));
        }else{
          loadSucced = false;
        }
        break;
      case 'home':
      default:
        break;
      }
    }
    return loadSucced;
  }

  accessVideos() async {
    await versionController.initialize();
    String url = versionController.isReleased ? '$domain/presses.json' : '$domain/fakes/presses.json' ;
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('presses', response.body);
      return true;
    } else {
      return false;
    }
  }

  listsToModels() async {
    List<List<Video>> videoModelsList = [];
    for(var videos in await categoryController.getRearrangedPress()){
      videoModelsList.add(await listToModels(videos));
    }
    return videoModelsList;
  }

  listToModels(List videos) async {
    List<Video> videoModels = [];
    for(var video in videos){
      videoModels.add(Video.fromMap(video));
      //videoModels.add(mapToModel(video));
    }
    return videoModels;
  }

  jsonToModels(String str){
    return   listToModels(json.decode(str));
  }

  Future<bool> updatePress(int categoryNumber) async {
    videos = [];
    displayingLoadingScreen = true;
    coverVideoAndVideoList();
    if(await accessVideos()) {
      videosList = await listsToModels();
      videos = await videosList[categoryNumber];
      displayingLoadingScreen = false;
      return true;
    }else{
      return false;
    }
  }

  search(String word, String pageName) async {
    videos = [];
    String jsonStr = '';
    displayingLoadingScreen = true;
    coverVideoAndVideoList();
    try {
      searchingWord = word;
      print(word);
      final response = await getSearchedVideos(word, 1, pageName);
      jsonStr = response.body;
      videos = await jsonToModels(jsonStr);
      displayingLoadingScreen = false;
      displayVideos();
      return true;
    } catch (e) {
      displayVideoList();
      return false;
    }
  }

  searchCategory(String category) async {
    videos = [];
    String jsonStr = '';
    displayingLoadingScreen = true;
    try {
      searchingCategory = category;
      print(category);
      final response = await getCategoryVideos(category, 1);
      jsonStr = response.body;
      videos = await jsonToModels(jsonStr);
      displayingLoadingScreen = false;
      displayVideos();
      return true;
    } catch (e) {
      print(e);
      displayVideoList();
      return false;
    }
  }

  getFavorites(int page) async {
    String url = '$domain/user/favorites.json?uuid=${await uuidController.getUuid()}&page=$page';
    final response = await http.get(Uri.parse(url));
    return response;
  }

  Future<bool> displayFavorites() async {
    final response = await getFavorites(1);
    if(response.statusCode == 200){
      videos = await jsonToModels(response.body);
      return true;
    }else{
      return false;
    }
  }

  Future <bool> createFavorite(Video video) async {
    String url = "$domain/user/favorites.json?uuid=${await uuidController.getUuid()}&youtube_id=${video.youtubeId}";
    final response = await http.post(Uri.parse(url));
    return response.statusCode == 204;
  }

  Future <bool> createSelectedFavorite() async {
    List youtubeIds = selection.map((map) => map.youtubeId).toList();
    final queryString = youtubeIds.map((id) => 'youtube_ids[]=$id').join('&');
    String url = "$domain/user/favorites/create_multiple.json?uuid=${await uuidController.getUuid()}&$queryString";
    final response = await http.post(Uri.parse(url));
    return response.statusCode == 200;
  }

  Future <bool> deleteFavorite(Video video) async {
    String url = "$domain/user/favorites/${video.id}.json?uuid=${await uuidController.getUuid()}";
    final response = await http.delete(Uri.parse(url));
    if(response.statusCode == 200){
      int videoIndex = videos.map((map) => map.id).toList().indexOf(video.id);
      videos.removeAt(videoIndex);
      return true;
    }else{
      return false;
    }
  }

  Future <bool> deleteAllFavorite() async {
    String url = "$domain/user/favorites/delete_all.json?uuid=${await uuidController.getUuid()}";
    final response = await http.delete(Uri.parse(url));
    return response.statusCode == 200;
  }

  Future <bool> deleteSelectedFavorite() async {
    List favoriteIds = selection.map((map) => map.id).toList();
    final queryString = favoriteIds.map((id) => 'ids[]=$id').join('&');
    String url = "$domain/user/favorites/delete_multiple.json?uuid=${await uuidController.getUuid()}&$queryString";
    final response = await http.delete(Uri.parse(url));
    return response.statusCode == 200;
  }

  getSearchedVideos(String word, int page, String mode) async {
    String url = '';
    switch(mode) {
      case 'favorite':
        url = '$domain/user/favorites/search.json?word=$word&uuid=${await uuidController.getUuid()}&page=$page';
        break;
      case 'history':
        url = '$domain/user/histories/search.json?word=$word&uuid=${await uuidController.getUuid()}&page=$page';
        break;
      case 'home':
        await versionController.initialize();
        url = versionController.isReleased ? '$domain/videos.json?word=$word&page=$page' : '$domain/fakes.json?word=$word&page=$page';
      default:
        break;
    }
    final response = await http.get(Uri.parse(url));
    return response;
  }

  getCategoryVideos(String category, int page) async {
    String url = '';
    await versionController.initialize();
    url = versionController.isReleased ? '$domain/videos.json?category=$category&page=$page' : '$domain/fakes.json?category=$category&page=$page';
        print('url');
        print(url);
    final response = await http.get(Uri.parse(url));
    return response;
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

  getHistories(int page) async {
    String url = '$domain/user/histories.json?uuid=${await uuidController.getUuid()}&page=$page';
    final response = await http.get(Uri.parse(url));
    return response;
  }

  Future<bool> displayHistories() async {
    final response = await getHistories(1);
    //print("status : ${response.statusCode}");
    if(response.statusCode == 200){
      print("200 ok");
      videos = await jsonToModels(response.body);
      return true;
    }else{
      return false;
    }
  }
  Future <bool> createHistory(Video video) async {
    String url = "$domain/user/histories.json?uuid=${await uuidController.getUuid()}&youtube_id=${video.youtubeId}";
    final response = await http.post(Uri.parse(url));
    return response.statusCode == 200;
  }

  searchHistories(String word, int page) async {
    String url = '$domain/user/histories/search.json?word=$word&uuid=${await uuidController.getUuid()}&page=$page';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  }
  
  Future <bool> deleteHistory(Video video) async {
    String url = "$domain/user/histories/${video.id}.json?uuid=${await uuidController.getUuid()}";
    final response = await http.delete(Uri.parse(url));
    if(response.statusCode == 200){
      int videoIndex = videos.map((map) => map.id).toList().indexOf(video.id);
      videos.removeAt(videoIndex);
      return true;
    }else{
      return false;
    }
  }

  Future <bool> deleteSelectedHistory() async {
    List historyIds = selection.map((map) => map.id).toList();
    final queryString = historyIds.map((id) => 'ids[]=$id').join('&');
    String url = "$domain/user/histories/delete_multiple.json?uuid=${await uuidController.getUuid()}&$queryString";
    final response = await http.delete(Uri.parse(url));
    return response.statusCode == 200;
  }

  Future <bool> deleteAllHistory() async {
    String url = "$domain/user/histories/delete_all.json?uuid=${await uuidController.getUuid()}";
    final response = await http.delete(Uri.parse(url));
    return response.statusCode == 200;
  }

  Future <bool> createSelectedHistory() async {
    List youtubeIds = selection.map((map) => map.id).toList();
    final queryString = youtubeIds.map((id) => 'video_ids[]=$id').join('&');
    String url = "$domain/user/histories/create_multiple.json?uuid=${await uuidController.getUuid()}&$queryString";
    final response = await http.post(Uri.parse(url));
    return response.statusCode == 200;
  }

  Future <bool> deleteSelectionOf(String model) async {
    switch(model){
      case 'favorite':
        return deleteSelectedFavorite();
      case 'history':
        return deleteSelectedHistory();
      default:
        return false;
    }
  }
}
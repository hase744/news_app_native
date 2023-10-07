import 'package:video_news/models/video.dart';
import 'package:video_news/controllers/access_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_news/controllers/category_controller.dart';
import 'dart:convert';
class VideoController{
  late List videosList = [];
  late List videos = [];
  List<Map> selection = [];
  List selectedVideos = [];
  int videoLength = 20;
  bool displayLoadingScreen = true;
  late int videoCount = videoLength;
  CategoryController categoryController = CategoryController();

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
    videos = videosList[index];
  }

  loadVideos(){
    videoCount += videoLength;
    if (videoCount > videos.length) { //ロード過多
      videoCount = videos.length;
      if(displayLoadingScreen){
        displayLoadingScreen = false;
      }
    }
  }
}
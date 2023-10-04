import 'package:video_news/models/video.dart';
import 'package:video_news/controllers/access_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_news/controllers/category_controller.dart';
class VideoController{
  late List<List<Video>> videoLists = [];
  late List<Video> videos = [];
  int videoPages = 20;
  int videoCount = 0;
  CategoryController categoryController = CategoryController();

  updatePresses() async {
    print("アップデート");
    AccessController access = AccessController();
    final prefs = await SharedPreferences.getInstance();
    await access.accessPress();
      if (access.statusCode == 200) {
        await prefs.setString('presses', access.data);
        List press = await categoryController.getPressOrder();
        //videos = press;
      } else {
        throw Exception('Failed to load data');
      }
  }
  setVideos(){

  }
}
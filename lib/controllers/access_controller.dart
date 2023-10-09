import 'package:http/http.dart' as http;
import 'package:video_news/controllers/uuid_controller.dart';
import 'package:video_news/consts/config.dart';
import 'package:video_news/models/favorite.dart';

class AccessController{
  String data = "";
  int statusCode = 400;
  //final domain = 'http://18.178.58.191';
  late final domain = Config.domain;
  UuidController uuidController = UuidController();
  
  accessPress() async {
    String url = '$domain/categories/index.json';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      data = response.body;
      statusCode = 200;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
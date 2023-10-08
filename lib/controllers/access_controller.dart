import 'package:http/http.dart' as http;
class AccessController{
  String data = "";
  int statusCode = 400;
  //final domain = 'http://18.178.58.191';
  final domain = 'http://10.0.2.2:3000';
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
  Future<String> getFavorites() async {
    String url = '$domain/user/favorites.json?uuid=hase';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      data = response.body;
      statusCode = 200;
      print(response.body);
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<String> postFavorite(int id) async {
    String url = "$domain/user/favorites.json?uuid=hase&video_id=$id";
    final response = await http.post(Uri.parse(url));
    if (response.statusCode == 200) {
      data = response.body;
      statusCode = 200;
      print(response.body);
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<String> postMultipleFavorites(List ids) async {
    final queryString = ids.map((id) => 'video_ids[]=$id').join('&');
    print("クエリ");
    print(queryString);
    String url = "$domain/user/favorites/create_multiple.json?uuid=hase&$queryString";
    final response = await http.post(Uri.parse(url));
    if (response.statusCode == 200) {
      data = response.body;
      statusCode = 200;
      print(response.body);
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<String> deleteFavorite(int id) async {
    String url = "$domain/user/favorites/$id.json?uuid=hase";
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode == 200) {
      data = response.body;
      statusCode = 200;
      print(response.body);
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<String> deleteAllFavorites() async {
    String url = "$domain/user/favorites/delete_all.json?uuid=hase";
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode == 200) {
      data = response.body;
      statusCode = 200;
      print(response.body);
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
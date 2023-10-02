import 'package:http/http.dart' as http;
class AccessController{
  String data = "";
  int statusCode = 400;
  accessPress() async {
    //final url = 'http://10.0.2.2:3000/categories/index.json';
    const url = 'http://18.178.58.191/categories/index.json';
    final response = await http.get(Uri.parse(url));if (response.statusCode == 200) {
      data = response.body;
      statusCode = 200;
    } else {
      throw Exception('Failed to load data');
    }
  }
  
  searchWord(){}
}
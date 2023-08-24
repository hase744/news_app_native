import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HttpRequest {
  static Future<String> fetchData(url) async {
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
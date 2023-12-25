import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_news/consts/config.dart';
import 'package:video_news/models/version.dart';
class VersionController{
  Version? version;
  bool isReleased = false;
  late final domain = Config.domain;
  late final versionName = Config.version;

  Future<Version> update() async {
    String url = '$domain/versions.json?name=$versionName';
    Response response = await get(Uri.parse(url));
    Map<String, dynamic> data = await jsonDecode(response.body);
    version = await Version.fromMap(data);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('version', json.encode(version!.toMap()));
    return version!;
  }

  Future<Version> getData() async {
    final prefs = await SharedPreferences.getInstance();
    String? versionString = prefs.getString('version');
    version = versionString == null 
    ? await update() 
    : Version.fromMap(jsonDecode(versionString));
    return version!;
  }

  Future initialize() async {
    version = await getData();
    isReleased = version!.isReleased();
  }
}
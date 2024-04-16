import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:video_news/models/category.dart';
import 'package:video_news/models/channel.dart';
import 'package:video_news/consts/config.dart';
import 'dart:convert';
import 'dart:convert' as convert;

class ChannelController {
  List<Channel> channels = [];

  setChannelsBy(Category category) async {
    String url = '${Config.domain}/user/categories/${category.name}/channels.json';
    var response = await http.get(Uri.parse(url));
    var channelParams = await json.decode(response.body);
    //channels = channelParams.map((c){return Channel.fromJson(c);}).toList();
    for (var channel in channelParams) {
      channels.add(Channel.fromJson(channel));
    }
  }

  Future<bool> searchChannel(String word) async {
    try {
      final url = '${Config.domain}/channels/${word}/search.json';
      final response = await http.get(Uri.parse(url));
      List searchedChannels = json.decode(response.body);
      channels = searchedChannels.map((channel){
        return Channel.fromJson(channel);
      }).toList();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Channel?> create(String url) async {
    String jsonData = jsonEncode(
      {'url': url}
    );
    String requestUrl = "${Config.domain}/channels";
    final response = await http.post(
      Uri.parse(requestUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonData,
    );
    if(response.statusCode == 200 && convert.json.decode(response.body)['is_success']){
      print(convert.json.decode(response.body));
      Channel? channel = Channel.fromJson(convert.json.decode(response.body)['channel']);
      return channel;
    }else{
      return null;
    }
  }

  Future<bool> add(Channel channel) async {
    bool isNew = !(await exist(channel));
    if (isNew) {
      channels.add(channel);
    }
    return isNew;
  }

  Future<bool> exist(Channel channel) async {
    return channels.any((existingChannel) => existingChannel.youtubeId == channel.youtubeId);
  }

  remove(int index) async {
    channels.removeAt(index);
  }
}

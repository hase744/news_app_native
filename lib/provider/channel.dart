import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_news/models/channel.dart';
import 'package:video_news/controllers/channel_controller.dart';
StateProvider<List<Channel>> channelListProvider = StateProvider<List<Channel>>(
  (ref) {
    return [];
  }
);

FutureProvider<List<Channel>> futureChannelProvider = FutureProvider<List<Channel>>(
  (ref) async {
    List<Channel> channel = ref.watch(channelListProvider);
    if(channel.isEmpty){
      var controller = ChannelController();
      return  controller.channels;
    }else{
      return channel;
    }
  }
);

StateProvider<bool> loadingProvider = StateProvider<bool>(
  (ref) {
    return false;
  }
);


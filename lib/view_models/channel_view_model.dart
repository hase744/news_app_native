import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_news/provider/channel.dart';
import 'package:video_news/controllers/channel_controller.dart';
import 'package:video_news/models/channel.dart';
import 'package:video_news/models/common_status.dart';
class ChannelViewModel{
  late WidgetRef _ref;
  final _channelController = ChannelController();
  bool _isLoading = false;

  void setRef(WidgetRef ref){
    this._ref = ref;
  }

  List<Channel> get channels => _ref.watch(channelListProvider);
  bool get isLoading => _ref.watch(loadingProvider);

  setChannels(String id){
    _ref.watch(channelListProvider.notifier).state = [..._channelController.channels];
  }

  Future<bool> onAddChannel(Channel channel) async {
    bool succeed = await _channelController.add(channel);
    _ref.watch(channelListProvider.notifier).state = [..._channelController.channels];
    return succeed;
  }

  Future<bool> existChannel(Channel channel) async {
    return _channelController.exist(channel);
  }

  Future<bool> onSearched(String word) async {
    _ref.watch(channelListProvider.notifier).state = [];
    onLoadStart();
    bool isSuccess = await _channelController.searchChannel(word);
    if(isSuccess){
      _ref.watch(channelListProvider.notifier).state = [..._channelController.channels];
    }
    onLoadEnd();
    return isSuccess;
  }

  Future<CreateStatus> createAndAdd(String url) async {
    Channel? channel = await _channelController.create(url);
    if(await channel == null){
      return CreateStatus.failure;
    }
    if(await _channelController.add(channel!)){
      _ref.watch(channelListProvider.notifier).state = [..._channelController.channels];
      return CreateStatus.success;
    }else{
      return CreateStatus.existing;
    }
  }

  Future<Channel?> onCreated(String url) async {
    Channel? channel = await _channelController.create(url);
    if(channel != null){
      await onAddChannel(channel);
      _ref.watch(channelListProvider.notifier).state = [..._channelController.channels];
    }
  }
  
 
  onLoadStart(){
    _isLoading = true;
    _ref.watch(loadingProvider.notifier).state = _isLoading;
  }

  onLoadEnd(){
    _isLoading = false;
    _ref.watch(loadingProvider.notifier).state = _isLoading;
  }
}
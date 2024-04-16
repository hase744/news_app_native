import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:video_news/consts/config.dart';
import 'package:video_news/models/channel.dart';
import 'package:video_news/models/channel_mode.dart';
import 'package:video_news/models/common_status.dart';
import 'package:video_news/controllers/uuid_controller.dart';
import 'package:video_news/controllers/interstitial_add_controller.dart';
import 'package:video_news/view_models/channel_view_model.dart';
import 'package:video_news/view_models/alert_view_model.dart';
import 'package:video_news/views/channels/channel_cell.dart';
import 'package:video_news/views/alert.dart';
import 'package:video_news/views/shared/common_methods.dart';
import 'dart:io';

class ChannelSearch extends ConsumerStatefulWidget {
  double width;
  double height;
  Function(Channel) onAdded;
  Future<bool> Function(Channel) onChecked;
  VoidCallback onClosed;
   
  ChannelSearch({
    required this.width,
    required this.height,
    required this.onAdded,
    required this.onClosed,
    required this.onChecked
  });
  @override
  ConsumerState<ChannelSearch> createState() => _ChannelSearch();
}

class _ChannelSearch extends ConsumerState<ChannelSearch> {
  UuidController _uuidController = UuidController();
  final TextEditingController _controller = TextEditingController();
  InterstitialAdController _interstitialAdController = new InterstitialAdController();
  ChannelViewModel _channelViewModel = ChannelViewModel();
  AlertViewModel _alertViewModel = AlertViewModel();
  ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
     _channelViewModel.setRef(ref);
     _alertViewModel.setRef(ref);
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      child: 
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: 
            TextField(
              autofocus: true,
              controller: _controller,
              cursorColor: Colors.grey,
              decoration: InputDecoration(
                hintText: 'チャンネル名を検索',
                prefixIcon: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: widget.onClosed
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                  },
                ),       
                enabledBorder: const UnderlineInputBorder(      
                  borderSide: BorderSide(color: Colors.grey),   
                  ),  
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),  
              ),
              onSubmitted: (text) async {
                if(!await _channelViewModel.onSearched(text)){
                  _alertViewModel.display('検索に失敗しました');
                };
              },
            ),
          ),
          Expanded(
            child: 
            Stack(
              children: [
                ListView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  children: [
                  for(var channel in _channelViewModel.channels)
                    ChannelCell(
                      mode: ChannelMode.search,
                      channel: channel,
                      width: widget.width,
                      onRemoved: (){},
                      onSelected: (){
                        showDialog(
                          context: context,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              title: Text("チャンネルを追加しますか？"),
                              //content: Text("メッセージ内容"),
                              actions: [
                                CupertinoDialogAction(
                                  child: Text('追加'),
                                  isDestructiveAction: true,
                                  onPressed: () async {
                                    showProgressDialog(context);
                                    if(await widget.onChecked(channel)){
                                      _alertViewModel.display("すでに追加されています");
                                    }else{
                                      CreateStatus status = await widget.onAdded(channel);
                                      _alertViewModel.displayFromStatus(status);
                                    };
                                    Navigator.pop(context);
                                    Navigator.of(context, rootNavigator: true).pop();
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: Text('キャンセル'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            );
                          }
                        );
                      },
                    ),
                    if(_channelViewModel.isLoading)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child:
                      Container(
                        alignment: Alignment.center,
                        width: widget.width,
                        child: 
                        const SizedBox(
                          height: 50,
                          width: 50,
                          child: 
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)
                          ),
                        ),
                      )
                    ),
                  ]
                ),
                if(_alertViewModel.alert != null)
                Alert(
                  text: _alertViewModel.alert!,
                  width:  widget.width,
                  height: widget.width/20,
                ),
              ],
            )
          )
        ],
      ),
    );
  }
}
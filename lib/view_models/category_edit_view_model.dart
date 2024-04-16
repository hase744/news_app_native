import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:video_news/provider/category.dart';
import 'package:video_news/controllers/category_controller.dart';
import 'package:video_news/controllers/video_controller.dart';
import 'package:video_news/controllers/channel_controller.dart';
import 'package:video_news/provider/channel.dart';
import 'package:video_news/models/category.dart';
import 'package:video_news/models/channel.dart';
import 'package:video_news/models/common_status.dart';
import 'package:video_news/views/shared/common_methods.dart';
import 'package:video_news/views/setting_page.dart';
import 'package:video_news/views/downloader/text_editing_dialog.dart';

import 'package:video_news/view_models/shared_view_model.dart';
class CategoryEditViewModel{
  late WidgetRef _ref;
  CategoryController _categoryController = CategoryController();
  ScrollController _scrollController = ScrollController();
  VideoController _videoController = VideoController();
  final _controller = WebViewController()
    ..loadRequest(Uri.parse('https://www.youtube.com'))
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          print(progress);
          // Update loading bar.
        },
        onPageStarted: (String url) {
          print("スタート");
        },
        onPageFinished: (String url) {
          print(url);
        },
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          //if (request.url.startsWith('https://www.youtube.com/')) {
          //  return NavigationDecision.prevent;
          //}
          print(request);
          return NavigationDecision.navigate;
        },
        
      ),
    );
  Category? _category = null;
  final formKey = GlobalKey<FormState>();
  final _channelController = ChannelController();

  setRef(WidgetRef ref) async {
    this._ref = ref;
  }
  List<Channel> get channels => _ref.watch(channelListProvider);
  Category? get category => _ref.watch(categoryProvider);
  
  saveChannel(BuildContext context, String emoji ,japaneseName) async {
    CategoryController controller = CategoryController();
    showProgressDialog(context);
    _category = _category!.copyWith(
      japaneseName: japaneseName,
      emoji: emoji,
      imageUrl: category?.imageUrl
    );
    if (!formKey.currentState!.validate()) { 
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    if(_channelController.channels.isEmpty){
      displayMessage(context, "チャンネルを追加してください");
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    await controller.create(
      _channelController.channels,
      _category!
    );
    await controller.addFromCategory(_category!);
    _videoController.updatePress(0);
    Navigator.of(context, rootNavigator: true).pop();
   await displayMessage(context, "保存しました");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingPage()
      )
    );
  }

  japaneseNameValidator(String? value){
    if(value == null || value.isEmpty){
      return '名前を入力してください';
    }
    if(value.length > 10){
      return '10字以下で入力してください';
    }
    return null;
  }

  onBackPushed(bool didPop, BuildContext context) async {
    return await showBackDialog(context);
  }

  setDefaultCategory(Category? category){
    _category = category ?? const Category(
      name: '', 
      japaneseName: '', 
      emoji: '', 
      isDefault: false, 
      isFormal: true, 
      isOriginal: true,
      imageUrl: null,
    );
    _ref.watch(categoryProvider.notifier).state = category;
  }

  Future<CreateStatus> createAndAdd(String url) async {
    Channel? channel = await _channelController.create(url);
    if(await channel == null){
      return CreateStatus.failure;
    }
    if(await _channelController.add(channel!)){
      _ref.watch(channelListProvider.notifier).state = [..._channelController.channels];
      if([null, ''].contains(category?.imageUrl)){
        changeCategoryImage(channel.imageUrl);
      }
      return CreateStatus.success;
    }else{
      return CreateStatus.existing;
    }
  }

  changeCategoryImage(String imageUrl){
    _ref.watch(categoryProvider.notifier).state = _category!.copyWith(imageUrl: imageUrl);
  }
  
  onRemoved(Channel channel) async {
    int index = _channelController.channels.indexWhere((element) => element.youtubeId == channel.youtubeId);
    await _channelController.remove(index);
    _ref.watch(channelListProvider.notifier).state = [..._channelController.channels];
  }

  Future setOriginalChannels(Category? category) async {
    if (category == null){
      return;
    }

    await _channelController.setChannelsBy(category);
    _ref.watch(channelListProvider.notifier).state = [..._channelController.channels];
  }

  displayMessage(BuildContext context, String text){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  displayMessageFrom(BuildContext context, CreateStatus status){
    displayMessageFromStatus(context, status);
  }

  Future<bool> existChannel(Channel channel) async {
    return _channelController.exist(channel);
  }

  addChannelFrom(BuildContext context, String url) async {
    showProgressDialog(context);
    CreateStatus status = await createAndAdd(url);
    Navigator.of(context, rootNavigator: true).pop();
    displayMessageFrom(context, status);
    Navigator.of(context).pop();
  }

  showDeleteDialog(BuildContext context, Channel channel){
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("チャンネルを削除しますか？"),
          actions: [
            CupertinoDialogAction(
              child: Text('削除'),
              isDestructiveAction: true,
              onPressed: (){
                onRemoved(channel);
                Navigator.pop(context);
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
  }

  Future<bool> showBackDialog(BuildContext context) async {
    bool back = false;
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("保存せずに戻りますか？"),
          actions: [
            CupertinoDialogAction(
              child: Text('はい'),
              isDestructiveAction: true,
              onPressed: (){
                back = true;
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: Text('キャンセル'),
              onPressed: (){
                back = true;
                Navigator.pop(context);
              },
            ),
          ],
        );
      }
    );
    return back;
  }

  Future<String?> openBrowser(
    BuildContext context,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return TextEditingDialog(
          title: "チャンネルを検索",
          name: '' ,
          onEntered: (string) async {
            Navigator.of(context).pop();
             _controller
            .loadRequest(Uri.parse('https://www.youtube.com/results?search_query=${string}&sp=EgIQAg%253D%253D'));
            showDialog(
              context: context,
              //isScrollControlled: true,
              builder: (BuildContext context) {
              return 
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height*0.8,
                    child: 
                    Scaffold(
                      body: 
                      Container(
                        height: MediaQuery.of(context).size.height*0.8,
                        child: WebViewWidget(
                          controller: _controller,
                        ),
                      ),
                      floatingActionButton: 
                        FloatingActionButton.extended(
                          label: Text('チャンネルを追加'),
                          onPressed: () async {
                            String? url = await _controller.currentUrl();
                            url = getBaseUrl(url!);
                            if(url.contains('www.youtube.com/@') || url.contains('m.youtube.com/@')){
                              url = url.replaceAll('m.youtube.com/@', 'www.youtube.com/@');
                              addChannelFrom(context, url);
                            }else{
                              var message = 'チャンネルを選択してください';
                              displayMessage(context, message);
                            }
                          },
                          icon: new Icon(Icons.add),
                        )
                      )
                    )
                  ]
                );
              },
            );
          },
        );
      },
    );
   }

  String getBaseUrl(String url) {
    Uri uri = Uri.parse(url);
    String baseUrl = "${uri.scheme}://${uri.host}/${uri.pathSegments.first}";
    return baseUrl;
  }
  
  void showImageDialog(BuildContext context, double width) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('選択可能な画像'),
          content: SingleChildScrollView(
            child: 
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child:
                Row(
                children:[
                  for(var channel in channels)
                  InkWell(
                    onTap: (){
                      changeCategoryImage(channel.imageUrl);
                    },
                    child:
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(horizontal: width/10),
                      width: width,
                      height: width,
                      child: 
                      ClipRRect(
                        borderRadius: BorderRadius.circular(width),
                        child:
                        Image.network(channel.imageUrl)
                      )
                    ),
                  )
                ]
              )
            ),
          ),
        );
      },
    );
  }
}
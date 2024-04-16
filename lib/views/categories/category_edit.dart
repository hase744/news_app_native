import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_news/controllers/version_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_news/views/downloader/text_editing_dialog.dart';
import 'package:video_news/view_models/category_edit_view_model.dart';
import 'package:video_news/views/channels/channel_cell.dart';
import 'package:video_news/models/channel_mode.dart';
import 'package:video_news/models/category.dart';
import 'package:video_news/views/channels/channel_search.dart';

class CategoryEditPage extends ConsumerStatefulWidget {
  final Category? category;
  const CategoryEditPage({
    required this.category,
    super.key,
  });
  @override
  ConsumerState<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends ConsumerState<CategoryEditPage> {
  VersionController _versionController = VersionController();
  ScrollController _scrollController = ScrollController();
  CategoryEditViewModel _viewModel = CategoryEditViewModel();
  TextEditingController _emojiEditingController = TextEditingController(text: "👤");
  TextEditingController _japaneseNameEditingController = TextEditingController(text: '');
  @override
  void initState() {
    super.initState();
    //_channelViewModel.setRef(ref);
    _versionController.initialize();
    _emojiEditingController = TextEditingController(text: widget.category?.emoji ?? '👤');
    _japaneseNameEditingController = TextEditingController(text: widget.category?.japaneseName ?? '');
    init();
  }

  init() async {
    await _viewModel.setRef(ref);
    await _viewModel.setDefaultCategory(widget.category);
    _viewModel.setOriginalChannels(widget.category);
  }

  Future<String?> addChannelDialog(
    BuildContext context,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return TextEditingDialog(
          title: "チャンネルのurl",
          name: '',
          onEntered: (url) async {
            _viewModel.addChannelFrom(context, url);
          },
        );
      },
    );
   }


  @override
  Widget build(BuildContext context) {
    double _deviceWidth = MediaQuery.of(context).size.width;
    double _deviceHeight = MediaQuery.of(context).size.height;
    return 
    PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        return _viewModel.onBackPushed(didPop, context);
      },
      child:
      Scaffold(
        appBar: 
        AppBar(
          elevation: 0,
          backgroundColor: const Color.fromRGBO(255,251,255, 1),
          title: Text(widget.category?.japaneseName ?? '', style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              child: Text(
                "保存",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: _deviceWidth/20
                ),
              ),
              onPressed: () async {
                _viewModel.saveChannel(
                  context, 
                  _emojiEditingController.text, 
                  _japaneseNameEditingController.text
                );
              }, 
            )
          ],
        ),
        body: 
        Center(
          child:
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(_deviceWidth/30),
                child:
                Form(
                  key : _viewModel.formKey,
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: _deviceWidth/20,
                      ),
                      Container(
                        alignment: Alignment.centerLeft, //任意のプロパティ
                        width: double.infinity,
                        child: Text('カテゴリー名')
                      ),
                      TextFormField(
                        autofocus: true,
                        controller: _japaneseNameEditingController,
                        cursorColor: Colors.grey,
                        decoration: const InputDecoration(
                          hintText: 'カテゴリー名',
                          enabledBorder: UnderlineInputBorder(      
                            borderSide: BorderSide(color: Colors.grey),   
                            ),  
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),  
                        ),
                        validator: (value)=> _viewModel.japaneseNameValidator(value)
                      ),
                      SizedBox(
                        height: _deviceWidth/20,
                      ),
                      if(![null, ''].contains(_viewModel.category?.imageUrl))
                      Container(
                        alignment: Alignment.centerLeft, //任意のプロパティ
                        width: double.infinity,
                        child: Text('アイコン')
                      ),
                      if(![null, ''].contains(_viewModel.category?.imageUrl))
                      InkWell(
                        onTap: () => _viewModel.showImageDialog(context,_deviceWidth*3/20),
                        child: 
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.symmetric(horizontal: _deviceWidth/20),
                          width: _deviceWidth*3/20,
                          height: _deviceWidth*3/20,
                          child: 
                          ClipRRect(
                            borderRadius: BorderRadius.circular(_deviceWidth),
                            child:
                            Image.network(_viewModel.category!.imageUrl!)
                          )
                        ),
                      ),
                      SizedBox(
                        height: _deviceWidth/20,
                      ),
                      Container(
                        alignment: Alignment.centerLeft, //任意のプロパティ
                        width: double.infinity,
                        child: Text('チャンネル一覧')
                      ),
                    ]
                  )
                )
              ),
              Expanded(
                child: 
                Stack(
                  children: [
                    ListView(
                      controller: _scrollController,
                      physics: const ClampingScrollPhysics(),
                      children: [
                      if(_viewModel.channels.length == 0)
                        const Text(
                          "＋ボタンからチャンネルを追加してください",
                          style: TextStyle(
                            color: Colors.grey
                          ),
                        ),
                      for(var channel in _viewModel.channels)
                        ChannelCell(
                          mode: ChannelMode.select,
                          channel: channel,
                          width: _deviceWidth,
                          onRemoved: () => _viewModel.showDeleteDialog(context, channel),
                          onSelected: (){},
                        ),
                        SizedBox(//スクロールした時にfloatingActionButtonとチャンネルがかぶるため
                          width: _deviceWidth,
                          height: _deviceWidth/20*6,
                        )
                      ],
                    ),
                  ],
                ),
              )
            ]
          )
        ),
        floatingActionButton: 
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              heroTag: "hero1",
              onPressed: () {
                showModalBottomSheet(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    ),
                  isScrollControlled: true,
                  isDismissible: true,
                  context: context, 
                  builder: (context) => 
                  ProviderScope(
                    child:
                    ChannelSearch(
                      height: _deviceHeight*0.8,
                      width: _deviceWidth,
                      onClosed:() => Navigator.of(context).pop(),
                      onAdded: (channel) async {
                        String url = 'https://www.youtube.com/channel/${channel.youtubeId}';
                        return _viewModel.createAndAdd(url);
                      },
                      onChecked: (channel) async {
                        return await _viewModel.existChannel(channel);
                      },
                    )
                  )
                );
              },
              label: const Text('チャンネルを検索'),
              icon: const Icon(Icons.add),
            ),
            FloatingActionButton.extended(
              heroTag: "hero2",
              onPressed: () {
                addChannelDialog(context);
              },
              label: const Text('urlからチャンネルを追加'),
              icon: const Icon(Icons.add),
            ),
            FloatingActionButton.extended(
              heroTag: "hero3",
              onPressed: () {
                _viewModel.openBrowser(context);
              },
              label: const Text('サイトから検索'),
              icon: const Icon(Icons.add),
            ),
          ]
        )
      )
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:video_news/consts/config.dart';
import 'package:video_news/models/video.dart';
import 'package:video_news/controllers/uuid_controller.dart';
import 'package:video_news/controllers/interstitial_add_controller.dart';
class Summary {
  String? order;
  String? answer;
  bool isSuccess;

  Summary({
    required this.order,
    required this.answer,
    required this.isSuccess
  });

  Summary.fromMap(Map<String, dynamic> map)
    :order = map['order'],
    isSuccess = map['is_success'],
    answer = map['answer'];
}
class SummarizerPage extends StatefulWidget {
  double width;
  double height;
  VideoForm video;
  VoidCallback onClosed;
   
  SummarizerPage({
    required this.width,
    required this.height,
    required this.video,
    required this.onClosed
  });
  @override
  State<SummarizerPage> createState() => _SummarizerPage();
}

class _SummarizerPage extends State<SummarizerPage> {
  UuidController _uuidController = UuidController();
  final TextEditingController _controller = TextEditingController(text: "内容を要約して");
  InterstitialAddController _interstitialAddController = new InterstitialAddController();
  bool _isLoading = false;
  List _summaries = [];
  int _summaryIndex = 0;
  bool get isMaxSummary => _summaryIndex+1 >= _summaries.length;
  bool get isMiniSummary => _summaryIndex <= 0;
  
  @override
  void initState() {
    super.initState();
    getSummaries();
    setState(() {
      _interstitialAddController.createAd();
      //ロード前に要約ボタンが押されたら、広告が表示されないため、その時はロードが完了した時に広告を表示
      _interstitialAddController.onAdLoadedCallback = (){
        if(_interstitialAddController.canShowAd && _isLoading){
          _interstitialAddController.showAd();
        }
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height * 0.8,
      width: widget.width,
      child: 
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
        child: 
        Column(
          children: [  
            Container(
              height: widget.width/10,
              child: 
              Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child:
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
                      child: 
                      Icon(
                        Icons.summarize,
                        size: widget.width/20,
                        color: Colors.black87
                      ),
                    )
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child:
                    Text(
                      'AIの内容要約',
                      style: TextStyle(
                        fontSize: widget.width/20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87
                      ),
                    )
                  ),
                  const Expanded(child: SizedBox()),
                  Align(
                    alignment: Alignment.centerRight,
                    child:
                    IconButton(
                      onPressed: widget.onClosed,
                      icon: Icon(
                        Icons.clear,
                        size: widget.width/15,
                        ),
                    ),
                  )
                ]
              )
            ),
            Container(
              height: widget.height * 0.7,
              child: 
              SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                physics: ClampingScrollPhysics(),
                child:
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: 
                      Text(
                        widget.video.title,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: widget.width/25,
                        ),
                      )
                    ), 
                    TextField(
                      //focusNode: _focusUserId,
                      style: TextStyle(
                        fontSize: widget.width/20,
                      ),
                      controller: _controller,
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                        labelText: '入力プロンプト',
                        labelStyle: TextStyle(
                          color: Colors.black54,
                          fontSize: widget.width/30,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(
                              color: Colors.blue,
                          ),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),  
                        suffixIcon: IconButton(
                          onPressed: () => createSummary(_controller.text),
                          icon: Icon(
                            color: _isLoading? Colors.grey: Colors.black87,
                            Icons.publish,
                            size: widget.width/10,
                          ),
                        ),
                      ),
                      onSubmitted: (String? value) => createSummary(value!),
                    ),
                    if(_isLoading)
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
                    if(_summaries.isNotEmpty && !_isLoading)
                    Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child:
                          Text(
                            _summaries[_summaryIndex].order,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: widget.width/20,
                              ),
                          )
                        ),
                        SizedBox(
                          height: widget.width/20,
                          child:
                          Row(
                            children: [
                              IconButton(
                                color: isMiniSummary? Colors.grey : Colors.black54,
                                padding: EdgeInsets.zero, 
                                iconSize: widget.width/20,
                                onPressed: (){
                                  if(!isMiniSummary){
                                    setState(() {
                                      _summaryIndex-=1;
                                    });
                                  }
                                }, 
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                )
                              ),
                              Text(
                                "${_summaryIndex+1}/${_summaries.length}",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: widget.width/20,
                                ),
                              ),
                              IconButton(
                                color: isMaxSummary? Colors.grey : Colors.black54,
                                padding: EdgeInsets.zero, 
                                iconSize: widget.width/20,
                                onPressed: (){
                                  if(!isMaxSummary){
                                    setState(() {
                                      _summaryIndex+=1;
                                    });
                                  }
                                }, 
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  size: widget.width/20,
                                )
                              )
                            ],
                          ) ,
                        ),
                        if(!_summaries[_summaryIndex].isSuccess)
                        Container(
                          alignment: Alignment.centerLeft,
                          child:
                          Text(
                            "エラー",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: widget.width/20,
                            ),
                          )
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child:
                          RichText(
                            text: TextSpan(
                              children: getHighLightedText(_summaries[_summaryIndex].answer),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: widget.width/10,
                          width: widget.width,
                        )
                      ],
                    )
                  ]
                )
              )
            )
          ]
        ),
      ),
    );
  }
  
  void getSummaries() async {
    setState(() {
      _isLoading = true;
    });
    final url = '${Config.domain}/user/summaries.json';

    Map<String, dynamic> parameters = {
      'uuid': await _uuidController.getUuid(),
      'youtube_id': widget.video.youtubeId,
    };

    String queryString = Uri(queryParameters: parameters).query;
    String requestUrl = '$url?$queryString';
    
    final response = await http.get(Uri.parse(requestUrl));

    setState(() {
      _isLoading = false;
      if (response.statusCode == 200) {
        Map summaries = json.decode(response.body);
        for(var summary in summaries['summaries']){
          _summaries.add(Summary.fromMap(summary));
        }
      }else{
        _summaries.add(Summary(
          order: '',
          isSuccess: false,
          answer: ''
        ));
      }
      _summaryIndex = _summaries.length-1;
    });
  }

  void createSummary(String value) async {
    if(_isLoading){
      return;
    }
    setState(() {
      _isLoading = true;
      FocusScope.of(context).unfocus();
      _interstitialAddController.showAd();
    });
    final url = '${Config.domain}/user/summaries.json';

    Map<String, dynamic> data = {
      'summary': {
        'uuid': await _uuidController.getUuid(),
        'youtube_id': widget.video.youtubeId,
        'order': value,
      }
    };

    String jsonData = jsonEncode(data);

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonData,
    );
    setState(() {
      _isLoading = false;
      var jsonParam = json.decode(response.body);
      _summaries.add(
        Summary.fromMap(jsonParam)
      );
      _summaryIndex = _summaries.length -1;
      _interstitialAddController.showCount = 0;
    });
  }

  List<TextSpan> getHighLightedText(String? text){
    text ??= '';
    List<TextSpan> spans = [];
    List<String> parts = text.split('**');
    for (int i = 0; i < parts.length; i++) {
      spans.add(
        TextSpan(
          text: parts[i].replaceAll('* ', '・'),
          style: 
          i % 2 == 0 ?
          TextStyle(
            color: Colors.black, 
            fontSize: widget.width/20
          ):
          TextStyle(
            color: Colors.black, 
            fontSize: widget.width/20,
            fontWeight: FontWeight.bold
          ),
        ),
      ); 
    }
    return spans;
  }
}

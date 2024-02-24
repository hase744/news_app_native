import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:video_news/consts/config.dart';
import 'package:video_news/models/video.dart';
import 'package:video_news/controllers/uuid_controller.dart';
class SummarizerPage extends StatefulWidget {
  double width;
  double height;
  VideoForm video;
   
  SummarizerPage({
    required this.width,
    required this.height,
    required this.video
  });
  @override
  State<SummarizerPage> createState() => _SummarizerPage();
}

class _SummarizerPage extends State<SummarizerPage> {
  UuidController uuidController = UuidController();
  final TextEditingController _controller = TextEditingController(text: "内容を要約して");
  bool _isLoading = false;
  List _summaries = [];
  int _summaryIndex = 0;
  bool get isMaxSummary => _summaryIndex+1 >= _summaries.length;
  bool get isMiniSummary => _summaryIndex <= 0;

  
  @override
  void initState() {
    super.initState();
    getSummaries();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height * 0.8,
      child: 
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: 
        SingleChildScrollView(
          child:
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: 
                Text(
                  'AIで要約を生成',
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
              TextField(
                  //focusNode: _focusUserId,
                  controller: _controller,
                  cursorColor: Colors.blue,
                  decoration: InputDecoration(
                    labelText: '入力プロンプト',
                    labelStyle: const TextStyle(
                      color: Colors.grey
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
                        Icons.arrow_circle_up,
                        size: widget.width/10,
                        ),
                    ),
                  ),
                  onSubmitted: (String? value) => createSummary(value!),
                ),
              //Align(
              //  alignment: Alignment.centerRight,
              //  child: 
              //  OutlinedButton(
              //    style: OutlinedButton.styleFrom(
              //      backgroundColor: Colors.white,
              //      shape: RoundedRectangleBorder(
              //        borderRadius: BorderRadius.circular(10),
              //      ),
              //      side: const BorderSide(
              //        color: Colors.blue
              //      ),
              //    ),
              //    onPressed: () {
              //      createSummary();
              //    },
              //    child: const Text(
              //      '生成',
              //      style: TextStyle(
              //        color: Colors.grey
              //      ),
              //      ),
              //  ),
              //),
              if(_isLoading)
              Padding(
                padding: EdgeInsets.all(20.0),
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
              if(_summaries.length > 0 && !_isLoading)
              Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child:
                    Text(
                      _summaries[_summaryIndex]['order'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: widget.width/15
                        ),
                    )
                  ),
                  Container(
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
                        icon: Icon(
                          Icons.arrow_back_ios,
                          )
                        ),
                      Text(
                        "${_summaryIndex+1}/${_summaries.length}",
                        style: TextStyle(
                          color: Colors.black54,
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
                  Container(
                    alignment: Alignment.centerLeft,
                    child:
                    RichText(
                      text: TextSpan(
                        children: getHighLightedText(_summaries[_summaryIndex]['answer']),
                      ),
                    ),
                  ),
                ],
              )
            ],
          )
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
        'uuid': await uuidController.getUuid(),
        'youtube_id': widget.video.youtubeId,
    };

    String queryString = Uri(queryParameters: parameters).query;
    String requestUrl = '$url?$queryString';
    
    final response = await http.get(Uri.parse(requestUrl));

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
        Map summaries = json.decode(response.body);
        _summaries = summaries['summaries'];
        _summaryIndex = _summaries.length-1;
      });
    }
  }

  void createSummary(String value) async {
      setState(() {
        _isLoading = true;
      });
    final url = '${Config.domain}/user/summaries.json';

    Map<String, dynamic> data = {
      'summary': {
        'uuid': await uuidController.getUuid(),
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

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
        var answer = json.decode(response.body)['summary'];
        _summaries.add({
          'order': _controller.text,
          'answer': answer
        });
        _summaryIndex = _summaries.length -1;
      });
    }
  }

  List<TextSpan> getHighLightedText(String? text){
    text = text == null ? '' : text;
    List<TextSpan> children = [];
    List<String> parts = text.replaceAll('* ', '・').split('**');
    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        children.add(
          TextSpan(
            text: parts[i],
            style: TextStyle(
              color: Colors.black, 
              fontSize: widget.width/20),
          ),
        ); 
      } else {
        children.add(
          TextSpan(
            text: parts[i],
            style: TextStyle(
              color: Colors.black, fontSize: widget.width/20,
              fontWeight: FontWeight.bold
              ),
          ),
        ); 
      }
    }
    return children;
  }
}

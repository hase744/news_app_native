class Press{
  String youtubeId = '';
  String title = '';
  String channelName = '';
  String channelId = '';
  String createdAt = '';
  //int second = 0;
  init(){}

  Map<String, dynamic> toMap() {
    return {
      'youtube_id': youtubeId,
      'title': title,
      'channel_name': channelName,
      'channel_id': channelId,
      'created_at': createdAt,
    };
  }

  setValue(Map<String, dynamic> press){
      youtubeId = press['youtube_id'];
      title = press['title'];
      channelId = press['channel_id'];
    }
}
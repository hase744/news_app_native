class Video{
  String id;
  String youtubeId;
  String title;
  String channelName;
  String channelId;
  int totalSeconds;
  DateTime publishedAt;
  //int second = 0;
  
  Video({
    required this.id,
    required this.youtubeId,
    required this.title,
    required this.channelName,
    required this.channelId,
    required this.totalSeconds,
    required this.publishedAt,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'channel_name': channelName,
      'channel_id': channelId,
      'published_at': publishedAt,
    };
  }

  setValue(Map<String, dynamic> press){
      id = press['id'];
      title = press['title'];
      channelId = press['channel_id'];
    }
}
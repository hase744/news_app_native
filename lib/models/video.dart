class Video{
  int id;
  String youtubeId;
  String title;
  String channelName;
  int channelId;
  int totalSeconds;
  String publishedAt;
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

  Video.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        youtubeId = json['youtube_id'],
        title = json['title'],
        channelName = json['channel_name'],
        channelId = json['channel_id'],
        totalSeconds = json['total_seconds'],
        publishedAt = json['published_at']
        ;
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'youtube_id': youtubeId,
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
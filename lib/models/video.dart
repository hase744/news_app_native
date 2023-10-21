class Video{
  int id;
  String youtubeId;
  String title;
  String channelName;
  int channelId;
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

  Video.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        youtubeId = json['youtube_id'],
        title = json['title'],
        channelName = json['channel_name'],
        channelId = json['channel_id'],
        totalSeconds = json['total_seconds'],
        publishedAt = DateTime.parse(json['published_at'])
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
  
  getReadableDuration(){
    final Duration duration = Duration(seconds: totalSeconds);
    String formattedDuration = '';
    if (duration.inHours > 0) {
      formattedDuration += '${duration.inHours.toString().padLeft(2, '0')}:';
    }
    formattedDuration += '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:';
    formattedDuration += '${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    return formattedDuration;
  }

  getFromNow(){
    Duration difference = DateTime.now().difference(publishedAt);
    if(difference.inDays < 1){
      return "${difference.inHours}時間前";
    }else{
      return "${difference.inDays}日前";
    }
  }
}
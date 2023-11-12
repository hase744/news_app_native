class Video{
  int id;
  String youtubeId;
  String title;
  String channelName;
  int channelId;
  int totalSeconds;
  DateTime publishedAt;
  
  Video({
    required this.id,
    required this.youtubeId,
    required this.title,
    required this.channelName,
    required this.channelId,
    required this.totalSeconds,
    required this.publishedAt,
  });

  Video.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        youtubeId = map['youtube_id'],
        title = map['title'],
        channelName = map['channel_name'],
        channelId = map['channel_id'],
        totalSeconds = map['total_seconds'],
        publishedAt = DateTime.parse(map['published_at'])
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
    formattedDuration += (duration.inSeconds % 60).toString().padLeft(2, '0');
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
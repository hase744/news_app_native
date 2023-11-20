import 'dart:io';
class Version{
  String name;
  bool iosReleased;
  bool androidReleased;

  Version({
    required this.name,
    required this.iosReleased,
    required this.androidReleased,
  });

  Version.fromMap(Map<String, dynamic> map)
      : name = map['name'],
        iosReleased = map['ios_released'],
        androidReleased = map['android_released']
        ;
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ios_released': iosReleased,
      'android_released': androidReleased,
    };
  }

  isReleased(){
    if(Platform.isIOS){
      return iosReleased;
    }
    if(Platform.isAndroid){
      return androidReleased;
    }
  }
}
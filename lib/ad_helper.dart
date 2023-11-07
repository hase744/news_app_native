import 'dart:io';

class AdHelper {

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-8457001237911326/9672142788';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-8457001237911326/7388798217';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }
}
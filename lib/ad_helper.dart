import 'dart:io';

class AdHelper {
  static bool isRelease = const bool.fromEnvironment('dart.vm.product');
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return isRelease ? 'ca-app-pub-8457001237911326/9672142788' : 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return isRelease ? 'ca-app-pub-8457001237911326/7388798217' : 'ca-app-pub-3940256099942544/6300978111';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }
}
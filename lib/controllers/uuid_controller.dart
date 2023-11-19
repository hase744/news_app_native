import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_id/android_id.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
class UuidController{
    getDeviceUniqueId() async {
    var deviceIdentifier = 'unknown';
    var deviceInfo = DeviceInfoPlugin();
    final TrackingStatus status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if(status == TrackingStatus.authorized  && 
    await AppTrackingTransparency.getAdvertisingIdentifier() != "00000000-0000-0000-0000-000000000000"){
      deviceIdentifier = await AppTrackingTransparency.getAdvertisingIdentifier();
    }else if (Platform.isAndroid) {
      const androidId = AndroidId();
      String? deviceId = await androidId.getId();
      deviceIdentifier = deviceId!;
    } else if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      deviceIdentifier = iosInfo.identifierForVendor ?? 'unknown';
    } else if (Platform.isLinux) {
      var linuxInfo = await deviceInfo.linuxInfo;
      deviceIdentifier = linuxInfo.machineId ?? 'unknown';
    } else if (kIsWeb) {
      var webInfo = await deviceInfo.webBrowserInfo;
      deviceIdentifier = webInfo.vendor! +
          webInfo.userAgent! +
          webInfo.hardwareConcurrency.toString();
    }

    return deviceIdentifier;
  }

  getUuid() async {
    final prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString('default_uuid');
    if(uuid == null){
      await prefs.setString('default_uuid', await getDeviceUniqueId());
      uuid = prefs.getString('default_uuid');
    }
    return uuid!;
  }
}
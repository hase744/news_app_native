import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/services.dart';

class AttO {

  // クラス外からアクセスできるように static でインスタンスを作成
  static final AttO attInstanceO = AttO();

  // ユーザー同意ダイアログを表示して、同意されればIDFAを取得するメソッド
  Future requestPermissionO() async {

    // OSがiOSのときのみ実行
    if (Platform.isIOS) {

      // ユーザーが回答済か否か（つまり初回起動か否か）の状態を取得
      TrackingStatus trackingStatusO =
      await AppTrackingTransparency.trackingAuthorizationStatus;
      print("trackingStatusO:$trackingStatusO");

      try {

        // ユーザーが未回答の場合だけ（＝初回起動の場合だけ）、以下の処理を実行
        if (trackingStatusO == TrackingStatus.notDetermined) {

          // 事前説明のダイアログを出したい場合は、この部分にshowDialogメソッド等を入れて
          // 追加のダイアログ表示の処理を書く
          // 【注】他のユーザー同意ダイアログ（通知許可など）の後に、ATTの同意ダイアログを出す場合は、
          //    この事前説明ダイアログ入れたほうが良い（後述）
          // showDialog(context: context, ・・・・

          // ユーザー同意ダイアログを表示して、回答（同意・不同意）の結果を取得
          var statusO =
          await AppTrackingTransparency.requestTrackingAuthorization();
          print("requestTrackingAuthorization:$statusO");
        }

      // エラー時の処理
      } on PlatformException {
        print('PlatformException was thrown');
      }
    }

    // IDFAを取得
    // ユーザー不同意の場合は「00000000-0000-0000-0000-000000000000」になる
    final uuidO = await AppTrackingTransparency.getAdvertisingIdentifier();
    print('IDFA:$uuidO');
  }
}
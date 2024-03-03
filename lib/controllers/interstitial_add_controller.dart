import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_news/helpers/ad_helper.dart';
import 'package:flutter/material.dart';

class InterstitialAddController {
  InterstitialAd? _interstitialAd;
  int num_of_attempt_load = 0;
  int showCount = 0;
  bool ready = true;
  VoidCallback? onAdLoadedCallback;
  VoidCallback? onAdClosedCallback;
  bool get canShowAd => (showCount < 1 && ready);

  void createAd() {
    print("作成");
    InterstitialAd.load(
      adUnitId: AdHelper.intersitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        // 広告が正常にロードされたときに呼ばれます。
        onAdLoaded: (InterstitialAd ad) {
          print('add loaded');
          _interstitialAd = ad;
          num_of_attempt_load = 0;
          ready = true;
          onAdLoadedCallback!();
        },
        // 広告のロードが失敗した際に呼ばれます。
        onAdFailedToLoad: (LoadAdError error) {
          print("失敗");
          print(error);
          num_of_attempt_load++;
          _interstitialAd = null;
          if (num_of_attempt_load <= 2) {
            createAd();
          }
        },
      ),
    );
    print("作成後");
  }

  // show interstitial ads to user
  Future<void> showAd() async {
    ready = false;
    showCount ++;
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        print("ad onAdshowedFullscreen");
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print("ad Disposed");
        ad.dispose();
        createAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError aderror) {
        print('$ad OnAdFailed $aderror');
        ad.dispose();
        createAd();
      },
    );

    await _interstitialAd!.show();
    _interstitialAd = null;
  }
}
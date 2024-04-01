import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_news/helpers/ad_helper.dart';
import 'package:flutter/material.dart';

class InterstitialAdController {
  InterstitialAd? _interstitialAd;
  int num_of_attempt_load = 0;
  int showCount = 0;
  bool canShowAdOnLoaded = false;
  VoidCallback? onAdLoadedCallback;
  VoidCallback? onAdClosedCallback;

  InterstitialAd? get getAd => _interstitialAd;

  void setAd(InterstitialAd? ad){
    _interstitialAd = ad;
  }

  void createAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.intersitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        // 広告が正常にロードされたときに呼ばれます。
        onAdLoaded: (InterstitialAd ad) {
          print("load succeeded");
          _interstitialAd = ad;
          num_of_attempt_load = 0;
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
    print("created");
  }

  // show interstitial ads to user
  Future<void> showAd() async {
    showCount ++;
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      canShowAdOnLoaded = true;
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
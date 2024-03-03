import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_news/helpers/ad_helper.dart';
import 'package:video_news/models/ad_display.dart';

class BannerAddsController {
  List<BannerAd> bannerAds = [];
  List<AdDisplay> adDisplays = [];
  List<BannerAdListener> bannerAdListeners = [];
  int bannerAdCount;
  
  BannerAddsController({
    required this.bannerAdCount
  }) {
    for (int i = 0; i < bannerAdCount; i++) {
      BannerAd bannerAd = BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            adDisplays[i].isLoaded = true;
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {},
        ),
      );
      bannerAd.load();
      bannerAds.add(bannerAd);
      //adDisplays.add(AdDisplay(bannerAd: bannerAd));
    }
  }

  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.fullBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => print('バナー広告がロードされました'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          print('バナー広告の読み込みが次の理由で失敗しました: $error');
        },
        onAdOpened: (Ad ad) => print('バナー広告が開かれました'),
        onAdClosed: (Ad ad) => print('バナー広告が閉じられました'),
        onAdImpression: (Ad ad) => print('次のバナー広告が表示されました: $ad'),
      ),
    );
  }
}

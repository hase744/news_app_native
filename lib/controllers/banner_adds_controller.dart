import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_news/helpers/ad_helper.dart';
import 'package:video_news/models/ad_display.dart';

class BannerAddsController {
  List<BannerAd> bannerAds = [];
  List<AdDisplay> adDisplays = [];
  List<BannerAdListener> bannerAdListeners = [];
  int bannerAdCount = 4;
  
  BannerAddsController() {
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
}

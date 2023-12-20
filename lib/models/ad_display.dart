import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_news/helpers/ad_helper.dart';
class AdDisplay{
  BannerAd bannerAd;
  bool isLoaded = false;

  AdDisplay({
    required this.bannerAd
  });
}
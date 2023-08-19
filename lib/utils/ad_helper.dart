import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'logger.dart';

class AdHelper {
  static String getBannerAdUnitId(String screen) {
    switch (screen) {
      case 'Home':
        return 'ca-app-pub-9710312053534636/7759249793';
      default:
        return '';
    }
  }

  static String getInterstitialAdUnitId({String? screen}) {
    switch (screen) {
      default:
        return 'ca-app-pub-9710312053534636/4414901158';
    }
  }

  static Future<void> createInterstitialAd({String? screen}) async {
    if (kDebugMode) {
      return;
    }
    InterstitialAd.load(
      adUnitId: AdHelper.getInterstitialAdUnitId(screen: screen),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          ad.show();
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              logError('onAdFailedToShowFullScreenContent: ${error.message}');
              ad.dispose();
              createInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          logDebug('InterstitialAd failed to load: $error');
        },
      ),
    );
  }
}

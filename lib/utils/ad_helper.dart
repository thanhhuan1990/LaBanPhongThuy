import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'logger.dart';

class AdHelper {
  // Google's sample ad unit IDs, used in debug builds to avoid invalid traffic on real units.
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/9214589741';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  /// Requests the latest consent info (UMP) and shows the consent form if required.
  /// Completes when ads may be requested; failures are logged and do not block the app.
  static Future<void> gatherConsent() {
    final Completer<void> completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          _loadConsentFormIfRequired(completer);
        } else {
          completer.complete();
        }
      },
      (FormError error) {
        logError('requestConsentInfoUpdate failed: ${error.message}');
        completer.complete();
      },
    );
    return completer.future;
  }

  static void _loadConsentFormIfRequired(Completer<void> completer) {
    ConsentForm.loadConsentForm(
      (ConsentForm form) async {
        if (await ConsentInformation.instance.getConsentStatus() == ConsentStatus.required) {
          form.show((FormError? error) {
            if (error != null) {
              logError('ConsentForm show failed: ${error.message}');
            }
            completer.complete();
          });
        } else {
          completer.complete();
        }
      },
      (FormError error) {
        logError('ConsentForm load failed: ${error.message}');
        completer.complete();
      },
    );
  }

  static String getBannerAdUnitId(String screen) {
    if (kDebugMode) {
      return _testBannerAdUnitId;
    }
    switch (screen) {
      case 'Home':
        return 'ca-app-pub-9710312053534636/7759249793';
      default:
        return '';
    }
  }

  static String getInterstitialAdUnitId({String? screen}) {
    if (kDebugMode) {
      return _testInterstitialAdUnitId;
    }
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

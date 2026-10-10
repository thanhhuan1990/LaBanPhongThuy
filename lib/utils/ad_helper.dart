import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
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

  // Interstitial frequency rules: only shown at a natural break (after a completed lookup),
  // never right after launch, and with a cooldown between two ads.
  static const Duration _interstitialFirstShowDelay = Duration(seconds: 60);
  static const Duration _interstitialCooldown = Duration(seconds: 90);
  static const int _lookupsPerInterstitial = 2;
  // A loaded interstitial is only valid for about one hour.
  static const Duration _interstitialExpiration = Duration(minutes: 55);
  static const int _maxInterstitialLoadRetries = 5;

  static final DateTime _sessionStart = DateTime.now();
  static InterstitialAd? _interstitialAd;
  static DateTime? _interstitialLoadedAt;
  static DateTime? _lastInterstitialShownAt;
  static bool _isLoadingInterstitial = false;
  static bool _isShowingInterstitial = false;
  static int _interstitialLoadRetries = 0;
  static int _lookupsSinceInterstitial = 0;

  /// Preloads an interstitial so it can be shown instantly at the next break point.
  static void createInterstitialAd({String? screen}) {
    if (_interstitialAd != null || _isLoadingInterstitial) {
      return;
    }
    _isLoadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: AdHelper.getInterstitialAdUnitId(screen: screen),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          logDebug('InterstitialAd loaded');
          _isLoadingInterstitial = false;
          _interstitialLoadRetries = 0;
          _interstitialAd = ad;
          _interstitialLoadedAt = DateTime.now();
        },
        onAdFailedToLoad: (LoadAdError error) {
          logDebug('InterstitialAd failed to load: $error');
          _isLoadingInterstitial = false;
          _retryInterstitialLoad(screen: screen);
        },
      ),
    );
  }

  /// Exponential backoff (2s, 4s, 8s...) so a no-fill does not hammer the ad server.
  static void _retryInterstitialLoad({String? screen}) {
    if (_interstitialLoadRetries >= _maxInterstitialLoadRetries) {
      _interstitialLoadRetries = 0;
      return;
    }
    _interstitialLoadRetries++;
    Timer(Duration(seconds: 1 << _interstitialLoadRetries), () => createInterstitialAd(screen: screen));
  }

  /// Called when the user finishes a lookup (a new gender/year result is on screen).
  /// Shows the preloaded interstitial if all frequency rules pass.
  static void onLookupCompleted() {
    _lookupsSinceInterstitial++;
    if (_canShowInterstitial()) {
      _showInterstitialAd();
    } else if (_interstitialAd == null) {
      createInterstitialAd();
    }
  }

  static bool _canShowInterstitial() {
    final DateTime now = DateTime.now();
    if (_interstitialAd == null || _isShowingInterstitial) {
      return false;
    }
    if (now.difference(_interstitialLoadedAt!) > _interstitialExpiration) {
      _interstitialAd!.dispose();
      _interstitialAd = null;
      return false;
    }
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return false;
    }
    if (_lookupsSinceInterstitial < _lookupsPerInterstitial ||
        now.difference(_sessionStart) < _interstitialFirstShowDelay) {
      return false;
    }
    final DateTime? lastShownAt = _lastInterstitialShownAt;
    return lastShownAt == null || now.difference(lastShownAt) >= _interstitialCooldown;
  }

  static void _showInterstitialAd() {
    final InterstitialAd ad = _interstitialAd!;
    _interstitialAd = null;
    _isShowingInterstitial = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        _lastInterstitialShownAt = DateTime.now();
        _lookupsSinceInterstitial = 0;
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        _isShowingInterstitial = false;
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        logError('onAdFailedToShowFullScreenContent: ${error.message}');
        _isShowingInterstitial = false;
        ad.dispose();
        createInterstitialAd();
      },
    );
    ad.show();
  }
}

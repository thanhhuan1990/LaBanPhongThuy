import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:la_ban_phong_thuy/utils/CanChiUtils.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/ad_helper.dart';
import '../utils/logger.dart';

/// Created by Huan.Huynh on 22/Apr/2021
///
/// Copyright © 2021 by Huan.Huynh All rights reserved.
class CompassController extends GetxController {
  final Rxn<BannerAd> anchoredBanner = Rxn<BannerAd>();
  Timer? _timer;

  var count = 0.obs;
  increment() => count++;

  var gender = "Nam".obs;
  setGender(String gender) => this.gender.value = gender;

  var year = DateTime.now().obs;
  setYear(DateTime year) => this.year.value = year;

  var hasPermissions = false.obs;

  Rx<double> heading = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    Permission.locationWhenInUse.request().then((ignored) {
      _fetchPermissionStatus();
      _registerListener();
    });

    _createAnchoredBanner();
    _initInterstitialAd();
  }

  @override
  void dispose() {
    if (_timer?.isActive == true) {
      _timer?.cancel();
    }
    anchoredBanner.value?.dispose();
    super.dispose();
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      hasPermissions.value = status == PermissionStatus.granted;
    });
  }

  void _registerListener() => FlutterCompass.events?.listen(_onData);

  void _onData(CompassEvent event) => heading.value = event.heading ?? 0;

  MaterialColor getAppColor() {
    String nguHanh = getNguHanh(year.value);
    if (nguHanh.contains('Kim')) {
      return Colors.yellow;
    } else if (nguHanh.contains('Mộc')) {
      return Colors.green;
    } else if (nguHanh.contains('Thủy')) {
      return Colors.blue;
    } else if (nguHanh.contains('Hoả')) {
      return Colors.red;
    } else {
      return Colors.brown;
    }
  }

  Future<void> _createAnchoredBanner() async {
    if (anchoredBanner.value != null) {
      return;
    }
    final AnchoredAdaptiveBannerAdSize? size = await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      Get.width.truncate(),
    );

    if (size == null) {
      logWarning('Unable to get height of anchored banner.');
      return;
    }

    final BannerAd banner = BannerAd(
      size: size,
      request: const AdRequest(
        keywords: <String>['foo', 'bar'],
        contentUrl: 'http://foo.com/bar.html',
        nonPersonalizedAds: true,
      ),
      adUnitId: AdHelper.getBannerAdUnitId('Home'),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          logInfo('$BannerAd Loaded');
          anchoredBanner.value = ad as BannerAd;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          logError('$BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => logDebug('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => logDebug('$BannerAd onAdClosed.'),
      ),
    );
    return banner.load();
  }

  void _initInterstitialAd() async {
    if (_timer?.isActive == true) {
      _timer?.cancel();
    }
    _timer = Timer.periodic(const Duration(minutes: 2), (Timer timer) {
      AdHelper.createInterstitialAd();
    });
  }
}

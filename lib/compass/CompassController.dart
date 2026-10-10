import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:la_ban_phong_thuy/utils/CanChiUtils.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/ad_helper.dart';
import '../utils/logger.dart';

enum CompassSensorStatus { waiting, ready, error, unsupported }

/// Created by Huan.Huynh on 22/Apr/2021
///
/// Copyright © 2021 by Huan.Huynh All rights reserved.
class CompassController extends GetxController {
  final Rxn<BannerAd> anchoredBanner = Rxn<BannerAd>();

  var count = 0.obs;
  increment() => count++;

  var gender = "Nam".obs;
  setGender(String gender) {
    this.gender.value = gender;
    _onProfileChanged();
  }

  var year = DateTime.now().obs;
  setYear(DateTime year) {
    this.year.value = year;
    _onProfileChanged();
  }

  // A lookup is completed when, after changing gender/year, the user turns the phone
  // and then holds it still (within _lookupStableDegrees) for _lookupStableDuration.
  static const double _lookupMinRotationDegrees = 15;
  static const double _lookupStableDegrees = 5;
  static const Duration _lookupStableDuration = Duration(seconds: 2);
  bool _awaitingLookup = false;
  bool _hasRotatedSinceProfileChange = false;
  double _profileChangedHeading = 0;
  double _stableAnchorHeading = 0;
  Timer? _lookupTimer;

  var hasPermissions = false.obs;

  /// Heading in degrees, normalized to [0, 360).
  Rx<double> heading = 0.0.obs;
  final Rx<CompassSensorStatus> sensorStatus = CompassSensorStatus.waiting.obs;
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void onInit() {
    super.onInit();

    // The compass sensor does not need location permission, so start listening right away.
    _registerListener();
    Permission.locationWhenInUse.request().then((ignored) => _fetchPermissionStatus());

    _createAnchoredBanner();
  }

  @override
  void onClose() {
    _lookupTimer?.cancel();
    _compassSubscription?.cancel();
    anchoredBanner.value?.dispose();
    super.onClose();
  }

  void _onProfileChanged() {
    _lookupTimer?.cancel();
    _awaitingLookup = true;
    _hasRotatedSinceProfileChange = false;
    _profileChangedHeading = heading.value;
  }

  void _trackLookupRotation(double currentHeading) {
    if (!_awaitingLookup) {
      return;
    }
    if (!_hasRotatedSinceProfileChange) {
      if (_angleDistance(currentHeading, _profileChangedHeading) < _lookupMinRotationDegrees) {
        return;
      }
      _hasRotatedSinceProfileChange = true;
      _restartStableTimer(currentHeading);
      return;
    }
    // Still turning: restart the "hold still" countdown from the new direction.
    if (_angleDistance(currentHeading, _stableAnchorHeading) > _lookupStableDegrees) {
      _restartStableTimer(currentHeading);
    }
  }

  void _restartStableTimer(double anchorHeading) {
    _stableAnchorHeading = anchorHeading;
    _lookupTimer?.cancel();
    _lookupTimer = Timer(_lookupStableDuration, () {
      _awaitingLookup = false;
      AdHelper.onLookupCompleted();
    });
  }

  /// Smallest angle between two headings, in [0, 180].
  double _angleDistance(double a, double b) => ((a - b + 540) % 360 - 180).abs();

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      hasPermissions.value = status == PermissionStatus.granted;
    });
  }

  void _registerListener() {
    final Stream<CompassEvent>? events = FlutterCompass.events;
    if (events == null) {
      sensorStatus.value = CompassSensorStatus.unsupported;
      return;
    }
    _compassSubscription?.cancel();
    _compassSubscription = events.listen(
      _onData,
      onError: (Object error) {
        logError('Compass sensor error: $error');
        sensorStatus.value = CompassSensorStatus.error;
      },
    );
  }

  void _onData(CompassEvent event) {
    final double? value = event.heading;
    // A null heading means the device has no compass sensor.
    if (value == null) {
      sensorStatus.value = CompassSensorStatus.unsupported;
      return;
    }
    // flutter_compass reports [-180, 180]; normalize so getDirection() gets [0, 360).
    heading.value = (value % 360 + 360) % 360;
    _trackLookupRotation(heading.value);
    sensorStatus.value = CompassSensorStatus.ready;
  }

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
    final AnchoredAdaptiveBannerAdSize? size = await AdSize.getLargeAnchoredAdaptiveBannerAdSizeWithOrientation(
      Orientation.portrait,
      Get.width.truncate(),
    );

    if (size == null) {
      logWarning('Unable to get height of anchored banner.');
      return;
    }

    final BannerAd banner = BannerAd(
      size: size,
      request: const AdRequest(),
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
}

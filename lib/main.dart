import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:xpromo/xpromo.dart';

import 'compass/CompassStatefulWidget.dart';
import 'ui/palette.dart';
import 'utils/ad_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Quảng bá chéo các app khác của HuanHuynh (package xpromo-flutter). Không chặn khởi động nếu lỗi.
  try {
    await XPromo.init(const XPromoConfig(
      selfPackage: 'com.huanhuynh.la_ban_phong_thuy',
      hostGroups: ['spiritual', 'household'],
    ));
    unawaited(XPromo.instance?.refreshIfStale() ?? Future<void>.value());
  } catch (_) {}
  await AdHelper.gatherConsent();
  await MobileAds.instance.initialize();
  AdHelper.createInterstitialAd();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(GetMaterialApp(
    title: 'Tự Xem Phong Thuỷ',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: ElementTheme.tho.primary,
      scaffoldBackgroundColor: Palette.paper,
    ),
    home: CompassStatefulWidget(),
  ));
}

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'compass/CompassStatefulWidget.dart';
import 'utils/ad_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AdHelper.gatherConsent();
  await MobileAds.instance.initialize();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(GetMaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CompassStatefulWidget(),
    );
  }
}

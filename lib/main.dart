import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'compass/CompassController.dart';
import 'compass/CompassStatefulWidget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await Firebase.initializeApp();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(GetMaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CompassController controller = Get.put(CompassController());

    return Obx(
      () => MaterialApp(
        title: 'Tự Xem Phong Thuỷ',
        theme: ThemeData(
          primarySwatch: controller.getAppColor(),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: CompassStatefulWidget(),
      ),
    );
  }
}

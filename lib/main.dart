import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:la_ban_phong_thuy/compass/CompassStatefulWidget.dart';

import 'compass/CompassController.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runZonedGuarded(() {
    runApp(GetMaterialApp(home: MyApp()));
  }, FirebaseCrashlytics.instance.recordError);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Instantiate your class using Get.put() to make it available for all "child" routes there.
    final CompassController controller = Get.put(CompassController());

    return Obx(() => MaterialApp(
          title: 'Tự Xem Phong Thuỷ',
          theme: ThemeData(
              primarySwatch: controller.getAppColor(),
              visualDensity: VisualDensity.adaptivePlatformDensity,
              accentColor: null),
          home: CompassStatefulWidget(),
        ));
  }
}

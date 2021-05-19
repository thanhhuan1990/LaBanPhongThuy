import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:get/get.dart';
import 'package:la_ban_phong_thuy/utils/CanChiUtils.dart';
import 'package:permission_handler/permission_handler.dart';

/// Created by Huan.Huynh on 22/Apr/2021
///
/// Copyright © 2021 by Huan.Huynh All rights reserved.
class CompassController extends GetxController {
  var count = 0.obs;
  increment() => count++;

  var gender = "Nam".obs;
  setGender(String gender) => this.gender.value = gender;

  var year = DateTime.now().obs;
  setYear(DateTime year) => this.year.value = year;

  var hasPermissions = false.obs;

  Rx<double> heading = 0.0.obs;

  void fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      hasPermissions.value = status == PermissionStatus.granted;
    });
  }

  void registerListener() {
    FlutterCompass.events.listen(_onData);
  }

  void _onData(CompassEvent event) {
    heading.value = event.heading;
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
}

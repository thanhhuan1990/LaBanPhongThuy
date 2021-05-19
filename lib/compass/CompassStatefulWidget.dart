import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:get/get.dart';
import 'package:la_ban_phong_thuy/utils/CanChiUtils.dart';
import 'package:la_ban_phong_thuy/utils/custom_year_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'CompassController.dart';

/// Created by Huan.Huynh on 22/Apr/2021
///
/// Copyright © 2021 by Huan.Huynh All rights reserved.
class CompassStatefulWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CompassState();
}

class CompassState extends State<CompassStatefulWidget> {
  final CompassController controller = Get.find();

  @override
  void initState() {
    super.initState();
    Permission.locationWhenInUse.request().then((ignored) {
      controller.fetchPermissionStatus();
      controller.registerListener();
    });
  }

  @override
  Widget build(context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        appBar: AppBar(
            title: Obx(() => Text(
                "Tự Xem Phong Thuỷ ${controller.hasPermissions.isTrue ? getDirection(controller.heading.value) : ""}"))),
        body: Container(
          color: Color(0xffF5F4F0),
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: _buildMainPage(controller),
        ),
      ),
    );
  }

  Widget _buildMainPage(CompassController controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Obx(() => Text(
                  "Mệnh: ${getNguHanh(controller.year.value)}",
                  style: TextStyle(fontSize: 20),
                  maxLines: 1,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Obx(() => Text(
                  "Can Chi: ${getCanChi(controller.year.value)}",
                  style: TextStyle(fontSize: 20),
                  maxLines: 1,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Obx(() => Text(
                  "Cung phi: ${getMenh(controller.gender.value, controller.year.value)}",
                  style: TextStyle(fontSize: 20),
                  maxLines: 1,
                )),
          ),
          AspectRatio(
            child: _buildCompass(),
            aspectRatio: 1,
          ),
          Expanded(
            child: _selector(),
          ),
          _contactWidget(),
        ],
      );

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text(
            'Thiết bị của bạn gặp lỗi với bộ phận cảm ứng!'
            '\nHãy thử cập nhật hệ điều hành mới nhất,'
            '\nvà vui lòng gửi thông báo tới tác giả.'
            '\n\nChúng tôi rất tiếc vì vấn đề này.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.6),
          ));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        var direction = snapshot.data.heading;

        // if direction is null, then device does not support this sensor
        // show error message
        if (direction == null)
          return Center(
            child: Text("Device does not have sensors !"),
          );

        return Material(
          shape: CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: (direction * (math.pi / 180) * -1),
                  child:
                      Obx(() => Image.asset('assets/${getMenhImages(controller.gender.value, controller.year.value)}')),
                ),
                Image.asset('assets/Needle.png'),
                Text(
                  'Thái Thạnh',
                  style: TextStyle(color: controller.getAppColor(), fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _selector() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: ScrollConfiguration(
              behavior: ScrollBehavior(),
              child: GlowingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                color: Colors.transparent,
                showLeading: false,
                showTrailing: false,
                child: CupertinoPicker(
                  itemExtent: 50,
                  scrollController: FixedExtentScrollController(initialItem: 0),
                  children: [
                    Container(
                      height: 50,
                      child: Center(
                        child: Text(
                          'Nam',
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      child: Center(child: Text('Nữ')),
                    ),
                  ],
                  onSelectedItemChanged: (value) {
                    controller.setGender(value == 0 ? "Nam" : "Nữ");
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Obx(() => ScrollConfiguration(
                  behavior: ScrollBehavior(),
                  child: GlowingOverscrollIndicator(
                    axisDirection: AxisDirection.down,
                    color: Colors.transparent,
                    showLeading: false,
                    showTrailing: false,
                    child: CustomYearPicker(
                      firstDate: DateTime(DateTime.now().year - 120, 1),
                      lastDate: DateTime(DateTime.now().year + 20, 1),
                      selectedDate: controller.year.value,
                      onChanged: (DateTime dateTime) => controller.setYear(dateTime),
                      currentDate: controller.year.value,
                    ),
                  ),
                )),
          )
        ],
      );

  Widget _contactWidget() => Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              key: GlobalKey(),
              text: TextSpan(
                style: TextStyle(color: Colors.grey, fontSize: 16.0),
                children: <TextSpan>[
                  TextSpan(text: 'Liên hệ Tác Giả: '),
                  TextSpan(
                      text: '0913013489',
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _launch("tel:+84913013489");
                        }),
                  TextSpan(text: ' - '),
                  TextSpan(
                      text: '0934131468',
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _launch("tel:+84934131468");
                        }),
                ],
              ),
            ),
            Container(
              height: 6,
            ),
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey, fontSize: 16.0),
                children: <TextSpan>[
                  TextSpan(text: 'Email: '),
                  TextSpan(
                      text: 'thaithanh87@gmail.com',
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _launch("mailto:thaithanh87@gmail.com");
                        }),
                ],
              ),
            ),
          ],
        ),
      );

  Future<void> _launch(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

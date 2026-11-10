import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:la_ban_phong_thuy/compass/widgets/author_card.dart';
import 'package:la_ban_phong_thuy/compass/widgets/smooth_compass_rotation.dart';
import 'package:la_ban_phong_thuy/ui/palette.dart';
import 'package:la_ban_phong_thuy/utils/CanChiUtils.dart';
import 'package:la_ban_phong_thuy/utils/custom_year_picker.dart';

import 'CompassController.dart';

/// Created by Huan.Huynh on 22/Apr/2021
///
/// Copyright © 2021 by Huan.Huynh All rights reserved.
///
/// Màn hình chính: đầu trang theo màu mệnh (hướng + Mệnh/Can Chi/Cung phi), la bàn (giữ nguyên ảnh,
/// kim, tên tác giả ở tâm), chọn giới tính & năm sinh, thẻ tác giả, banner.
class CompassStatefulWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CompassState();
}

class CompassState extends State<CompassStatefulWidget> {
  final CompassController controller = Get.put(CompassController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ElementTheme el = ElementTheme.of(controller.year.value);
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: el.primary, primary: el.primary),
        ),
        child: Scaffold(
          backgroundColor: Palette.paper,
          appBar: AppBar(
            backgroundColor: el.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text('Tự Xem Phong Thuỷ', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            actions: [
              IconButton(
                tooltip: 'Ứng dụng khác',
                icon: const Icon(Icons.apps_rounded),
                onPressed: () => showMoreAppsSheet(context, el),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(el),
                Expanded(child: _buildCompass(el)),
                _profileBar(context, el),
                const SizedBox(height: 8),
                AuthorCard(accent: el),
                const SizedBox(height: 8),
                bottomBanner(),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ---------------- Đầu trang ----------------

  Widget _header(ElementTheme el) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [el.primary, el.dark]),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            final bool ready = controller.sensorStatus.value == CompassSensorStatus.ready;
            final double h = controller.heading.value;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ready ? '${h.round()}°' : '--°',
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white, height: 1),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      ready ? 'Hướng ${directionName(h)}' : 'Đang dò hướng…',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoPill('Mệnh', getNguHanh(controller.year.value)),
              const SizedBox(width: 8),
              _infoPill('Can Chi', getCanChi(controller.year.value)),
              const SizedBox(width: 8),
              _infoPill('Cung phi', getMenh(controller.gender.value, controller.year.value)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoPill(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  maxLines: 1, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- La bàn (giữ nguyên ảnh, kim, tên tác giả) ----------------

  Widget _buildCompass(ElementTheme el) {
    return Obx(() {
      switch (controller.sensorStatus.value) {
        case CompassSensorStatus.waiting:
          return const Center(child: CircularProgressIndicator());
        case CompassSensorStatus.error:
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Thiết bị của bạn gặp lỗi với bộ phận cảm ứng!'
                '\nHãy thử cập nhật hệ điều hành mới nhất,'
                '\nvà vui lòng gửi thông báo tới tác giả.'
                '\n\nChúng tôi rất tiếc vì vấn đề này.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.6, color: Palette.ink),
              ),
            ),
          );
        // Device does not have a compass sensor.
        case CompassSensorStatus.unsupported:
          return const Center(
            child: Text('Thiết bị của bạn gặp lỗi với bộ phận cảm ứng!', style: TextStyle(color: Palette.ink)),
          );
        case CompassSensorStatus.ready:
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Center(child: AspectRatio(aspectRatio: 1, child: _buildDial(el))),
          );
      }
    });
  }

  Widget _buildDial(ElementTheme el) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: el.dark.withValues(alpha: 0.25), blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: Material(
        color: Colors.white,
        shape: CircleBorder(side: BorderSide(color: el.primary.withValues(alpha: 0.35), width: 2)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SmoothCompassRotation(
                headingStream: controller.heading.stream,
                initialHeading: controller.heading.value,
                child: Image.asset(
                  'assets/${getMenhImages(controller.gender.value, controller.year.value)}',
                  gaplessPlayback: true,
                ),
              ),
              const FractionallySizedBox(
                widthFactor: 0.6, // Chiều rộng của kim là 60% la bàn
                heightFactor: 0.6,
                child: Image(image: AssetImage('assets/Needle.png')),
              ),
              // Tên tác giả ở tâm la bàn: chữ đậm màu mệnh, viền sáng để nổi trên hình âm dương.
              Text(
                'Nguyễn Nhan\nThái Thạnh',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: el.dark,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'serif',
                  height: 1.15,
                  letterSpacing: 0.3,
                  shadows: const [
                    Shadow(color: Colors.white, blurRadius: 2),
                    Shadow(color: Colors.white, blurRadius: 6),
                    Shadow(color: Colors.white, blurRadius: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Giới tính & năm sinh ----------------

  Widget _profileBar(BuildContext context, ElementTheme el) {
    final String gender = controller.gender.value;
    final int year = controller.year.value.year;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'Nam', label: Text('Nam'), icon: Icon(Icons.male_rounded)),
                ButtonSegment(value: 'Nữ', label: Text('Nữ'), icon: Icon(Icons.female_rounded)),
              ],
              selected: {gender},
              onSelectionChanged: (s) => controller.setGender(s.first),
              style: SegmentedButton.styleFrom(
                backgroundColor: Palette.card,
                selectedBackgroundColor: el.primary,
                selectedForegroundColor: Colors.white,
                foregroundColor: Palette.ink,
                side: const BorderSide(color: Palette.line),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _pickYear(context, el),
              style: OutlinedButton.styleFrom(
                backgroundColor: Palette.card,
                foregroundColor: Palette.ink,
                side: const BorderSide(color: Palette.line),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cake_outlined, size: 18, color: el.primary),
                  const SizedBox(width: 6),
                  Text('Năm sinh $year', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const Icon(Icons.arrow_drop_down_rounded),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickYear(BuildContext context, ElementTheme el) {
    final ThemeData theme = Theme.of(context);
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Palette.paper,
      builder: (ctx) => Theme(
        data: theme,
        child: SafeArea(
          child: SizedBox(
            height: 380,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text('Chọn năm sinh (âm lịch)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Palette.ink)),
                ),
                Expanded(
                  child: CustomYearPicker(
                    firstDate: DateTime(DateTime.now().year - 120, 1),
                    lastDate: DateTime(DateTime.now().year + 20, 1),
                    selectedDate: controller.year.value,
                    currentDate: controller.year.value,
                    onChanged: (DateTime dateTime) {
                      controller.setYear(dateTime);
                      Navigator.of(ctx).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Banner ----------------

  Widget bottomBanner() {
    final BannerAd? ad = controller.anchoredBanner.value;
    if (ad == null) {
      return const SizedBox(height: kBottomNavigationBarHeight);
    }
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}

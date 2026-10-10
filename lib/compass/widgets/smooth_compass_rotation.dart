import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Rotates [child] against the device heading, interpolating every frame so the dial
/// glides instead of jumping between noisy sensor readings.
class SmoothCompassRotation extends StatefulWidget {
  const SmoothCompassRotation({
    super.key,
    required this.headingStream,
    required this.initialHeading,
    required this.child,
  });

  /// Heading in degrees, [0, 360).
  final Stream<double> headingStream;
  final double initialHeading;
  final Widget child;

  @override
  State<SmoothCompassRotation> createState() => _SmoothCompassRotationState();
}

class _SmoothCompassRotationState extends State<SmoothCompassRotation> with SingleTickerProviderStateMixin {
  // Time constant of the low-pass filter: higher is smoother but lags more.
  static const double _smoothingSeconds = 0.12;
  // Ignore sensor jitter smaller than this so the dial stays still when the phone is still.
  static const double _deadZoneDegrees = 0.4;
  static const double _settledDegrees = 0.05;

  late final Ticker _ticker;
  late final ValueNotifier<double> _angle;
  StreamSubscription<double>? _subscription;

  // Both values are unwrapped (not limited to [0, 360)) so the dial always turns the short way.
  late double _target;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _target = widget.initialHeading;
    _angle = ValueNotifier<double>(widget.initialHeading);
    _ticker = createTicker(_onTick);
    _subscribe();
  }

  @override
  void didUpdateWidget(SmoothCompassRotation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.headingStream != widget.headingStream) {
      _subscribe();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _ticker.dispose();
    _angle.dispose();
    super.dispose();
  }

  void _subscribe() {
    _subscription?.cancel();
    _subscription = widget.headingStream.listen(_onHeading);
  }

  void _onHeading(double heading) {
    // Shortest signed difference in (-180, 180], so 359° -> 1° turns 2°, not -358°.
    final double delta = (heading - _target + 540) % 360 - 180;
    if (delta.abs() < _deadZoneDegrees) {
      return;
    }
    _target += delta;
    if (!_ticker.isActive) {
      _lastTick = Duration.zero;
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    final double dt = (elapsed - _lastTick).inMicroseconds / Duration.microsecondsPerSecond;
    _lastTick = elapsed;

    final double remaining = _target - _angle.value;
    if (remaining.abs() < _settledDegrees) {
      _angle.value = _target;
      _ticker.stop();
      return;
    }
    // Frame-rate independent exponential smoothing.
    final double alpha = 1 - math.exp(-dt / _smoothingSeconds);
    _angle.value += remaining * alpha;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _angle,
      // RepaintBoundary caches the dial image so each frame only re-applies the transform.
      child: RepaintBoundary(child: widget.child),
      builder: (BuildContext context, double angle, Widget? child) => Transform.rotate(
        angle: -angle * math.pi / 180,
        child: child,
      ),
    );
  }
}

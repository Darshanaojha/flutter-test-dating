/// Tracks scroll velocity for fast-scroll suppression policies.
///
/// Implementations must be deterministic and side-effect free.
abstract interface class ScrollVelocityTracker {
  /// Feed successive scroll offsets.
  void onScrollOffset({required double offsetPixels, required Duration timestamp});

  /// Current velocity estimate in px/s.
  double get pixelsPerSecond;

  /// Whether the current velocity qualifies as "fast scroll".
  bool get isFastScroll;

  void reset();
}

/// A minimal deterministic scroll-velocity tracker.
///
/// - Computes instantaneous velocity from last (offset,time) sample.
/// - Uses injected threshold (spec does not define a numeric value).
final class BasicScrollVelocityTracker implements ScrollVelocityTracker {
  final double fastScrollThresholdPxPerSec;

  double _velocity = 0.0;
  double? _lastOffset;
  Duration? _lastTime;

  BasicScrollVelocityTracker({
    required this.fastScrollThresholdPxPerSec,
  });

  @override
  void onScrollOffset({required double offsetPixels, required Duration timestamp}) {
    final double? prevOffset = _lastOffset;
    final Duration? prevTime = _lastTime;

    _lastOffset = offsetPixels;
    _lastTime = timestamp;

    if (prevOffset == null || prevTime == null) {
      _velocity = 0.0;
      return;
    }

    final double dtSec =
        (timestamp - prevTime).inMicroseconds.toDouble() / 1e6;
    if (dtSec <= 0) {
      _velocity = 0.0;
      return;
    }

    final double dx = offsetPixels - prevOffset;
    _velocity = dx / dtSec;
  }

  @override
  double get pixelsPerSecond => _velocity;

  @override
  bool get isFastScroll => _velocity.abs() >= fastScrollThresholdPxPerSec;

  @override
  void reset() {
    _velocity = 0.0;
    _lastOffset = null;
    _lastTime = null;
  }
}

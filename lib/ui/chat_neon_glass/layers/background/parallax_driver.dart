/// Computes parallax offsets for background layers relative to scroll offset.
///
/// The spec calls for background drift of ~8–12px slower than content; we use
/// the provided tokens.parallaxDrift range to clamp the offset.
class ParallaxDriver {
  final double minDrift;
  final double maxDrift;

  const ParallaxDriver({
    required this.minDrift,
    required this.maxDrift,
  });

  /// Returns a vertical offset (pixels) for a given scroll offset.
  ///
  /// We scale the scroll offset down to the drift range to avoid large shifts.
  double offsetFor(double scrollOffset) {
    // Clamp drift to spec range.
    final double drift = scrollOffset * 0.05;
    final double clamped =
        drift.clamp(minDrift * -1, maxDrift); // allow slight negative for pull
    return clamped;
  }
}

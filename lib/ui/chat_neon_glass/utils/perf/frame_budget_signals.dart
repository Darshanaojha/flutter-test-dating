/// Signals about frame budget/performance pressure.
///
/// Used to optionally suppress expensive effects (noise/blur/particles).
abstract interface class FrameBudgetSignals {
  /// True when the UI should reduce or disable expensive effects.
  bool get isUnderPressure;

  Stream<bool> watchPressure();
}

/// A simple, UI-only implementation that exposes a fixed pressure signal.
///
/// This keeps the system compilable without depending on engine frame timings.
final class StaticFrameBudgetSignals implements FrameBudgetSignals {
  final bool _isUnderPressure;

  const StaticFrameBudgetSignals({bool isUnderPressure = false})
      : _isUnderPressure = isUnderPressure;

  @override
  bool get isUnderPressure => _isUnderPressure;

  @override
  Stream<bool> watchPressure() => Stream<bool>.value(_isUnderPressure);
}

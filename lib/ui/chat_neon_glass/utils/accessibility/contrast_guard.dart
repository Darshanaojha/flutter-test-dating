import 'package:flutter/material.dart';

/// Accessibility guard for ensuring minimum contrast ratios.
///
/// Stubs only: no implementation yet.
abstract interface class ContrastGuard {
  /// Returns true if the provided foreground/background meet minimum contrast.
  bool meetsMinimumContrast({required Color fg, required Color bg, double minRatio = 4.5});
}

import 'dart:ui';

/// Helper for producing glass-like paints/filters.
///
/// Stubs only: no rendering logic yet.
abstract interface class GlassPaintHelper {
  ImageFilter backdropBlur({required double sigmaX, required double sigmaY});

  Paint glassFillPaint();
  Paint glassStrokePaint();
}

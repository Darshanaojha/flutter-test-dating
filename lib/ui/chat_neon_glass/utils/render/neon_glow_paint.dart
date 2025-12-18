import 'dart:ui';

/// Helper for neon glow paint/shadow generation.
///
/// Stubs only: no rendering logic yet.
abstract interface class NeonGlowPaintHelper {
  Paint rimGlowPaint(Color color, double opacity);
  Paint rimStrokePaint(Color color, double opacity);
}

/// Basic implementation of neon glow paints using additive-friendly colors.
final class DefaultNeonGlowPaintHelper implements NeonGlowPaintHelper {
  const DefaultNeonGlowPaintHelper();

  @override
  Paint rimGlowPaint(Color color, double opacity) {
    return Paint()
      ..color = color.withOpacity(opacity.clamp(0, 1))
      ..blendMode = BlendMode.screen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
  }

  @override
  Paint rimStrokePaint(Color color, double opacity) {
    return Paint()
      ..color = color.withOpacity(opacity.clamp(0, 1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
  }
}

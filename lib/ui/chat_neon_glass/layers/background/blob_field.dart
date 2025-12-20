import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../tokens/chat_tokens.dart';

/// Blurred neon blob field with parallax drift (UI-only).
class BlobField extends StatelessWidget {
  final ChatTokens tokens;
  final double blurMultiplier;
  final double parallaxOffset;

  const BlobField({
    super.key,
    required this.tokens,
    required this.blurMultiplier,
    this.parallaxOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double w = size.width;
    final List<Color> palette = tokens.colors.blobColors.isNotEmpty
        ? tokens.colors.blobColors
        : tokens.colors.backgroundGradientStops;

    // Define 5 blobs with large radii (0.6–1.3 x screen width).
    final List<_Blob> blobs = <_Blob>[
      _Blob(
        radius: w * 0.9,
        color: palette[0 % palette.length],
        alignment: const Alignment(-0.55, -0.45),
      ),
      _Blob(
        radius: w * 0.7,
        color: palette[1 % palette.length],
        alignment: const Alignment(0.45, -0.25),
      ),
      _Blob(
        radius: w * 1.1,
        color: palette[2 % palette.length],
        alignment: const Alignment(0.05, 0.55),
      ),
      _Blob(
        radius: w * 0.6,
        color: palette[(0 + 2) % palette.length],
        alignment: const Alignment(-0.2, 0.35),
      ),
      _Blob(
        radius: w * 1.3,
        color: palette[(1 + 2) % palette.length],
        alignment: const Alignment(0.6, 0.65),
      ),
    ];

    // Parallax drift scaled by blurMultiplier so suppression zeroes movement.
    final double drift = parallaxOffset * 0.5 * blurMultiplier.clamp(0, 1);

    return IgnorePointer(
      child: Opacity(
        opacity: blurMultiplier.clamp(0.02, 1),
        child: Stack(
          children: blobs
              .map(
                (b) => Align(
                  alignment: b.alignment,
                  child: Transform.translate(
                    offset: Offset(0, drift),
                    child: _BlobPaint(
                      radius: b.radius,
                      color: b.color,
                      blurMultiplier: blurMultiplier,
                      parallaxOffset: parallaxOffset,
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _Blob {
  final double radius;
  final Color color;
  final Alignment alignment;
  const _Blob({
    required this.radius,
    required this.color,
    required this.alignment,
  });
}

class _BlobPainter extends CustomPainter {
  final Color color;
  final double radius;
  final Paint _paint;
  final double blurMultiplier;
  final double parallaxOffset;

  _BlobPainter({
    required this.color,
    required this.radius,
    required this.blurMultiplier,
    required this.parallaxOffset,
  }) : _paint = Paint()
          ..color = color.withOpacity(0.35)
          ..blendMode = BlendMode.screen
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.25);

  @override
  void paint(Canvas canvas, Size size) {
    debugPrint(
        "NEON: BlobPainter paint parallaxOffset=$parallaxOffset blurMult=$blurMultiplier");
    final Offset c = size.center(Offset.zero);
    final Rect bounds = Offset.zero & size;
    canvas.save();
    canvas.clipRect(bounds);
    canvas.drawCircle(c, radius, _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.blurMultiplier != blurMultiplier ||
        oldDelegate.parallaxOffset != parallaxOffset;
  }
}

class _BlobPaint extends StatelessWidget {
  final double radius;
  final Color color;
  final double blurMultiplier;
  final double parallaxOffset;

  const _BlobPaint({
    required this.radius,
    required this.color,
    required this.blurMultiplier,
    required this.parallaxOffset,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(radius * 2, radius * 2),
      painter: _BlobPainter(
        color: color,
        radius: radius,
        blurMultiplier: blurMultiplier,
        parallaxOffset: parallaxOffset,
      ),
    );
  }
}

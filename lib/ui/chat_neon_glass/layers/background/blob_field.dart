import 'package:flutter/material.dart';

import '../../tokens/chat_tokens.dart';

/// Static blurred blob field (animation to be added later).
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
    // Deterministic blob positions/sizes using token radii.
    final double minR = tokens.radius.blobRadiusMin;
    final double maxR = tokens.radius.blobRadiusMax;
    final List<Color> palette = tokens.colors.blobColors;

    final List<_Blob> blobs = <_Blob>[
      _Blob(
        radius: lerpDouble(minR, maxR, 0.15),
        color: palette[0 % palette.length],
        alignment: const Alignment(-0.6, -0.4),
      ),
      _Blob(
        radius: lerpDouble(minR, maxR, 0.55),
        color: palette[1 % palette.length],
        alignment: const Alignment(0.4, -0.2),
      ),
      _Blob(
        radius: lerpDouble(minR, maxR, 0.75),
        color: palette[2 % palette.length],
        alignment: const Alignment(0.1, 0.5),
      ),
    ];

    return Transform.translate(
      offset: Offset(0, parallaxOffset * 0.5),
      child: IgnorePointer(
        child: Opacity(
          opacity: blurMultiplier.clamp(0, 1),
          child: Stack(
            children: blobs
                .map(
                  (b) => Align(
                    alignment: b.alignment,
                    child: Container(
                      width: b.radius * 2,
                      height: b.radius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: b.color.withOpacity(0.35),
                        boxShadow: [
                          BoxShadow(
                            color: b.color.withOpacity(0.35),
                            blurRadius: b.radius * 0.6,
                            spreadRadius: b.radius * 0.15,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ),
    );
  }

  double lerpDouble(double a, double b, double t) => a + (b - a) * t;
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

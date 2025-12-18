import 'package:flutter/material.dart';

import '../../tokens/chat_tokens.dart';
import 'blob_field.dart';
import 'gradient_base.dart';
import 'noise_film.dart';
import 'parallax_driver.dart';

/// Composed background layer (gradient + blobs + noise) with parallax support.
class BackgroundLayer extends StatelessWidget {
  final ChatTokens tokens;
  final ParallaxDriver parallax;
  final double scrollOffset;
  final double blurMultiplier;
  final bool suppressNoise;
  final double parallaxStrength;

  const BackgroundLayer({
    super.key,
    required this.tokens,
    required this.parallax,
    required this.scrollOffset,
    required this.blurMultiplier,
    required this.suppressNoise,
    required this.parallaxStrength,
  });

  @override
  Widget build(BuildContext context) {
    final double effectiveOffset =
        parallax.offsetFor(scrollOffset * parallaxStrength);
    return Stack(
      children: [
        Positioned.fill(
          child: GradientBase(
            tokens: tokens,
            parallaxOffset: effectiveOffset,
          ),
        ),
        Positioned.fill(
          child: BlobField(
            tokens: tokens,
            blurMultiplier: blurMultiplier,
            parallaxOffset: effectiveOffset,
          ),
        ),
        if (!suppressNoise)
          Positioned.fill(
            child: NoiseFilm(
              opacity: 0.05,
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

/// Simple noise film overlay (opacity controlled by caller).
class NoiseFilm extends StatelessWidget {
  final double opacity;

  const NoiseFilm({
    super.key,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0) return const SizedBox.shrink();
    return IgnorePointer(
      child: Opacity(
        opacity: opacity.clamp(0, 1),
        child: Container(
          decoration: const BoxDecoration(
            // Placeholder static noise: subtle overlay color.
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

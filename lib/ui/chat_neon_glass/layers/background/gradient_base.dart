import 'package:flutter/material.dart';

import '../../tokens/chat_tokens.dart';

/// Base gradient background using spec-defined stops.
class GradientBase extends StatelessWidget {
  final ChatTokens tokens;
  final double parallaxOffset; // applied as vertical translation

  const GradientBase({
    super.key,
    required this.tokens,
    this.parallaxOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, parallaxOffset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: tokens.colors.backgroundGradientStops,
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

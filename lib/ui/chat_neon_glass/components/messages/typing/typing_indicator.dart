import 'dart:math';

import 'package:flutter/material.dart';

import '../../../tokens/chat_tokens.dart';

/// Animated typing indicator with three pulsing dots.
class TypingIndicator extends StatefulWidget {
  final ChatTokens tokens;
  final double glowMultiplier;

  const TypingIndicator({
    super.key,
    required this.tokens,
    required this.glowMultiplier,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.tokens.timing.typingIndicatorLoop,
    )..repeat();
    _anim = CurvedAnimation(
      parent: _controller,
      curve: widget.tokens.motion.typing,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double baseOpacity = widget.glowMultiplier.clamp(0, 1);
    return SizedBox(
      height: 24,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              final double phase = (index == 0)
                  ? 0.0
                  : (index == 1)
                      ? 0.12
                      : 0.24; // ~90-120ms staggering on 900ms loop
              final double t = (_anim.value + phase) % 1.0;
              final double pulse = 0.5 + 0.5 * sin(2 * pi * t);
              final double opacity = pulse * baseOpacity;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.tokens.spacing.xs / 2),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.tokens.colors.textSecondary.withOpacity(opacity),
                    boxShadow: [
                      BoxShadow(
                        color: widget.tokens.colors.textSecondary
                            .withOpacity(opacity * 0.8),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

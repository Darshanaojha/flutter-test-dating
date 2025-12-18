import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../adapters/ui_message.dart';
import '../../../adapters/ui_message_status.dart';
import '../../../tokens/chat_tokens.dart';
import 'bubble_text.dart';
import '../../../utils/render/neon_glow_paint.dart';

/// Base bubble shell (no text/timestamp/glow yet).
///
/// Responsibilities:
/// - Align incoming left, outgoing right
/// - Enforce radius, padding, max width from tokens
/// - Apply translucent glass fill + stroke using token opacity ranges
/// - Expose a slot [child] for future content
/// - Show deleted messages as visible placeholders with reduced opacity
class BubbleShell extends StatelessWidget {
  final UIMessage message;
  final ChatTokens tokens;
  final Widget child;
  final double glowMultiplier; // suppression-aware multiplier

  const BubbleShell({
    super.key,
    required this.message,
    required this.tokens,
    required this.child,
    this.glowMultiplier = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutgoing = message.isOutgoing;
    final bool isDeleted = message.status == UIMessageStatus.deleted;
    final bool isFailed = message.status == UIMessageStatus.failed;

    // Use mid-range translucency between min/max.
    final double bubbleOpacity =
        (tokens.opacity.bubbleBackgroundMin + tokens.opacity.bubbleBackgroundMax) /
            2;
    final double deletedOpacity = isDeleted ? 0.5 : 1.0;

    // Padding using midpoints.
    final double padV =
        (tokens.spacing.bubblePaddingVMin + tokens.spacing.bubblePaddingVMax) / 2;
    final double padH =
        (tokens.spacing.bubblePaddingHMin + tokens.spacing.bubblePaddingHMax) / 2;

    // Max width: use the stricter (min) fraction to avoid overly wide bubbles.
    final double maxFraction = tokens.spacing.bubbleMaxWidthFractionMin;

    final double blurSigma =
        (tokens.blur.microMin + tokens.blur.microMax) / 2; // light blur for glass

    // Rim color selection precedence: deleted -> failed -> outgoing -> incoming
    final Color rimColor = isDeleted
        ? tokens.colors.incomingBubbleStart
        : isFailed
            ? tokens.colors.failedBubbleRim
            : isOutgoing
                ? tokens.colors.outgoingBubbleStart
                : tokens.colors.incomingBubbleStart;

    // Base rim opacity: use active rim range mid-point.
    final double baseRimOpacity =
        (tokens.opacity.rimGlowActiveMin + tokens.opacity.rimGlowActiveMax) / 2;

    // Deleted multiplier 25–35%.
    final double deletedMultiplier = isDeleted ? 0.3 : 1.0;

    final double finalRimOpacity =
        baseRimOpacity * glowMultiplier.clamp(0, 1) * deletedMultiplier;

    final NeonGlowPaintHelper glowHelper = const DefaultNeonGlowPaintHelper();

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * maxFraction,
        ),
        child: Opacity(
          opacity: deletedOpacity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radius.bubbleMax),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: CustomPaint(
                painter: _RimPainter(
                  color: rimColor,
                  opacity: finalRimOpacity,
                  glowHelper: glowHelper,
                  radius: tokens.radius.bubbleMax,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: padV, horizontal: padH),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(bubbleOpacity),
                    borderRadius: BorderRadius.circular(tokens.radius.bubbleMax),
                    border: Border.all(
                      color: tokens.colors.glassStroke,
                    ),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RimPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final NeonGlowPaintHelper glowHelper;
  final double radius;

  const _RimPainter({
    required this.color,
    required this.opacity,
    required this.glowHelper,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    // Stroke polish.
    final Paint stroke = glowHelper.rimStrokePaint(color, opacity * 0.8);
    canvas.drawRRect(rrect.deflate(0.5), stroke);

    // Rim glow (blurred stroke).
    final Paint glow = glowHelper.rimGlowPaint(color, opacity);
    canvas.drawRRect(rrect.deflate(1.0), glow);
  }

  @override
  bool shouldRepaint(covariant _RimPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.opacity != opacity;
  }
}

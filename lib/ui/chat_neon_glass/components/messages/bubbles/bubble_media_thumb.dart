import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../adapters/ui_message_status.dart';
import '../../../tokens/chat_tokens.dart';

/// Glass-styled media thumbnail for image bubbles.
class BubbleMediaThumb extends StatelessWidget {
  final String imageUrl;
  final ChatTokens tokens;
  final bool isOutgoing;
  final bool isFailed;
  final bool isDeleted;
  final double blurMultiplier; // typically 0..1 based on fast scroll suppression

  const BubbleMediaThumb({
    super.key,
    required this.imageUrl,
    required this.tokens,
    required this.isOutgoing,
    required this.isFailed,
    required this.isDeleted,
    required this.blurMultiplier,
  });

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    final double maxWidth = screen.width * tokens.spacing.bubbleMaxWidthFractionMin;
    final double maxHeight = screen.height * 0.5; // mid of 40–55%

    // Default aspect ratio 4:5 until image loads.
    const double fallbackAspect = 4 / 5;

    final double glassOpacity =
        (tokens.opacity.bubbleBackgroundMin + tokens.opacity.bubbleBackgroundMax) / 2;
    final double blurSigma =
        ((tokens.blur.microMin + tokens.blur.microMax) / 2) * blurMultiplier.clamp(0, 1);

    final Gradient tint = _tintGradient();

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.radius.bubbleMax),
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: Container(
                color: Colors.white.withOpacity(glassOpacity),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final double height = min(constraints.maxHeight, width / fallbackAspect);
                return SizedBox(
                  width: width,
                  height: height,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) {
                      return _FailurePlaceholder(tokens: tokens);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _LoadingPlaceholder(tokens: tokens);
                    },
                  ),
                );
              },
            ),
            // Tint overlay (suppressed if deleted)
            if (!isDeleted)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(gradient: tint),
                  ),
                ),
              ),
            if (isDeleted)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.black.withOpacity(0.55),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Gradient _tintGradient() {
    if (isFailed) {
      return LinearGradient(
        colors: [
          tokens.colors.failedBubbleRim.withOpacity(0.22),
          tokens.colors.failedBubbleInner.withOpacity(0.08),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (isOutgoing) {
      return LinearGradient(
        colors: [
          tokens.colors.outgoingBubbleStart.withOpacity(0.18),
          tokens.colors.outgoingBubbleEnd.withOpacity(0.10),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return LinearGradient(
      colors: [
        tokens.colors.incomingBubbleStart.withOpacity(0.18),
        tokens.colors.incomingBubbleEnd.withOpacity(0.10),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  final ChatTokens tokens;
  const _LoadingPlaceholder({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: tokens.colors.glassFill,
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _FailurePlaceholder extends StatelessWidget {
  final ChatTokens tokens;
  const _FailurePlaceholder({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: tokens.colors.glassFill,
      child: Center(
        child: Icon(
          Icons.error_outline,
          color: tokens.colors.failedBubbleRim,
          size: 20,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Color tokens for the neon–glass chat UI.
///
/// Values are taken directly from `chat-ui-impl.md`.
abstract interface class ChatColorTokens {
  // Background
  Color get bgBase;
  List<Color> get backgroundGradientStops;

  /// Accent glows used across the system.
  Color get bgGlowPurple;
  Color get bgGlowPink;

  /// Allowed blob colors (2–4 blobs choose from this palette).
  List<Color> get blobColors;

  // Text
  Color get textPrimary;
  Color get textSecondary;

  // Glass
  Color get glassStroke;
  Color get glassFill;

  // Bubble rim glow colors (explicit in spec)
  Color get incomingRimGlow;
  Color get outgoingRimGlow;

  // Bubble tint gradients (explicit in spec)
  Color get incomingBubbleStart;
  Color get incomingBubbleEnd;
  Color get outgoingBubbleStart;
  Color get outgoingBubbleEnd;

  // Failed/retry tints (explicit in spec)
  Color get failedBubbleRim;
  Color get failedBubbleInner;
  Color get failedBubbleGlowBase;
  double get failedBubbleGlowOpacityMin;
  double get failedBubbleGlowOpacityMax;
  Color get retryGlowStart;
  Color get retryGlowEnd;
}

/// Default neon–glass chat colors.
final class NeonChatColors implements ChatColorTokens {
  static const NeonChatColors instance = NeonChatColors._();
  const NeonChatColors._();

  @override
  Color get bgBase => const Color(0xFF0B0314);

  @override
  List<Color> get backgroundGradientStops => const <Color>[
        Color(0xFF1B0129),
        Color(0xFF320248),
        Color(0xFF45026A),
        Color(0xFF210034),
      ];

  @override
  Color get bgGlowPurple => const Color(0xFF742BFF);

  @override
  Color get bgGlowPink => const Color(0xFFE624C7);

  @override
  List<Color> get blobColors => const <Color>[
        Color(0xFF7F2BFF),
        Color(0xFFD824C7),
        Color(0xFF9128FF),
      ];

  @override
  Color get textPrimary => const Color(0xF2FFFFFF); // rgba(255,255,255,0.95)

  @override
  Color get textSecondary => const Color(0xA6FFFFFF); // rgba(255,255,255,0.65)

  @override
  Color get glassStroke => const Color(0x1FFFFFFF); // rgba(255,255,255,0.12)

  @override
  Color get glassFill => const Color(0x0DFFFFFF); // rgba(255,255,255,0.05)

  @override
  Color get incomingRimGlow => const Color(0xFF9747FF);

  @override
  Color get outgoingRimGlow => const Color(0xFFE92BD6);

  @override
  Color get incomingBubbleStart => const Color(0xFF4D1FFF);

  @override
  Color get incomingBubbleEnd => const Color(0xFFA46BFF);

  @override
  Color get outgoingBubbleStart => const Color(0xFF9B1BFF);

  @override
  Color get outgoingBubbleEnd => const Color(0xFFF025C2);

  @override
  Color get failedBubbleRim => const Color(0xFFFF4466);

  @override
  Color get failedBubbleInner => const Color(0xFFB3123A);

  @override
  Color get failedBubbleGlowBase => const Color(0xFFFF4466);

  @override
  double get failedBubbleGlowOpacityMin => 0.36;

  @override
  double get failedBubbleGlowOpacityMax => 0.48;

  @override
  Color get retryGlowStart => const Color(0xFFFF6A8A);

  @override
  Color get retryGlowEnd => const Color(0xFFFF98AF);
}

/// Spacing + layout metric tokens for neon–glass chat UI.
///
/// Values are taken directly from `chat-ui-impl.md`.
abstract interface class ChatSpacingTokens {
  // Global spacing scale
  double get xs;
  double get s;
  double get m;
  double get l;
  double get xl;
  double get xxl;

  // Bubble internal padding
  double get bubblePaddingVMin;
  double get bubblePaddingVMax;
  double get bubblePaddingHMin;
  double get bubblePaddingHMax;

  // Bubble max width fraction of screen
  double get bubbleMaxWidthFractionMin;
  double get bubbleMaxWidthFractionMax;

  // Timestamp layout
  double get timestampPaddingFromEdgeMin;
  double get timestampPaddingFromEdgeMax;
  double get timestampDriftPx;

  // Parallax drift amount (px)
  double get parallaxDriftMin;
  double get parallaxDriftMax;
}

final class NeonChatSpacing implements ChatSpacingTokens {
  static const NeonChatSpacing instance = NeonChatSpacing._();
  const NeonChatSpacing._();

  @override
  double get xs => 6.0;

  @override
  double get s => 10.0;

  @override
  double get m => 14.0;

  @override
  double get l => 20.0;

  @override
  double get xl => 28.0;

  @override
  double get xxl => 40.0;

  @override
  double get bubblePaddingVMin => 8.0;

  @override
  double get bubblePaddingVMax => 12.0;

  @override
  double get bubblePaddingHMin => 14.0;

  @override
  double get bubblePaddingHMax => 18.0;

  @override
  double get bubbleMaxWidthFractionMin => 0.68;

  @override
  double get bubbleMaxWidthFractionMax => 0.78;

  @override
  double get timestampPaddingFromEdgeMin => 6.0;

  @override
  double get timestampPaddingFromEdgeMax => 10.0;

  @override
  double get timestampDriftPx => 2.0;

  @override
  double get parallaxDriftMin => 8.0;

  @override
  double get parallaxDriftMax => 12.0;
}

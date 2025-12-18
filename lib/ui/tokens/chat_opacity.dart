/// Opacity tokens for the neon–glass chat UI.
///
/// Values are taken directly from `chat-ui-impl.md`.
abstract interface class ChatOpacityTokens {
  // Bubble translucency
  double get bubbleBackgroundMin;
  double get bubbleBackgroundMax;

  // Rim glow opacities
  double get rimGlowIdleMin;
  double get rimGlowIdleMax;

  double get rimGlowActiveMin;
  double get rimGlowActiveMax;

  double get glowBurstMin;
  double get glowBurstMax;

  // Presence indicator pulse opacity
  double get presencePulseMin;
  double get presencePulseMax;

  // Timestamp opacities
  double get timestampIdleMin;
  double get timestampIdleMax;
  double get timestampIdleRecommended;

  double get timestampActiveMin;
  double get timestampActiveMax;
  double get timestampActiveRecommended;

  double get timestampScrollMinMin;
  double get timestampScrollMinMax;
  double get timestampScrollMinRecommended;

  // Glass standards (from Blur+Glass Standards table)
  double get microGlassOpacityMin;
  double get microGlassOpacityMax;

  double get mediumGlassOpacityMin;
  double get mediumGlassOpacityMax;

  double get heavyGlassOpacityMin;
  double get heavyGlassOpacityMax;
}

/// Default neon–glass chat opacities.
final class NeonChatOpacity implements ChatOpacityTokens {
  static const NeonChatOpacity instance = NeonChatOpacity._();
  const NeonChatOpacity._();

  @override
  double get bubbleBackgroundMin => 0.35;

  @override
  double get bubbleBackgroundMax => 0.55;

  @override
  double get rimGlowIdleMin => 0.10;

  @override
  double get rimGlowIdleMax => 0.18;

  @override
  double get rimGlowActiveMin => 0.18;

  @override
  double get rimGlowActiveMax => 0.26;

  @override
  double get glowBurstMin => 0.28;

  @override
  double get glowBurstMax => 0.40;

  @override
  double get presencePulseMin => 0.15;

  @override
  double get presencePulseMax => 0.30;

  @override
  double get timestampIdleMin => 0.28;

  @override
  double get timestampIdleMax => 0.38;

  @override
  double get timestampIdleRecommended => 0.32;

  @override
  double get timestampActiveMin => 0.65;

  @override
  double get timestampActiveMax => 0.80;

  @override
  double get timestampActiveRecommended => 0.74;

  @override
  double get timestampScrollMinMin => 0.10;

  @override
  double get timestampScrollMinMax => 0.18;

  @override
  double get timestampScrollMinRecommended => 0.12;

  @override
  double get microGlassOpacityMin => 0.04;

  @override
  double get microGlassOpacityMax => 0.06;

  @override
  double get mediumGlassOpacityMin => 0.06;

  @override
  double get mediumGlassOpacityMax => 0.10;

  @override
  double get heavyGlassOpacityMin => 0.12;

  @override
  double get heavyGlassOpacityMax => 0.15;
}

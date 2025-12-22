/// Glow geometry tokens for neon–glass chat UI.
///
/// Values are taken directly from `chat-ui-impl.md`.
abstract interface class ChatGlowTokens {
  // Element rim radius range
  double get rimRadiusMin;
  double get rimRadiusMax;

  // Active rim radius range
  double get activeRimRadiusMin;
  double get activeRimRadiusMax;

  // Burst glow radius range
  double get burstRadiusMin;
  double get burstRadiusMax;
}

final class NeonChatGlow implements ChatGlowTokens {
  static const NeonChatGlow instance = NeonChatGlow._();
  const NeonChatGlow._();

  @override
  double get rimRadiusMin => 4.0;

  @override
  double get rimRadiusMax => 8.0;

  @override
  double get activeRimRadiusMin => 8.0;

  @override
  double get activeRimRadiusMax => 14.0;

  @override
  double get burstRadiusMin => 16.0;

  @override
  double get burstRadiusMax => 42.0;
}

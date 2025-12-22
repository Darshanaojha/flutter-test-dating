/// Radius tokens for neon–glass chat UI.
///
/// Values are taken directly from `chat-ui-impl.md`.
abstract interface class ChatRadiusTokens {
  double get bubbleMin;
  double get bubbleMax;

  double get inputBarMin;
  double get inputBarMax;

  double get buttonMin;
  double get buttonMax;

  // Background blob radius (px)
  double get blobRadiusMin;
  double get blobRadiusMax;
}

final class NeonChatRadius implements ChatRadiusTokens {
  static const NeonChatRadius instance = NeonChatRadius._();
  const NeonChatRadius._();

  @override
  double get bubbleMin => 18.0;

  @override
  double get bubbleMax => 26.0;

  @override
  double get inputBarMin => 32.0;

  @override
  double get inputBarMax => 40.0;

  @override
  double get buttonMin => 20.0;

  @override
  double get buttonMax => 28.0;

  @override
  double get blobRadiusMin => 180.0;

  @override
  double get blobRadiusMax => 320.0;
}

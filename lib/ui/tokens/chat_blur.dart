/// Blur radius tokens for neon–glass chat UI.
///
/// Values are taken directly from `chat-ui-impl.md`.
abstract interface class ChatBlurTokens {
  double get microMin;
  double get microMax;

  double get mediumMin;
  double get mediumMax;

  double get heavyMin;
  double get heavyMax;

  // Timestamp glow blur
  double get timestampGlowMin;
  double get timestampGlowMax;
}

final class NeonChatBlur implements ChatBlurTokens {
  static const NeonChatBlur instance = NeonChatBlur._();
  const NeonChatBlur._();

  @override
  double get microMin => 6.0;

  @override
  double get microMax => 10.0;

  @override
  double get mediumMin => 12.0;

  @override
  double get mediumMax => 18.0;

  @override
  double get heavyMin => 20.0;

  @override
  double get heavyMax => 32.0;

  @override
  double get timestampGlowMin => 2.0;

  @override
  double get timestampGlowMax => 4.0;
}

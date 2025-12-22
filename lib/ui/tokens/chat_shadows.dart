/// Shadow tokens for neon–glass chat UI.
///
/// Values are taken directly from `chat-ui-impl.md`.
abstract interface class ChatShadowTokens {
  // Bubble shadow
  double get bubbleYOffset;
  double get bubbleBlur;
  double get bubbleOpacity;

  // Floating UI shadow
  double get floatingYOffset;
  double get floatingBlur;
  double get floatingOpacity;

  // Input bar upward glow shadow
  double get inputGlowYOffset;
  double get inputGlowBlur;
  double get inputGlowOpacity;
}

final class NeonChatShadows implements ChatShadowTokens {
  static const NeonChatShadows instance = NeonChatShadows._();
  const NeonChatShadows._();

  @override
  double get bubbleYOffset => 2.0;

  @override
  double get bubbleBlur => 12.0;

  @override
  double get bubbleOpacity => 0.18;

  @override
  double get floatingYOffset => 4.0;

  @override
  double get floatingBlur => 16.0;

  @override
  double get floatingOpacity => 0.22;

  @override
  double get inputGlowYOffset => -2.0;

  @override
  double get inputGlowBlur => 8.0;

  @override
  double get inputGlowOpacity => 0.30;
}

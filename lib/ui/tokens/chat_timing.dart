/// Timing (duration) tokens for neon–glass chat UI.
///
/// Values are taken directly from `chat-ui-impl.md`.
abstract interface class ChatTimingTokens {
  Duration get fadeShortMin;
  Duration get fadeShortMax;

  Duration get fadeMediumMin;
  Duration get fadeMediumMax;

  Duration get fadeLongMin;
  Duration get fadeLongMax;

  Duration get scaleSpringFastMin;
  Duration get scaleSpringFastMax;

  Duration get scaleSpringNormalMin;
  Duration get scaleSpringNormalMax;

  Duration get timestampFadeMin;
  Duration get timestampFadeMax;

  Duration get scrollSettleMin;
  Duration get scrollSettleMax;

  Duration get particleDriftMin;
  Duration get particleDriftMax;

  // Fixed durations
  Duration get typingIndicatorLoop;
  Duration get sendRipple;
  Duration get deliveredPulse;
}

final class NeonChatTiming implements ChatTimingTokens {
  static const NeonChatTiming instance = NeonChatTiming._();
  const NeonChatTiming._();

  @override
  Duration get fadeShortMin => const Duration(milliseconds: 120);

  @override
  Duration get fadeShortMax => const Duration(milliseconds: 180);

  @override
  Duration get fadeMediumMin => const Duration(milliseconds: 200);

  @override
  Duration get fadeMediumMax => const Duration(milliseconds: 260);

  @override
  Duration get fadeLongMin => const Duration(milliseconds: 320);

  @override
  Duration get fadeLongMax => const Duration(milliseconds: 420);

  @override
  Duration get scaleSpringFastMin => const Duration(milliseconds: 180);

  @override
  Duration get scaleSpringFastMax => const Duration(milliseconds: 220);

  @override
  Duration get scaleSpringNormalMin => const Duration(milliseconds: 220);

  @override
  Duration get scaleSpringNormalMax => const Duration(milliseconds: 300);

  @override
  Duration get timestampFadeMin => const Duration(milliseconds: 140);

  @override
  Duration get timestampFadeMax => const Duration(milliseconds: 240);

  @override
  Duration get scrollSettleMin => const Duration(milliseconds: 220);

  @override
  Duration get scrollSettleMax => const Duration(milliseconds: 360);

  @override
  Duration get particleDriftMin => const Duration(milliseconds: 2400);

  @override
  Duration get particleDriftMax => const Duration(milliseconds: 4000);

  @override
  Duration get typingIndicatorLoop => const Duration(milliseconds: 900);

  @override
  Duration get sendRipple => const Duration(milliseconds: 450);

  @override
  Duration get deliveredPulse => const Duration(milliseconds: 400);
}

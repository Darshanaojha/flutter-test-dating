import 'package:flutter/animation.dart';

/// Motion curves for neon–glass chat UI.
///
/// Values are taken directly from `chat-ui-impl.md`.
abstract interface class ChatMotionCurves {
  Curve get bubbleAppear;
  Curve get fade;
  Curve get sendRipple;
  Curve get typing;
  Curve get scrollSettle;
}

final class NeonChatMotionCurves implements ChatMotionCurves {
  static const NeonChatMotionCurves instance = NeonChatMotionCurves._();
  const NeonChatMotionCurves._();

  @override
  Curve get bubbleAppear => const Cubic(0.18, 0.89, 0.32, 1.28);

  @override
  Curve get fade => Curves.easeOutCubic;

  @override
  Curve get sendRipple => Curves.easeOutQuint;

  @override
  Curve get typing => Curves.easeInOutQuad;

  @override
  Curve get scrollSettle => Curves.easeOutCubic;
}

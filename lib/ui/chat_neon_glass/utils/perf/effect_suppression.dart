import 'dart:ui';

import '../../state_machine/chat_state.dart';
import '../../../tokens/chat_tokens.dart';
import 'frame_budget_signals.dart';

/// Central policy object for suppressing expensive effects.
///
/// Derived from [ChatUiState] (fast scroll, settle) and optional frame signals.
abstract interface class EffectSuppressionPolicy {
  bool suppressNoise(ChatUiState state);
  double blurMultiplier(ChatUiState state);
  double glowMultiplier(ChatUiState state);
  double particleMultiplier(ChatUiState state);
  double timestampOpacityMultiplier(ChatUiState state);
}

/// Default suppression policy aligned with the spec:
/// - During fast scroll (or frame pressure), suppress heavy glow/blur/particles.
/// - Timestamp opacity fades down toward the spec minimum.
///
/// Note: The spec does not define partial multipliers for blur/glow/particles,
/// only that they should be reduced/suppressed. We therefore treat them as
/// on/off (1.0 vs 0.0) to avoid inventing tuning constants outside tokens.
final class DefaultEffectSuppressionPolicy implements EffectSuppressionPolicy {
  final ChatTokens tokens;
  final FrameBudgetSignals frameBudget;

  // Smoothed velocity + previous multipliers to reduce flicker.
  double _smoothedVelocity = 0.0;
  double _prevBlur = 1.0;
  double _prevGlow = 1.0;
  double _prevParticle = 1.0;

  DefaultEffectSuppressionPolicy({
    required this.tokens,
    required this.frameBudget,
  });

  bool _suppressed(ChatUiState state, double rawVelocity) {
    _smoothedVelocity = lerpDouble(_smoothedVelocity, rawVelocity, 0.15)!;
    final bool fast = _smoothedVelocity >= 0.5 || frameBudget.isUnderPressure;
    return fast;
  }

  @override
  bool suppressNoise(ChatUiState state) {
    final double rawV = _rawVelocityFor(state);
    final bool sup = _suppressed(state, rawV);
    return sup;
  }

  @override
  double blurMultiplier(ChatUiState state) {
    final double rawV = _rawVelocityFor(state);
    final bool sup = _suppressed(state, rawV);
    final double target = sup ? 0.0 : 1.0;
    _prevBlur = lerpDouble(_prevBlur, target, 0.12)!.clamp(0.35, 1.0);
    return _prevBlur;
  }

  @override
  double glowMultiplier(ChatUiState state) {
    final double rawV = _rawVelocityFor(state);
    final bool sup = _suppressed(state, rawV);
    final double target = sup ? 0.0 : 1.0;
    _prevGlow = lerpDouble(_prevGlow, target, 0.10)!.clamp(0.25, 1.0);
    return _prevGlow;
  }

  @override
  double particleMultiplier(ChatUiState state) {
    final double rawV = _rawVelocityFor(state);
    final bool sup = _suppressed(state, rawV);
    final double target = sup ? 0.0 : 1.0;
    _prevParticle =
        lerpDouble(_prevParticle, target, 0.08)!.clamp(0.20, 1.0);
    return _prevParticle;
  }

  @override
  double timestampOpacityMultiplier(ChatUiState state) {
    // Spec: timestamps fade to a minimum opacity during fast scroll.
    final double rawV = _rawVelocityFor(state);
    if (!_suppressed(state, rawV)) return 1.0;

    final double idle = tokens.opacity.timestampIdleRecommended;
    final double min = tokens.opacity.timestampScrollMinRecommended;
    if (idle <= 0) return 1.0;
    return (min / idle).clamp(0.0, 1.0);
  }

  double _rawVelocityFor(ChatUiState state) {
    switch (state.scrollPhase) {
      case ChatScrollPhase.fast:
        return 1.0;
      case ChatScrollPhase.settle:
        return 0.35;
      case ChatScrollPhase.idle:
      default:
        return 0.0;
    }
  }
}

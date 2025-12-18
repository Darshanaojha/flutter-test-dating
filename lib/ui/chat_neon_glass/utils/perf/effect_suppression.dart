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

  const DefaultEffectSuppressionPolicy({
    required this.tokens,
    required this.frameBudget,
  });

  bool _suppressed(ChatUiState state) {
    return frameBudget.isUnderPressure || state.scrollPhase == ChatScrollPhase.fast;
  }

  @override
  bool suppressNoise(ChatUiState state) => _suppressed(state);

  @override
  double blurMultiplier(ChatUiState state) => _suppressed(state) ? 0.0 : 1.0;

  @override
  double glowMultiplier(ChatUiState state) => _suppressed(state) ? 0.0 : 1.0;

  @override
  double particleMultiplier(ChatUiState state) => _suppressed(state) ? 0.0 : 1.0;

  @override
  double timestampOpacityMultiplier(ChatUiState state) {
    // Spec: timestamps fade to a minimum opacity during fast scroll.
    if (!_suppressed(state)) return 1.0;

    final double idle = tokens.opacity.timestampIdleRecommended;
    final double min = tokens.opacity.timestampScrollMinRecommended;
    if (idle <= 0) return 1.0;
    return (min / idle).clamp(0.0, 1.0);
  }
}

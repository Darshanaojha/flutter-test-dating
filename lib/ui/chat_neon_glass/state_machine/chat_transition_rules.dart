import 'chat_events.dart';
import 'chat_state.dart';

/// Transition rules for chat state machine.
///
/// Deterministic reducer for chat UI state.
abstract interface class ChatTransitionRules {
  ChatUiState reduce(ChatUiState current, ChatEvent event);
}

/// Default transition rules for the neon–glass chat state machine.
///
/// The spec defines velocity thresholds but does not provide concrete numbers,
/// so they are injected.
final class DefaultChatTransitionRules implements ChatTransitionRules {
  /// Absolute px/s at or above which scrolling enters [ChatScrollPhase.fast].
  final double fastScrollThresholdPxPerSec;

  /// Absolute px/s at or below which fast scrolling transitions to settle.
  final double settleThresholdPxPerSec;

  const DefaultChatTransitionRules({
    required this.fastScrollThresholdPxPerSec,
    required this.settleThresholdPxPerSec,
  });

  @override
  ChatUiState reduce(ChatUiState current, ChatEvent event) {
    if (event is ChatScrollVelocityChanged) {
      final double v = event.pixelsPerSecond.abs();
      final ChatScrollPhase nextPhase;

      if (v >= fastScrollThresholdPxPerSec) {
        nextPhase = ChatScrollPhase.fast;
      } else if (current.scrollPhase == ChatScrollPhase.fast &&
          v <= settleThresholdPxPerSec) {
        nextPhase = ChatScrollPhase.settle;
      } else if (v == 0) {
        nextPhase = ChatScrollPhase.idle;
      } else {
        // Preserve existing phase unless a threshold boundary is crossed.
        nextPhase = current.scrollPhase;
      }

      return ChatUiState(
        scrollPhase: nextPhase,
        inputMode: current.inputMode,
        activeMessageId: current.activeMessageId,
      );
    }

    if (event is ChatInputModeChanged) {
      final ChatInputMode mode =
          event.isTyping ? ChatInputMode.typing : ChatInputMode.idle;
      return ChatUiState(
        scrollPhase: current.scrollPhase,
        inputMode: mode,
        activeMessageId: current.activeMessageId,
      );
    }

    if (event is ChatMessageActivated) {
      return ChatUiState(
        scrollPhase: current.scrollPhase,
        inputMode: current.inputMode,
        activeMessageId: event.messageId,
      );
    }

    // ChatMessageUpdated does not change global UI state by default; visual
    // effects will be driven later by widgets/animations.
    return current;
  }
}

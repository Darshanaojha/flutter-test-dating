import 'package:flutter/foundation.dart';

/// High-level input mode states (no voice/video/call).
enum ChatInputMode {
  idle,
  typing,
}

/// High-level scrolling phases used for effect suppression.
enum ChatScrollPhase {
  idle,
  fast,
  settle,
}

/// UI state for the neon–glass chat screen state machine.
///
/// This is UI-only and must be derived from backend states + UI interactions.
@immutable
class ChatUiState {
  final ChatScrollPhase scrollPhase;
  final ChatInputMode inputMode;

  /// Active message (e.g., long-pressed) for timestamp emphasis.
  final String? activeMessageId;

  const ChatUiState({
    required this.scrollPhase,
    required this.inputMode,
    this.activeMessageId,
  });
}

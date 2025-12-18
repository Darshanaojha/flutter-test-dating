import 'chat_events.dart';
import 'chat_state.dart';
import 'chat_transition_rules.dart';

/// ChatScreenStateMachine interface.
abstract interface class ChatStateMachine {
  ChatUiState get state;
  ChatTransitionRules get rules;

  void dispatch(ChatEvent event);

  Stream<ChatUiState> watchState();
}

/// Deterministic state machine implementation for chat UI state.
///
/// Uses a reducer ([ChatTransitionRules]) to produce next state and broadcasts
/// it to listeners. This class contains no animation logic.
final class DefaultChatStateMachine implements ChatStateMachine {
  ChatUiState _state;
  @override
  final ChatTransitionRules rules;

  final StreamController<ChatUiState> _stateController =
      StreamController<ChatUiState>.broadcast();

  DefaultChatStateMachine({
    required ChatUiState initialState,
    required this.rules,
  }) : _state = initialState;

  @override
  ChatUiState get state => _state;

  @override
  void dispatch(ChatEvent event) {
    final ChatUiState next = rules.reduce(_state, event);
    if (identical(next, _state)) return;

    // Deterministic structural equality is not implemented; compare fields.
    final bool changed = next.scrollPhase != _state.scrollPhase ||
        next.inputMode != _state.inputMode ||
        next.activeMessageId != _state.activeMessageId;
    if (!changed) return;

    _state = next;
    _stateController.add(_state);
  }

  @override
  Stream<ChatUiState> watchState() => _stateController.stream;
}

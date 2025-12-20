import '../adapters/message_adapter.dart';
import '../adapters/ui_message.dart';
import '../state_machine/chat_events.dart';
import '../state_machine/chat_state_machine.dart';
import '../state_machine/chat_state.dart';
import 'haptics_hooks.dart';
import 'message_stream_bridge.dart';
import 'sound_hooks.dart';

/// UI-only controller contract for the neon–glass chat screen.
///
/// This layer:
/// - Consumes existing backend streams via [MessageStreamBridge]
/// - Maps backend messages via [MessageAdapter]
/// - Exposes UI-ready [UIMessage] streams and state-machine state
///
/// IMPORTANT: Do not modify backend logic or schemas.
abstract interface class NeonChatController {
  MessageStreamBridge get bridge;
  MessageAdapter get adapter;

  ChatSoundHooks? get soundHooks;
  ChatHapticsHooks? get hapticsHooks;

  ChatStateMachine get stateMachine;

  Stream<List<UIMessage>> watchUiMessages();

  Stream<ChatUiState> watchState();
}

/// Default UI-layer controller implementation.
///
/// Responsibilities:
/// - Subscribe to [MessageStreamBridge] list updates (no backend mutation)
/// - Map each backend message via [MessageAdapter] into immutable [UIMessage]
/// - Provide deterministic ordering (sort by timestamp then id) since backend
///   ordering is not guaranteed
/// - Forward state transitions through [ChatStateMachine]
///
/// Notes:
/// - No animations are implemented here; only state/signals.
/// - No voice/video/call features.
final class DefaultNeonChatController implements NeonChatController {
  @override
  final MessageStreamBridge bridge;

  @override
  final MessageAdapter adapter;

  @override
  final ChatSoundHooks? soundHooks;

  @override
  final ChatHapticsHooks? hapticsHooks;

  @override
  final ChatStateMachine stateMachine;

  const DefaultNeonChatController({
    required this.bridge,
    required this.adapter,
    required this.stateMachine,
    this.soundHooks,
    this.hapticsHooks,
  });

  @override
  Stream<List<UIMessage>> watchUiMessages() {
    return bridge.watchConversationMessages().map((rawList) {
      print("NEON: controller mapping raw list count=${rawList.length}");
      try {
        final List<UIMessage> mapped = adapter.fromRawList(rawList);
        print("NEON: controller mapped UI list count=${mapped.length}");

        // Deterministic ordering: timestamp ascending, then id.
        final List<UIMessage> sorted = List<UIMessage>.of(mapped);
        sorted.sort((a, b) {
          final int t = a.timestamp.compareTo(b.timestamp);
          if (t != 0) return t;
          return a.id.compareTo(b.id);
        });

        // Emit immutable list instance.
        final List<UIMessage> out = List<UIMessage>.unmodifiable(sorted);

        // Drive state machine with message updates (deterministic per list emission).
        for (final UIMessage m in out) {
          stateMachine.dispatch(ChatMessageUpdated(m));
        }

        return out;
      } catch (e, st) {
        print("NEON: controller mapping error=$e\n$st");
        return const <UIMessage>[];
      }
    });
  }

  @override
  Stream<ChatUiState> watchState() => stateMachine.watchState();
}

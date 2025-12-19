import 'dart:async';

import 'package:flutter/material.dart';

import 'ui/chat_neon_glass/adapters/message_adapter.dart';
import 'ui/chat_neon_glass/adapters/raw_backend_message.dart';
import 'ui/chat_neon_glass/adapters/ui_message.dart';
import 'ui/chat_neon_glass/adapters/ui_message_status.dart';
import 'ui/chat_neon_glass/controllers/haptics_hooks.dart';
import 'ui/chat_neon_glass/controllers/message_stream_bridge.dart';
import 'ui/chat_neon_glass/controllers/neon_chat_controller.dart';
import 'ui/chat_neon_glass/controllers/sound_hooks.dart';
import 'ui/chat_neon_glass/neon_chat_screen.dart';
import 'ui/chat_neon_glass/state_machine/chat_events.dart';
import 'ui/chat_neon_glass/state_machine/chat_state.dart';
import 'ui/chat_neon_glass/state_machine/chat_state_machine.dart';
import 'ui/chat_neon_glass/state_machine/chat_transition_rules.dart';
import 'ui/chat_neon_glass/utils/perf/effect_suppression.dart';
import 'ui/chat_neon_glass/utils/perf/frame_budget_signals.dart';
import 'ui/chat_neon_glass/utils/perf/scroll_velocity_tracker.dart';
import 'ui/tokens/chat_tokens.dart';

/// Temporary dev-only preview for the neon glass chat UI.
/// - No backend access.
/// - Mocked controller + timers drive delivery/seen/failed flows.
/// - Wire `main.dart` to `ChatPreviewApp()` manually when testing.
class ChatPreviewApp extends StatefulWidget {
  const ChatPreviewApp({super.key});

  @override
  State<ChatPreviewApp> createState() => _ChatPreviewAppState();
}

class _ChatPreviewAppState extends State<ChatPreviewApp> {
  late final ChatTokens _tokens;
  late final EffectSuppressionPolicy _effectPolicy;
  late final DefaultChatStateMachine _stateMachine;
  late final ScrollVelocityTracker _velocityTracker;
  late final MockNeonChatController _controller;

  final List<Timer> _timers = <Timer>[];
  bool _isPeerTyping = false;

  @override
  void initState() {
    super.initState();
    _tokens = NeonChatTokens.instance;
    _stateMachine = DefaultChatStateMachine(
      initialState: const ChatUiState(
        scrollPhase: ChatScrollPhase.idle,
        inputMode: ChatInputMode.idle,
        activeMessageId: null,
      ),
      rules: const DefaultChatTransitionRules(
        fastScrollThresholdPxPerSec: 1600,
        settleThresholdPxPerSec: 400,
      ),
    );
    _velocityTracker =
        BasicScrollVelocityTracker(fastScrollThresholdPxPerSec: 1600);
    _effectPolicy = DefaultEffectSuppressionPolicy(
      tokens: _tokens,
      frameBudget: const StaticFrameBudgetSignals(isUnderPressure: false),
    );
    _controller = MockNeonChatController(stateMachine: _stateMachine);

    _seedMessages();
    _scheduleDemoTimeline();
  }

  @override
  void dispose() {
    for (final Timer t in _timers) {
      t.cancel();
    }
    _controller.dispose();
    super.dispose();
  }

  void _seedMessages() {
    final DateTime base = DateTime.now().subtract(const Duration(minutes: 1));
    _controller.seed(<UIMessage>[
      UIMessage(
        id: 'o1',
        timestamp: base,
        status: UIMessageStatus.pending,
        isOutgoing: true,
        text: 'Shipping the neon glass UI — watch the states roll.',
      ),
      UIMessage(
        id: 'i1',
        timestamp: base.add(const Duration(seconds: 10)),
        status: UIMessageStatus.delivered,
        isOutgoing: false,
        text: 'Looks amazing from the receiver side already.',
      ),
      UIMessage(
        id: 'o2_failed',
        timestamp: base.add(const Duration(seconds: 20)),
        status: UIMessageStatus.failed,
        isOutgoing: true,
        text: 'This one intentionally fails — tap retry.',
      ),
      UIMessage(
        id: 'i2',
        timestamp: base.add(const Duration(seconds: 30)),
        status: UIMessageStatus.sent,
        isOutgoing: false,
        text: 'I see a failure icon on that bubble.',
      ),
      UIMessage(
        id: 'o3',
        timestamp: base.add(const Duration(seconds: 40)),
        status: UIMessageStatus.sent,
        isOutgoing: true,
        text: 'On it — sending a follow-up.',
      ),
      UIMessage(
        id: 'i3',
        timestamp: base.add(const Duration(seconds: 50)),
        status: UIMessageStatus.seen,
        isOutgoing: false,
        text: 'Thanks! Animations look smooth.',
      ),
    ]);
  }

  void _scheduleDemoTimeline() {
    // Pending -> sent -> delivered -> seen for the first outgoing.
    _enqueue(const Duration(milliseconds: 900),
        () => _controller.updateStatus('o1', UIMessageStatus.sent));
    _enqueue(const Duration(seconds: 2),
        () => _controller.updateStatus('o1', UIMessageStatus.delivered));
    _enqueue(const Duration(seconds: 3),
        () => _controller.updateStatus('o1', UIMessageStatus.seen));

    // Advance a second outgoing.
    _enqueue(const Duration(seconds: 2),
        () => _controller.updateStatus('o3', UIMessageStatus.delivered));
    _enqueue(const Duration(seconds: 4),
        () => _controller.updateStatus('o3', UIMessageStatus.seen));

    // Typing bursts from peer.
    _enqueue(const Duration(seconds: 1), () => _setPeerTyping(true));
    _enqueue(const Duration(seconds: 3), () => _setPeerTyping(false));
    _enqueue(const Duration(seconds: 6), () => _setPeerTyping(true));
    _enqueue(const Duration(seconds: 8), () => _setPeerTyping(false));
  }

  void _enqueue(Duration delay, VoidCallback fn) {
    _timers.add(Timer(delay, fn));
  }

  void _setPeerTyping(bool value) {
    setState(() {
      _isPeerTyping = value;
    });
    _stateMachine.dispatch(ChatInputModeChanged(isTyping: value));
  }

  void _scheduleStatusChain(
    String id, {
    Duration initialDelay = const Duration(milliseconds: 500),
    Duration step = const Duration(seconds: 1),
  }) {
    Duration t = initialDelay;
    for (final UIMessageStatus s
        in const <UIMessageStatus>[UIMessageStatus.sent, UIMessageStatus.delivered, UIMessageStatus.seen]) {
      _enqueue(t, () => _controller.updateStatus(id, s));
      t += step;
    }
  }

  void _handleSendText(String text) {
    final UIMessage msg = _controller.appendOutgoingText(text);
    _scheduleStatusChain(msg.id);
  }

  void _handleRetry(UIMessage failed) {
    final UIMessage replacement = _controller.replaceWithRetry(failed);
    _scheduleStatusChain(
      replacement.id,
      initialDelay: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: NeonChatScreen(
          controller: _controller,
          tokens: _tokens,
          effectPolicy: _effectPolicy,
          stateMachine: _stateMachine,
          velocityTracker: _velocityTracker,
          onSendText: _handleSendText,
          onRetry: _handleRetry,
          isPeerTyping: _isPeerTyping,
          onAttach: () {},
          onTextChanged: (value) => _stateMachine
              .dispatch(ChatInputModeChanged(isTyping: value.trim().isNotEmpty)),
        ),
      ),
    );
  }
}

/// Minimal mock controller that never touches backend layers.
class MockNeonChatController implements NeonChatController {
  @override
  final MessageStreamBridge bridge = const _DevNullMessageStreamBridge();

  @override
  final MessageAdapter adapter = const _DevNullMessageAdapter();

  @override
  final ChatSoundHooks? soundHooks = null;

  @override
  final ChatHapticsHooks? hapticsHooks = null;

  @override
  final ChatStateMachine stateMachine;

  final StreamController<List<UIMessage>> _messagesController =
      StreamController<List<UIMessage>>.broadcast();

  List<UIMessage> _messages = <UIMessage>[];

  MockNeonChatController({required this.stateMachine});

  void seed(List<UIMessage> seedMessages) {
    _messages = List<UIMessage>.of(seedMessages);
    _emit();
  }

  UIMessage appendOutgoingText(String text) {
    final DateTime ts = DateTime.now();
    final UIMessage msg = UIMessage(
      id: 'local_${ts.millisecondsSinceEpoch}',
      timestamp: ts,
      status: UIMessageStatus.pending,
      isOutgoing: true,
      text: text,
    );
    _messages = <UIMessage>[..._messages, msg];
    _emit();
    return msg;
  }

  UIMessage replaceWithRetry(UIMessage failed) {
    final UIMessageStatus status = failed.status;
    if (status != UIMessageStatus.failed) return failed;

    final DateTime ts = DateTime.now();
    final UIMessage retry = UIMessage(
      id: '${failed.id}_retry_${ts.millisecondsSinceEpoch}',
      timestamp: ts,
      status: UIMessageStatus.pending,
      isOutgoing: true,
      text: failed.text,
      imageUrl: failed.imageUrl,
    );

    _messages = _messages
        .where((m) => m.id != failed.id)
        .toList(growable: true)
      ..add(retry);
    _emit();
    return retry;
  }

  void updateStatus(String id, UIMessageStatus status) {
    _messages = _messages
        .map((m) => m.id == id
            ? UIMessage(
                id: m.id,
                timestamp: m.timestamp,
                status: status,
                isOutgoing: m.isOutgoing,
                text: m.text,
                imageUrl: m.imageUrl,
              )
            : m)
        .toList(growable: false);
    _emit();
  }

  void _emit() {
    final List<UIMessage> sorted = List<UIMessage>.of(_messages);
    sorted.sort((a, b) {
      final int t = a.timestamp.compareTo(b.timestamp);
      if (t != 0) return t;
      return a.id.compareTo(b.id);
    });
    final List<UIMessage> immutable = List<UIMessage>.unmodifiable(sorted);

    for (final UIMessage m in immutable) {
      stateMachine.dispatch(ChatMessageUpdated(m));
    }

    _messagesController.add(immutable);
  }

  @override
  Stream<List<UIMessage>> watchUiMessages() => _messagesController.stream;

  @override
  Stream<ChatUiState> watchState() => stateMachine.watchState();

  void dispose() {
    _messagesController.close();
  }
}

/// Stub bridge to satisfy the controller contract without backend calls.
class _DevNullMessageStreamBridge implements MessageStreamBridge {
  const _DevNullMessageStreamBridge();

  @override
  Stream<List<RawBackendMessage>> watchConversationMessages() =>
      const Stream<List<RawBackendMessage>>.empty();

  @override
  Stream<RawBackendMessage> watchMessageEvents() =>
      const Stream<RawBackendMessage>.empty();
}

/// Stub adapter that is never invoked in the mock flow.
class _DevNullMessageAdapter implements MessageAdapter {
  const _DevNullMessageAdapter();

  @override
  UIMessage fromRaw(RawBackendMessage raw) =>
      throw UnimplementedError('Dev preview uses UI messages only.');

  @override
  List<UIMessage> fromRawList(Iterable<RawBackendMessage> raws) =>
      const <UIMessage>[];
}

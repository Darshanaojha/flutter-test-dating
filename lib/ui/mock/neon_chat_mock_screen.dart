import 'dart:async';

import 'package:flutter/material.dart';

import '../chat_neon_glass/adapters/ui_message.dart';
import '../chat_neon_glass/adapters/ui_message_status.dart';
import '../chat_neon_glass/controllers/haptics_hooks.dart';
import '../chat_neon_glass/controllers/neon_chat_controller.dart';
import '../chat_neon_glass/controllers/sound_hooks.dart';
import '../chat_neon_glass/neon_chat_screen.dart';
import '../chat_neon_glass/state_machine/chat_state.dart';
import '../chat_neon_glass/state_machine/chat_state_machine.dart';
import '../chat_neon_glass/state_machine/chat_transition_rules.dart';
import '../chat_neon_glass/utils/perf/effect_suppression.dart';
import '../chat_neon_glass/utils/perf/frame_budget_signals.dart';
import '../chat_neon_glass/utils/perf/scroll_velocity_tracker.dart';
import '../chat_neon_glass/tokens/chat_tokens.dart';

/// Run this screen standalone to visualize the neon chat UI with mock data.
class NeonChatMockScreen extends StatefulWidget {
  const NeonChatMockScreen({super.key});

  @override
  State<NeonChatMockScreen> createState() => _NeonChatMockScreenState();
}

class _NeonChatMockScreenState extends State<NeonChatMockScreen> {
  late final MockNeonChatController _controller;
  late final DefaultChatStateMachine _stateMachine;
  late final BasicScrollVelocityTracker _velocityTracker;
  late final DefaultEffectSuppressionPolicy _effectPolicy;
  bool _isPeerTyping = false;

  @override
  void initState() {
    super.initState();
    final tokens = NeonChatTokens.instance;
    _stateMachine = DefaultChatStateMachine(
      initialState: const ChatUiState(
        scrollPhase: ChatScrollPhase.idle,
        inputMode: ChatInputMode.idle,
        activeMessageId: null,
      ),
      rules: const DefaultChatTransitionRules(
        fastScrollThresholdPxPerSec: 1200,
        settleThresholdPxPerSec: 200,
      ),
    );
    _velocityTracker =
        BasicScrollVelocityTracker(fastScrollThresholdPxPerSec: 1200);
    _effectPolicy = DefaultEffectSuppressionPolicy(
      tokens: tokens,
      frameBudget: const StaticFrameBudgetSignals(isUnderPressure: false),
    );
    _controller = MockNeonChatController(
      stateMachine: _stateMachine,
      soundHooks: const _MockSoundHooks(),
      hapticsHooks: const _MockHapticsHooks(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NeonChatTokens.instance;
    return MaterialApp(
      home: NeonChatScreen(
        controller: _controller,
        tokens: tokens,
        effectPolicy: _effectPolicy,
        stateMachine: _stateMachine,
        velocityTracker: _velocityTracker,
        isPeerTyping: _isPeerTyping,
        onAttach: () {
          debugPrint('Mock attach tapped');
        },
        onSendText: (text) {
          _controller.sendOutgoing(text);
        },
        onTextChanged: (_) {},
        onRetry: (msg) => _controller.retry(msg),
        onBlockUser: (msg) => debugPrint('Mock block user from message ${msg.id}'),
        onReportUser: (msg) => debugPrint('Mock report user from message ${msg.id}'),
        soundHooks: _controller.soundHooks,
        hapticsHooks: _controller.hapticsHooks,
      ),
    );
  }
}

class MockNeonChatController implements NeonChatController {
  final ChatSoundHooks? soundHooks;
  final ChatHapticsHooks? hapticsHooks;
  final ChatStateMachine _stateMachine;
  final StreamController<List<UIMessage>> _stream =
      StreamController<List<UIMessage>>.broadcast();
  final List<UIMessage> _messages = <UIMessage>[];

  MockNeonChatController({
    required ChatStateMachine stateMachine,
    this.soundHooks,
    this.hapticsHooks,
  }) : _stateMachine = stateMachine {
    _seedInitial();
  }

  void _seedInitial() {
    final now = DateTime.now();
    _messages.addAll([
      UIMessage(
        id: 'm1',
        timestamp: now.subtract(const Duration(minutes: 3)),
        status: UIMessageStatus.seen,
        isOutgoing: false,
        text: 'Hey there 👋',
        imageUrl: null,
      ),
      UIMessage(
        id: 'm2',
        timestamp: now.subtract(const Duration(minutes: 2)),
        status: UIMessageStatus.delivered,
        isOutgoing: true,
        text: 'Testing neon glass UI!',
        imageUrl: null,
      ),
      UIMessage(
        id: 'm3',
        timestamp: now.subtract(const Duration(minutes: 1)),
        status: UIMessageStatus.failed,
        isOutgoing: true,
        text: 'This one will fail.',
        imageUrl: null,
      ),
    ]);
    _push();
  }

  void _push() {
    _stream.add(List<UIMessage>.unmodifiable(_messages));
  }

  @override
  MessageStreamBridge get bridge => const _NullBridge();

  @override
  MessageAdapter get adapter => const _NullAdapter();

  @override
  ChatSoundHooks? get soundHooks => this.soundHooks;

  @override
  ChatHapticsHooks? get hapticsHooks => this.hapticsHooks;

  @override
  ChatStateMachine get stateMachine => _stateMachine;

  @override
  Stream<List<UIMessage>> watchUiMessages() => _stream.stream;

  @override
  Stream<ChatUiState> watchState() => _stateMachine.watchState();

  void sendOutgoing(String text) {
    final now = DateTime.now();
    final String id = 'msg_${now.microsecondsSinceEpoch}';
    final UIMessage pending = UIMessage(
      id: id,
      timestamp: now,
      status: UIMessageStatus.pending,
      isOutgoing: true,
      text: text,
      imageUrl: null,
    );
    _messages.add(pending);
    _push();
    _simulateDelivery(id);
  }

  void retry(UIMessage message) {
    final int idx = _messages.indexWhere((m) => m.id == message.id);
    if (idx == -1) return;
    _messages[idx] = _messages[idx].copyWith(status: UIMessageStatus.pending);
    _push();
    _simulateDelivery(message.id);
  }

  void _simulateDelivery(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _updateStatus(id, UIMessageStatus.sent);
    await Future.delayed(const Duration(milliseconds: 700));
    _updateStatus(id, UIMessageStatus.delivered);
    await Future.delayed(const Duration(milliseconds: 700));
    _updateStatus(id, UIMessageStatus.seen);
  }

  void _updateStatus(String id, UIMessageStatus status) {
    final int idx = _messages.indexWhere((m) => m.id == id);
    if (idx == -1) return;
    final UIMessage m = _messages[idx].copyWith(status: status);
    _messages[idx] = m;
    _push();
  }
}

class _NullBridge implements MessageStreamBridge {
  const _NullBridge();
  @override
  Stream<List<RawBackendMessage>> watchConversationMessages() =>
      const Stream.empty();
  @override
  Stream<RawBackendMessage> watchMessageEvents() => const Stream.empty();
}

class _NullAdapter implements MessageAdapter {
  const _NullAdapter();
  @override
  UIMessage fromRaw(RawBackendMessage raw) => throw UnimplementedError();

  @override
  List<UIMessage> fromRawList(Iterable<RawBackendMessage> raws) =>
      const <UIMessage>[];
}

class _MockSoundHooks implements ChatSoundHooks {
  const _MockSoundHooks();
  @override
  void onMessageDelivered(UIMessage message) {
    debugPrint('Sound: delivered ${message.id}');
  }

  @override
  void onMessageFailed(UIMessage message) {
    debugPrint('Sound: failed ${message.id}');
  }

  @override
  void onMessageReceived(UIMessage message) {
    debugPrint('Sound: received ${message.id}');
  }

  @override
  void onMessageRetry(UIMessage message) {
    debugPrint('Sound: retry ${message.id}');
  }

  @override
  void onMessageSeen(UIMessage message) {
    debugPrint('Sound: seen ${message.id}');
  }

  @override
  void onMessageSent(UIMessage message) {
    debugPrint('Sound: sent ${message.id}');
  }

  @override
  void onOpenChat() {
    debugPrint('Sound: open chat');
  }
}

class _MockHapticsHooks implements ChatHapticsHooks {
  const _MockHapticsHooks();
  @override
  void onLongPressMessage(UIMessage message) {
    debugPrint('Haptic: long press ${message.id}');
  }

  @override
  void onMessageDelivered(UIMessage message) {
    debugPrint('Haptic: delivered ${message.id}');
  }

  @override
  void onMessageRetry(UIMessage message) {
    debugPrint('Haptic: retry ${message.id}');
  }

  @override
  void onMessageSeen(UIMessage message) {
    debugPrint('Haptic: seen ${message.id}');
  }

  @override
  void onScrollBounce() {
    debugPrint('Haptic: scroll bounce');
  }

  @override
  void onSendMessage(UIMessage message) {
    debugPrint('Haptic: send ${message.id}');
  }
}

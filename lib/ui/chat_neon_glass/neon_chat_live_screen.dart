import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt_shared_preferences/provider.dart';

import '../../Controllers/controller.dart';
import '../../Providers/WebsocketService.dart';
import '../../constants.dart';
import '../chat_neon_glass/adapters/message_adapter.dart';
import '../chat_neon_glass/adapters/ui_message.dart';
import '../chat_neon_glass/controllers/message_stream_bridge.dart';
import '../chat_neon_glass/controllers/neon_chat_controller.dart';
import '../chat_neon_glass/neon_chat_screen.dart';
import '../chat_neon_glass/state_machine/chat_events.dart';
import '../chat_neon_glass/state_machine/chat_state.dart';
import '../chat_neon_glass/state_machine/chat_state_machine.dart';
import '../chat_neon_glass/state_machine/chat_transition_rules.dart';
import '../chat_neon_glass/tokens/chat_tokens.dart';
import '../chat_neon_glass/utils/perf/effect_suppression.dart';
import '../chat_neon_glass/utils/perf/frame_budget_signals.dart';
import '../chat_neon_glass/utils/perf/scroll_velocity_tracker.dart';

/// Live neon chat screen that uses real backend streams.
/// Additive entrypoint for testing without replacing the legacy chat UI.
class NeonChatLiveScreen extends StatefulWidget {
  final String viewerId;
  final String peerId;
  final String peerName;
  final String peerImageUrl;

  const NeonChatLiveScreen({
    super.key,
    required this.viewerId,
    required this.peerId,
    required this.peerName,
    required this.peerImageUrl,
  });

  @override
  State<NeonChatLiveScreen> createState() => _NeonChatLiveScreenState();
}

class _NeonChatLiveScreenState extends State<NeonChatLiveScreen> {
  late final DefaultChatStateMachine _stateMachine;
  late final BasicScrollVelocityTracker _velocityTracker;
  late final EffectSuppressionPolicy _effectPolicy;
  late final DefaultNeonChatController _controller;

  final Controller _legacyController = Controller();
  final WebSocketService _websocket = WebSocketService();

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
        fastScrollThresholdPxPerSec: 1400,
        settleThresholdPxPerSec: 320,
      ),
    );
    _velocityTracker =
        BasicScrollVelocityTracker(fastScrollThresholdPxPerSec: 1400);
    _effectPolicy = DefaultEffectSuppressionPolicy(
      tokens: tokens,
      frameBudget: const StaticFrameBudgetSignals(isUnderPressure: false),
    );

    final MessageStreamBridge bridge = GetxConversationMessageStreamBridge(
      viewerId: widget.viewerId,
      peerId: widget.peerId,
      messagesRxList: _legacyController.messages,
    );
    final MessageAdapter adapter =
        DefaultMessageAdapter(viewerId: widget.viewerId);

    _controller = DefaultNeonChatController(
      bridge: bridge,
      adapter: adapter,
      stateMachine: _stateMachine,
    );

    // Ensure websocket connection mirrors legacy screen behavior.
    _websocket.connect(_legacyController.token.value);
    // Fetch initial history if not already loaded.
    _legacyController.fetchChats(widget.peerId);
  }

  Future<void> _sendText(String text) async {
    if (text.trim().isEmpty) return;
    final EncryptedSharedPreferences prefs =
        EncryptedSharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null || token.isEmpty) return;

    final Uri url = Uri.parse('$springbooturl/ChatController/send-message');
    final http.MultipartRequest request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['receiverId'] = widget.peerId
      ..fields['message'] = text;

    try {
      final http.StreamedResponse resp = await request.send();
      if (resp.statusCode != 200) {
        debugPrint('Neon send failed: ${resp.statusCode}');
      } else {
        // Refresh to pick up backend status updates.
        _legacyController.fetchChats(widget.peerId);
      }
    } catch (e) {
      debugPrint('Neon send error: $e');
    }
  }

  Future<void> _retry(UIMessage failed) async {
    final String retryText = failed.text ?? '';
    if (retryText.isEmpty) return;
    await _sendText(retryText);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NeonChatTokens.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text('Neon Chat – ${widget.peerName}'),
      ),
      body: NeonChatScreen(
        controller: _controller,
        tokens: tokens,
        effectPolicy: _effectPolicy,
        stateMachine: _stateMachine,
        velocityTracker: _velocityTracker,
        onSendText: _sendText,
        onRetry: _retry,
        onAttach: () {},
        onTextChanged: (value) => _stateMachine.dispatch(
          ChatInputModeChanged(isTyping: value.trim().isNotEmpty),
        ),
        isPeerTyping: false,
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../Controllers/controller.dart';
import '../../Providers/WebSocketService.dart';
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
  final Controller controller;
  final TextEditingController messageController;
  final ScrollController scrollController;
  final String bearerToken;
  final Future<void> Function({
    required String message,
    required String receiverId,
    File? image,
  }) onSendMessage;
  final Future<XFile?> Function()? pickImageFromGallery;
  final String viewerId;
  final String peerId;
  final String peerName;
  final String peerImageUrl;

  const NeonChatLiveScreen({
    super.key,
    required this.controller,
    required this.messageController,
    required this.scrollController,
    required this.bearerToken,
    required this.onSendMessage,
    this.pickImageFromGallery,
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
  final WebSocketService _webSocketService = WebSocketService();
  bool _didConnectSocket = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Ensure the websocket service uses the injected controller instance.
        _webSocketService.controller = widget.controller;
        // Prefer the injected bearerToken, fallback to controller.token.value.
        final String token = widget.bearerToken.isNotEmpty
            ? widget.bearerToken
            : widget.controller.token.value;
        if (token.isNotEmpty && !_didConnectSocket) {
          _webSocketService.connect(token);
          _didConnectSocket = true;
        }
      } catch (_) {
        // Ignore; controller or websocket may handle their own lifecycle.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NeonChatTokens.instance;
    return NeonChatScreen(
      tokens: tokens,
      effectPolicy: _effectPolicy,
      stateMachine: _stateMachine,
      velocityTracker: _velocityTracker,
      legacyController: widget.controller,
      messageController: widget.messageController,
      scrollController: widget.scrollController,
      bearerToken: widget.bearerToken,
      onSendMessage: widget.onSendMessage,
      pickImageFromGallery: widget.pickImageFromGallery,
      initialBlocked: false,
      onTextChanged: (value) => _stateMachine.dispatch(
        ChatInputModeChanged(isTyping: value.trim().isNotEmpty),
      ),
      isPeerTyping: false,
      title: widget.peerName,
      peerName: widget.peerName,
      peerImageUrl: widget.peerImageUrl,
      viewerId: widget.viewerId,
      peerId: widget.peerId,
    );
  }

  @override
  void dispose() {
    // Do not disconnect here; websocket is a shared singleton used by legacy chat.
    super.dispose();
  }
}

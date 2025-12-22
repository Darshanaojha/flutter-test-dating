import 'dart:io';

import 'package:dating_application/Controllers/controller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../chat_neon_glass/neon_chat_screen.dart';
import '../chat_neon_glass/state_machine/chat_state.dart';
import '../chat_neon_glass/state_machine/chat_state_machine.dart';
import '../chat_neon_glass/state_machine/chat_transition_rules.dart';
import '../chat_neon_glass/tokens/chat_tokens.dart';
import '../chat_neon_glass/utils/perf/effect_suppression.dart';
import '../chat_neon_glass/utils/perf/frame_budget_signals.dart';
import '../chat_neon_glass/utils/perf/scroll_velocity_tracker.dart';

/// Run this screen standalone to preview the neon chat shell
/// while staying wired to the legacy controller/list types.
class NeonChatMockScreen extends StatefulWidget {
  const NeonChatMockScreen({super.key});

  @override
  State<NeonChatMockScreen> createState() => _NeonChatMockScreenState();
}

class _NeonChatMockScreenState extends State<NeonChatMockScreen> {
  late final DefaultChatStateMachine _stateMachine;
  late final BasicScrollVelocityTracker _velocityTracker;
  late final DefaultEffectSuppressionPolicy _effectPolicy;

  final Controller _legacyController = Controller();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NeonChatTokens.instance;
    return MaterialApp(
      home: NeonChatScreen(
        tokens: tokens,
        effectPolicy: _effectPolicy,
        stateMachine: _stateMachine,
        velocityTracker: _velocityTracker,
        peerName: 'Mock Chat',
        peerImageUrl: null,
        viewerId: 'mock_viewer',
        peerId: 'mock_peer',
        legacyController: _legacyController,
        messageController: _messageController,
        scrollController: _scrollController,
        bearerToken: '',
        onSendMessage: ({
          required String message,
          required String receiverId,
          File? image,
        }) async {},
        pickImageFromGallery: () async => null,
        onTextChanged: (_) {},
        isPeerTyping: false,
      ),
    );
  }
}



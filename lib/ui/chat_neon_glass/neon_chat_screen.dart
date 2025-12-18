import 'package:flutter/material.dart';

import 'controllers/neon_chat_controller.dart';
import 'components/messages/neon_message_list.dart';
import 'layers/background/background_layer.dart';
import 'layers/background/parallax_driver.dart';
import 'state_machine/chat_state.dart';
import 'state_machine/chat_state_machine.dart';
import 'utils/perf/effect_suppression.dart';
import 'utils/perf/scroll_velocity_tracker.dart';
import 'tokens/chat_tokens.dart';

/// Root screen for the neon–glass chat UI.
///
/// This file wires only the layer stack scaffold:
/// - Background layer (gradient + blob/noise placeholders)
/// - Ambient particles placeholder
/// - Chat content shell (app bar + message list + input bar placeholders)
/// - Lighting overlay placeholder
///
/// No bubbles, messages, or input logic are implemented here. Those will be
/// added in subsequent steps.
class NeonChatScreen extends StatefulWidget {
  final NeonChatController controller;
  final ChatTokens tokens;
  final EffectSuppressionPolicy effectPolicy;
  final ChatStateMachine stateMachine;
  final ScrollVelocityTracker velocityTracker;

  const NeonChatScreen({
    super.key,
    required this.controller,
    required this.tokens,
    required this.effectPolicy,
    required this.stateMachine,
    required this.velocityTracker,
  });

  @override
  State<NeonChatScreen> createState() => _NeonChatScreenState();
}

class _NeonChatScreenState extends State<NeonChatScreen> {
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);

  @override
  void dispose() {
    _scrollOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ChatUiState>(
      stream: widget.controller.watchState(),
      initialData: const ChatUiState(
        scrollPhase: ChatScrollPhase.idle,
        inputMode: ChatInputMode.idle,
        activeMessageId: null,
      ),
      builder: (context, snapshot) {
        final ChatUiState state = snapshot.data!;

        // Suppression flags derived from state.
        final bool suppressNoise = widget.effectPolicy.suppressNoise(state);
        final double blurMultiplier =
            widget.effectPolicy.blurMultiplier(state);
        final double glowMultiplier =
            widget.effectPolicy.glowMultiplier(state);
        final double particleMultiplier =
            widget.effectPolicy.particleMultiplier(state);

        final ParallaxDriver parallax = ParallaxDriver(
          minDrift: widget.tokens.spacing.parallaxDriftMin,
          maxDrift: widget.tokens.spacing.parallaxDriftMax,
        );

        return Scaffold(
          backgroundColor: widget.tokens.colors.bgBase,
          body: Stack(
            children: [
              Positioned.fill(
                child: ValueListenableBuilder<double>(
                  valueListenable: _scrollOffset,
                  builder: (context, offset, _) {
                    return BackgroundLayer(
                      tokens: widget.tokens,
                      parallax: parallax,
                      scrollOffset: offset,
                      blurMultiplier: blurMultiplier,
                      suppressNoise: suppressNoise,
                      parallaxStrength: blurMultiplier,
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: _AmbientParticlesLayer(
                  tokens: widget.tokens,
                  particleMultiplier: particleMultiplier,
                ),
              ),
              // Main chat content shell (app bar + list + input).
              Positioned.fill(
                child: SafeArea(
                  child: _ChatContentShell(
                    controller: widget.controller,
                    stateMachine: widget.stateMachine,
                    velocityTracker: widget.velocityTracker,
                    tokens: widget.tokens,
                    onScrollOffset: (value) => _scrollOffset.value = value,
                  ),
                ),
              ),
              Positioned.fill(
                child: _LightingTopcoat(
                  tokens: widget.tokens,
                  glowMultiplier: glowMultiplier,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BackgroundLayer extends StatelessWidget {
  final ChatTokens tokens;
  final double blurMultiplier;
  final bool suppressNoise;

  const _BackgroundLayer({
    required this.tokens,
    required this.blurMultiplier,
    required this.suppressNoise,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: tokens.colors.backgroundGradientStops,
        ),
      ),
      child: Stack(
        children: [
          // Placeholder for blurred blob field; actual animation added later.
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: blurMultiplier.clamp(0, 1),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          if (!suppressNoise)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withOpacity(0.02),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AmbientParticlesLayer extends StatelessWidget {
  final ChatTokens tokens;
  final double particleMultiplier;

  const _AmbientParticlesLayer({
    required this.tokens,
    required this.particleMultiplier,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: particleMultiplier.clamp(0, 1),
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }
}

class _ChatContentShell extends StatelessWidget {
  final NeonChatController controller;
  final ChatTokens tokens;
  final ChatStateMachine stateMachine;
  final ScrollVelocityTracker velocityTracker;
  final ValueChanged<double> onScrollOffset;

  const _ChatContentShell({
    required this.controller,
    required this.stateMachine,
    required this.velocityTracker,
    required this.tokens,
    required this.onScrollOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AppBarPlaceholder(tokens: tokens),
        const SizedBox(height: 12),
        Expanded(
          child: NeonMessageList(
            controller: controller,
            tokens: tokens,
            stateMachine: stateMachine,
            velocityTracker: velocityTracker,
            onScrollOffset: onScrollOffset,
          ),
        ),
        _InputBarPlaceholder(tokens: tokens),
      ],
    );
  }
}

class _AppBarPlaceholder extends StatelessWidget {
  final ChatTokens tokens;
  const _AppBarPlaceholder({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.l,
        vertical: tokens.spacing.s,
      ),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: tokens.colors.glassFill,
          border: Border.all(color: tokens.colors.glassStroke),
          borderRadius: BorderRadius.circular(tokens.radius.buttonMax),
        ),
        child: const Center(
          child: Text(
            'Chat',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }
}

class _InputBarPlaceholder extends StatelessWidget {
  final ChatTokens tokens;
  const _InputBarPlaceholder({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.spacing.l,
        tokens.spacing.s,
        tokens.spacing.l,
        tokens.spacing.m,
      ),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: tokens.colors.glassFill,
          border: Border.all(color: tokens.colors.glassStroke),
          borderRadius: BorderRadius.circular(tokens.radius.inputBarMax),
        ),
        child: const Center(
          child: Text(
            'Input bar',
            style: TextStyle(color: Colors.white60),
          ),
        ),
      ),
    );
  }
}

class _LightingTopcoat extends StatelessWidget {
  final ChatTokens tokens;
  final double glowMultiplier;

  const _LightingTopcoat({
    required this.tokens,
    required this.glowMultiplier,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: glowMultiplier.clamp(0, 1),
        child: Container(
          decoration: const BoxDecoration(
            // Placeholder vignette; detailed lighting will be added later.
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                Colors.transparent,
                Colors.black26,
                Colors.black45,
              ],
              stops: [0.6, 0.8, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

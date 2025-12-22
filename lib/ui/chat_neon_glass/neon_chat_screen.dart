import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../Controllers/controller.dart';
import '../../Models/ResponseModels/get_report_user_options_response_model.dart';
import 'controllers/haptics_hooks.dart';
import 'controllers/sound_hooks.dart';
import 'components/messages/neon_message_list.dart';
import 'layers/background/background_layer.dart';
import 'layers/background/parallax_driver.dart';
import 'components/input_bar/neon_input_bar.dart';
import 'state_machine/chat_state.dart';
import 'state_machine/chat_state_machine.dart';
import 'utils/perf/effect_suppression.dart';
import 'utils/perf/scroll_velocity_tracker.dart';
import 'tokens/chat_tokens.dart';
import 'widgets/neon_chat_header.dart';

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
  final ChatTokens tokens;
  final EffectSuppressionPolicy effectPolicy;
  final ChatStateMachine stateMachine;
  final ScrollVelocityTracker velocityTracker;
  final ChatSoundHooks? soundHooks;
  final ChatHapticsHooks? hapticsHooks;
  final ValueChanged<String>? onTextChanged;
  final bool isPeerTyping;
  final String title;
  final String peerName;
  final String? peerImageUrl;
  final String viewerId;
  final String peerId;
  final Controller legacyController;
  final TextEditingController messageController;
  final ScrollController scrollController;
  final String bearerToken;
  final bool initialBlocked;
  final Future<void> Function({
    required String message,
    required String receiverId,
    File? image,
  }) onSendMessage;
  final Future<XFile?> Function()? pickImageFromGallery;

  const NeonChatScreen({
    super.key,
    required this.tokens,
    required this.effectPolicy,
    required this.stateMachine,
    required this.velocityTracker,
    required this.peerName,
    this.peerImageUrl,
    this.soundHooks,
    this.hapticsHooks,
    this.onTextChanged,
    this.isPeerTyping = false,
    this.title = 'Chat',
    required this.viewerId,
    required this.peerId,
    required this.legacyController,
    required this.messageController,
    required this.scrollController,
    required this.bearerToken,
    required this.onSendMessage,
    this.pickImageFromGallery,
    this.initialBlocked = false,
  });

  @override
  State<NeonChatScreen> createState() => _NeonChatScreenState();
}

class _NeonChatScreenState extends State<NeonChatScreen> {
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);
  double _smoothBlur = 1.0;
  double _smoothGlow = 1.0;
  double _smoothParticles = 1.0;
  int _lastBlurInt = -1;
  int _lastGlowInt = -1;
  int _lastParticlesInt = -1;
  bool _isBlocked = false;

  @override
  void initState() {
    super.initState();
    _isBlocked = widget.initialBlocked;
  }
  

  @override
  void dispose() {
    _scrollOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ChatUiState>(
      stream: widget.stateMachine.watchState(),
      initialData: const ChatUiState(
        scrollPhase: ChatScrollPhase.idle,
        inputMode: ChatInputMode.idle,
        activeMessageId: null,
      ),
      builder: (context, snapshot) {
        final ChatUiState state = snapshot.data!;
        final bool suppressNoise = widget.effectPolicy.suppressNoise(state);
        final double rawBlur = widget.effectPolicy.blurMultiplier(state);
        final double rawGlow = widget.effectPolicy.glowMultiplier(state);
        final double rawParticles = widget.effectPolicy.particleMultiplier(state);

        // Smooth multipliers to avoid flicker.
        _smoothBlur = lerpDouble(_smoothBlur, rawBlur, 0.20)!.clamp(0.35, 1.0);
        _smoothGlow = lerpDouble(_smoothGlow, rawGlow, 0.18)!.clamp(0.25, 1.0);
        _smoothParticles =
            lerpDouble(_smoothParticles, rawParticles, 0.16)!.clamp(0.20, 1.0);

        final int b = (_smoothBlur * 100).round();
        final int g = (_smoothGlow * 100).round();
        final int p = (_smoothParticles * 100).round();
        if (b != _lastBlurInt || g != _lastGlowInt || p != _lastParticlesInt) {
          _lastBlurInt = b;
          _lastGlowInt = g;
          _lastParticlesInt = p;
          debugPrint(
              "NEON: smooth blur=${_smoothBlur.toStringAsFixed(2)} glow=${_smoothGlow.toStringAsFixed(2)} particles=${_smoothParticles.toStringAsFixed(2)}");
        }

        final ParallaxDriver parallax = ParallaxDriver(
          minDrift: widget.tokens.spacing.parallaxDriftMin,
          maxDrift: widget.tokens.spacing.parallaxDriftMax,
        );

        final double timestampOpacityMult =
            widget.effectPolicy.timestampOpacityMultiplier(state);

        return Stack(
          children: [
            RepaintBoundary(
              child: _NeonBackgroundStack(),
            ),
            // Main chat content shell (list + input).
            Positioned.fill(
              child: SafeArea(
                child: _ChatContentShell(
                  legacyController: widget.legacyController,
                  messageController: widget.messageController,
                  scrollController: widget.scrollController,
                  viewerId: widget.viewerId,
                  peerId: widget.peerId,
                  bearerToken: widget.bearerToken,
                  onSendMessage: widget.onSendMessage,
                  pickImageFromGallery: widget.pickImageFromGallery,
                  isBlocked: _isBlocked,
                  onBlockUser: _handleBlock,
                  onReportUser: _handleReport,
                  stateMachine: widget.stateMachine,
                  velocityTracker: widget.velocityTracker,
                  tokens: widget.tokens,
                  title: widget.title,
                  peerName: widget.peerName,
                  peerImageUrl: widget.peerImageUrl,
                  onScrollOffset: (value) => _scrollOffset.value = value,
                  uiState: state,
                  timestampOpacityMultiplier: timestampOpacityMult,
                  soundHooks: widget.soundHooks,
                  hapticsHooks: widget.hapticsHooks,
                  blurMultiplier: _smoothBlur,
                  glowMultiplier: _smoothGlow,
                  onTextChanged: widget.onTextChanged,
                  isPeerTyping: widget.isPeerTyping,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleBlock() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block user?'),
        content: const Text('You will no longer be able to send messages.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Block'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    widget.legacyController.blockToRequestModel.blockto = widget.peerId;
    final ok =
        await widget.legacyController.blockUser(widget.legacyController.blockToRequestModel);
    if (ok && mounted) {
      setState(() => _isBlocked = true);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('User blocked')));
    }
  }

  Future<void> _handleReport() async {
    final ok = await widget.legacyController.reportReason();
    if (!ok || !mounted) return;

    ReportReason? selected;
    String? description;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text('Report user'),
              content: SizedBox(
                width: double.maxFinite,
                height: 320,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.legacyController.reportReasons.length,
                        itemBuilder: (context, index) {
                          final reason =
                              widget.legacyController.reportReasons[index];
                          return RadioListTile<ReportReason>(
                            value: reason,
                            groupValue: selected,
                            title: Text(reason.title),
                            onChanged: (value) => setLocal(() => selected = value),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Optional description',
                      ),
                      onChanged: (v) => description = v,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: selected == null
                      ? null
                      : () async {
                          widget
                              .legacyController
                              .reportUserReasonFeedbackRequestModel
                              .reasonId = selected!.id;
                          widget
                              .legacyController
                              .reportUserReasonFeedbackRequestModel
                              .reason =
                              (description != null && description!.trim().isNotEmpty)
                                  ? description!
                                  : selected!.title;
                          widget
                              .legacyController
                              .reportUserReasonFeedbackRequestModel
                              .reportAgainst = widget.peerId;
                          await widget.legacyController.reportAgainstUser(widget
                              .legacyController
                              .reportUserReasonFeedbackRequestModel);
                          if (mounted) Navigator.pop(context);
                        },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _NeonBackgroundStack extends StatefulWidget {
  const _NeonBackgroundStack();

  @override
  State<_NeonBackgroundStack> createState() => _NeonBackgroundStackState();
}

class _NeonBackgroundStackState extends State<_NeonBackgroundStack> {
  @override
  Widget build(BuildContext context) {
    final _NeonChatScreenState? host =
        context.findAncestorStateOfType<_NeonChatScreenState>();
    if (host == null) return const SizedBox.shrink();

    final ChatTokens tokens = host.widget.tokens;
    final double rawBlur =
        host.widget.effectPolicy.blurMultiplier(host.widget.stateMachine.state);
    final double rawGlow =
        host.widget.effectPolicy.glowMultiplier(host.widget.stateMachine.state);
    final double rawParticles = host.widget.effectPolicy
        .particleMultiplier(host.widget.stateMachine.state);

    host._smoothBlur =
        lerpDouble(host._smoothBlur, rawBlur, 0.20)!.clamp(0.35, 1.0);
    host._smoothGlow =
        lerpDouble(host._smoothGlow, rawGlow, 0.18)!.clamp(0.25, 1.0);
    host._smoothParticles =
        lerpDouble(host._smoothParticles, rawParticles, 0.16)!.clamp(0.20, 1.0);

    final int b = (host._smoothBlur * 100).round();
    final int g = (host._smoothGlow * 100).round();
    final int p = (host._smoothParticles * 100).round();
    if (b != host._lastBlurInt ||
        g != host._lastGlowInt ||
        p != host._lastParticlesInt) {
      host._lastBlurInt = b;
      host._lastGlowInt = g;
      host._lastParticlesInt = p;
      debugPrint(
          "NEON: smooth blur=${host._smoothBlur.toStringAsFixed(2)} glow=${host._smoothGlow.toStringAsFixed(2)} particles=${host._smoothParticles.toStringAsFixed(2)}");
    }
    final ParallaxDriver parallax = ParallaxDriver(
      minDrift: tokens.spacing.parallaxDriftMin,
      maxDrift: tokens.spacing.parallaxDriftMax,
    );
    final double scrollOffset =
        host._scrollOffset.hasListeners ? host._scrollOffset.value : 0.0;
    final bool suppressNoise =
        host.widget.effectPolicy.suppressNoise(host.widget.stateMachine.state);

    return Stack(
      children: [
        Positioned.fill(
          child: ValueListenableBuilder<double>(
            valueListenable: host._scrollOffset,
            builder: (context, offset, _) {
              final double parallaxStrength = host._smoothBlur;
              return BackgroundLayer(
                tokens: tokens,
                parallax: parallax,
                scrollOffset: offset,
                blurMultiplier: host._smoothBlur.clamp(0.02, 1.0),
                suppressNoise: suppressNoise,
                parallaxStrength: parallaxStrength,
              );
            },
          ),
        ),
        Positioned.fill(
          child: _AmbientParticlesLayer(
            tokens: tokens,
            particleMultiplier: host._smoothParticles.clamp(0.02, 1.0),
            scrollOffset: scrollOffset,
          ),
        ),
        Positioned.fill(
          child: _LightingTopcoat(
            tokens: tokens,
            glowMultiplier: host._smoothGlow.clamp(0.02, 1.0),
          ),
        ),
      ],
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
    final double noiseOpacity = 0.05 * blurMultiplier;
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
          // Placeholder layer kept for compatibility; actual blobs handled elsewhere.
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: blurMultiplier.clamp(0.02, 1.0),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withOpacity(
                  suppressNoise ? noiseOpacity * 0.3 : noiseOpacity,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientParticlesLayer extends StatefulWidget {
  final ChatTokens tokens;
  final double particleMultiplier;
  final double scrollOffset;

  const _AmbientParticlesLayer({
    required this.tokens,
    required this.particleMultiplier,
    required this.scrollOffset,
  });

  @override
  State<_AmbientParticlesLayer> createState() => _AmbientParticlesLayerState();
}

class _AmbientParticlesLayerState extends State<_AmbientParticlesLayer>
    with SingleTickerProviderStateMixin {
  static const int _count = 56;
  late final List<_Particle> _particles;
  late final AnimationController _ticker;
  double _timeMs = 0.0;

  @override
  void initState() {
    super.initState();
    final Random rng = Random(1337);
    _particles = List<_Particle>.generate(_count, (int i) {
      return _Particle(
        pos: Offset(rng.nextDouble(), rng.nextDouble()),
        radius: (0.0015 + rng.nextDouble() * 0.0035) * 1.3,
        alpha: 0.25 + rng.nextDouble() * 0.35,
        drift: Offset(rng.nextDouble() - 0.5, rng.nextDouble() - 0.5),
      );
    });
    _ticker = AnimationController(vsync: this, duration: const Duration(days: 1))
      ..addListener(() {
        final double t =
            _ticker.lastElapsedDuration?.inMilliseconds.toDouble() ?? 0.0;
        if ((t - _timeMs).abs() > 80) {
          setState(() {
            _timeMs = t;
          });
        }
      })
      ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.particleMultiplier <= 0) {
      return const SizedBox.shrink();
    }
    // debugPrint(
    //     "NEON: AmbientParticlesLayer build scrollOffset=${widget.scrollOffset} mult=${widget.particleMultiplier}");
    return IgnorePointer(
      child: CustomPaint(
        painter: _AmbientParticlesPainter(
          particles: _particles,
          multiplier: widget.particleMultiplier.clamp(0, 1),
          scrollOffset: widget.scrollOffset,
          timeMs: _timeMs,
          color: widget.tokens.colors.glassStroke,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

class _AmbientParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double multiplier;
  final double scrollOffset;
  final double timeMs;
  final Color color;

  _AmbientParticlesPainter({
    required this.particles,
    required this.multiplier,
    required this.scrollOffset,
    required this.timeMs,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (multiplier <= 0.02) return;
    // debugPrint(
    //     "NEON: AmbientParticlesPainter paint scroll=$scrollOffset mult=$multiplier");
    final Paint p = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.screen;

    // Time-based slow drift with mild scroll influence.
    final double t = timeMs / 1000.0;
    final double driftY = ((scrollOffset * 0.008) + (t * 6)) % size.height;
    final double driftX = (t * 4) % size.width;

    for (final _Particle part in particles) {
      // Hot-reload tolerant: older particles may not have drift set.
      final Offset drift = (part.drift) ?? Offset.zero;
      final Offset base = Offset(
        (part.pos.dx * size.width + driftX + drift.dx * 40) % size.width,
        (part.pos.dy * size.height + driftY + drift.dy * 40) % size.height,
      );
      p.color = color.withOpacity(part.alpha * multiplier);
      final double r = part.radius * size.shortestSide;
      canvas.drawCircle(base, r, p);
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientParticlesPainter oldDelegate) {
    return (oldDelegate.multiplier - multiplier).abs() > 0.01 ||
        (oldDelegate.scrollOffset - scrollOffset).abs() > 1.0 ||
        (oldDelegate.timeMs - timeMs).abs() > 80 ||
        oldDelegate.color != color;
  }
}

class _Particle {
  final Offset pos;
  final double radius;
  final double alpha;
  final Offset? drift;
  const _Particle({
    required this.pos,
    required this.radius,
    required this.alpha,
    this.drift,
  });
}

class _ChatContentShell extends StatelessWidget {
  final Controller legacyController;
  final TextEditingController messageController;
  final ScrollController scrollController;
  final String viewerId;
  final String peerId;
  final String bearerToken;
  final Future<void> Function({
    required String message,
    required String receiverId,
    File? image,
  }) onSendMessage;
  final Future<XFile?> Function()? pickImageFromGallery;
  final ChatTokens tokens;
  final ChatStateMachine stateMachine;
  final ScrollVelocityTracker velocityTracker;
  final ValueChanged<double> onScrollOffset;
  final ChatUiState uiState;
  final double timestampOpacityMultiplier;
  final ChatSoundHooks? soundHooks;
  final ChatHapticsHooks? hapticsHooks;
  final double blurMultiplier;
  final double glowMultiplier;
  final ValueChanged<String>? onTextChanged;
  final bool isPeerTyping;
  final String title;
  final String peerName;
  final String? peerImageUrl;
  final bool isBlocked;
  final VoidCallback onReportUser;
  final VoidCallback onBlockUser;

  const _ChatContentShell({
    required this.legacyController,
    required this.messageController,
    required this.scrollController,
    required this.viewerId,
    required this.peerId,
    required this.bearerToken,
    required this.onSendMessage,
    this.pickImageFromGallery,
    required this.isBlocked,
    required this.onReportUser,
    required this.onBlockUser,
    required this.stateMachine,
    required this.velocityTracker,
    required this.tokens,
    required this.title,
    required this.peerName,
    this.peerImageUrl,
    required this.onScrollOffset,
    required this.uiState,
    required this.timestampOpacityMultiplier,
    this.soundHooks,
    this.hapticsHooks,
    required this.blurMultiplier,
    required this.glowMultiplier,
    this.onTextChanged,
    required this.isPeerTyping,
  });

  bool _looksLikeBase64Image(String? input) {
    if (input == null) return false;
    final String s = input.trim();
    if (s.isEmpty) return false;
    if (s.startsWith('http://') || s.startsWith('https://')) return false;
    // Common JPEG/PNG base64 prefixes seen in this codebase.
    return s.length > 50 && (s.startsWith('/9j/') || s.startsWith('/iVB'));
  }

  Uint8List? _tryDecodeBase64(String input) {
    try {
      String clean = input.trim();
      if (clean.contains(',')) clean = clean.split(',').last.trim();
      final int rem = clean.length % 4;
      if (rem != 0) clean += '=' * (4 - rem);
      return base64Decode(clean);
    } catch (_) {
      return null;
    }
  }

  Widget _buildPeerAvatar(String? imageUrl) {
    const double radius = 18;
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return const CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white10,
        child: Icon(Icons.person, size: 18, color: Colors.white54),
      );
    }

    final String raw = imageUrl.trim();
    if (_looksLikeBase64Image(raw)) {
      final Uint8List? bytes = _tryDecodeBase64(raw);
      if (bytes != null) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.white10,
          child: ClipOval(
            child: Image.memory(
              bytes,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white10,
      child: ClipOval(
        child: Image.network(
          raw,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.person, size: 18, color: Colors.white54),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NeonChatHeader(
          title: peerName,
          imageUrl: peerImageUrl,
          onReport: onReportUser,
          onBlock: onBlockUser,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: NeonMessageList(
            controller: legacyController,
            scrollController: scrollController,
            viewerId: viewerId,
            bearerToken: bearerToken,
            peerId: peerId,
            tokens: tokens,
            stateMachine: stateMachine,
            velocityTracker: velocityTracker,
            onScrollOffset: onScrollOffset,
            uiState: uiState,
            timestampOpacityMultiplier: timestampOpacityMultiplier,
            soundHooks: soundHooks,
            hapticsHooks: hapticsHooks,
            blurMultiplier: blurMultiplier,
            glowMultiplier: glowMultiplier,
            isPeerTyping: isPeerTyping,
          ),
        ),
        NeonInputBar(
          tokens: tokens,
          blurMultiplier: blurMultiplier,
          glowMultiplier: glowMultiplier,
          legacyController: legacyController,
          messageController: messageController,
          scrollController: scrollController,
          peerId: peerId,
          onSendMessage: onSendMessage,
          pickImageFromGallery: pickImageFromGallery,
          isBlocked: isBlocked,
          onChanged: onTextChanged,
        ),
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
    debugPrint(
        "NEON: LightingTopcoat build glowMultiplier=${glowMultiplier}");
    return IgnorePointer(
      child: Opacity(
        opacity: glowMultiplier.clamp(0, 1),
        child: Stack(
          children: [
            // Soft center glow
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.95,
                    colors: [
                      tokens.colors.bgGlowPurple.withOpacity(0.12),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
            // Cross-light wash
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      tokens.colors.bgGlowPink.withOpacity(0.10),
                      Colors.transparent,
                      tokens.colors.bgGlowPurple.withOpacity(0.10),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Darker edge vignette
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.05,
                    colors: [
                      Colors.transparent,
                      Colors.black38,
                    ],
                    stops: [0.55, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

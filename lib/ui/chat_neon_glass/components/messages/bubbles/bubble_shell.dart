import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../adapters/ui_message.dart';
import '../../../adapters/ui_message_status.dart';
import '../../../controllers/haptics_hooks.dart';
import '../../../controllers/sound_hooks.dart';
import '../../../state_machine/chat_state.dart';
import '../../../tokens/chat_tokens.dart';
import '../../../utils/render/neon_glow_paint.dart';
import 'bubble_text.dart';
import 'bubble_timestamp.dart';

/// Bubble shell with rim, glass, text, timestamp, and retry affordance.
class BubbleShell extends StatefulWidget {
  final UIMessage message;
  final ChatTokens tokens;
  final Widget child;
  final double glowMultiplier; // suppression-aware multiplier
  final ChatUiState uiState;
  final double timestampOpacityMultiplier;
  final void Function(UIMessage message)? onRetry;
  final ChatSoundHooks? soundHooks;
  final ChatHapticsHooks? hapticsHooks;
  final double blurMultiplier; // for media thumb / content if needed
  final void Function(UIMessage message)? onBlockUser;
  final void Function(UIMessage message)? onReportUser;

  const BubbleShell({
    super.key,
    required this.message,
    required this.tokens,
    required this.child,
    this.glowMultiplier = 1.0,
    required this.uiState,
    required this.timestampOpacityMultiplier,
    this.onRetry,
    this.soundHooks,
    this.hapticsHooks,
    this.blurMultiplier = 1.0,
    this.onBlockUser,
    this.onReportUser,
  });

  @override
  State<BubbleShell> createState() => _BubbleShellState();
}

class _BubbleShellState extends State<BubbleShell> with TickerProviderStateMixin {
  late AnimationController _rimController;
  late Animation<double> _rimAnim;

  double _currentRimOpacity = 0;
  double _targetRimOpacity = 0;
  double _currentRimRadius = 0;
  double _targetRimRadius = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  double _pulseOpacityBoost = 0;
  double _pulseRadiusBoost = 0;

  late AnimationController _rippleController;
  late Animation<double> _rippleAnim;
  Color? _rippleColor;
  double _rippleProgress = 0.0;
  double _rippleOpacityBase = 0.0;

  UIMessageStatus? _lastStatus;

  @override
  void initState() {
    super.initState();
    _rimController = AnimationController(
      vsync: this,
      duration: _rimDuration(),
    );
    _rimAnim = CurvedAnimation(
      parent: _rimController,
      curve: widget.tokens.motion.fade,
    )..addListener(_onRimTick);

    _pulseController = AnimationController(
      vsync: this,
      duration: widget.tokens.timing.deliveredPulse,
    );
    _pulseAnim = CurvedAnimation(
      parent: _pulseController,
      curve: widget.tokens.motion.sendRipple,
    )..addListener(_onPulseTick);

    _rippleController = AnimationController(
      vsync: this,
      duration: widget.tokens.timing.sendRipple,
    );
    _rippleAnim = CurvedAnimation(
      parent: _rippleController,
      curve: widget.tokens.motion.sendRipple,
    )..addListener(_onRippleTick);

    _recomputeRimTargets(first: true);
    _lastStatus = widget.message.status;
  }

  @override
  void didUpdateWidget(covariant BubbleShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uiState != widget.uiState ||
        oldWidget.glowMultiplier != widget.glowMultiplier ||
        oldWidget.message.status != widget.message.status ||
        oldWidget.message.isOutgoing != widget.message.isOutgoing) {
      _recomputeRimTargets(first: false);
    }

    if (_shouldPulse(_lastStatus, widget.message.status)) {
      _startPulse();
    }

    if (_shouldRipple(_lastStatus, widget.message.status)) {
      _startRipple(forRetry: _lastStatus == UIMessageStatus.failed);
    }

    if (_shouldSoundHook(_lastStatus, widget.message.status)) {
      _fireSoundHook(_lastStatus, widget.message.status);
    }
    if (_shouldHapticHook(_lastStatus, widget.message.status)) {
      _fireHapticHook(_lastStatus, widget.message.status);
    }

    _lastStatus = widget.message.status;
  }

  @override
  void dispose() {
    _rimController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _recomputeRimTargets({required bool first}) {
    final _RimState state = _deriveRimState(widget.uiState, widget.message);
    final double baseOpacity = (widget.tokens.opacity.rimGlowActiveMin +
            widget.tokens.opacity.rimGlowActiveMax) /
        2;

    final double deletedMultiplier = state.isDeleted ? 0.0 : (state.deletedOpacityMul ?? 1.0);
    final double suppression = widget.glowMultiplier.clamp(0, 1);
    _targetRimOpacity = baseOpacity * suppression * deletedMultiplier;

    final double idleRadius = widget.tokens.glow.rimRadiusMin;
    final double activeRadius = widget.tokens.glow.activeRimRadiusMax;
    final double fastRadius = widget.tokens.glow.rimRadiusMin;
    _targetRimRadius = state.isDeleted
        ? idleRadius
        : state.mode == _RimMode.active
            ? activeRadius
            : state.mode == _RimMode.fast
                ? fastRadius
                : idleRadius;

    if (first) {
      _currentRimOpacity = _targetRimOpacity;
      _currentRimRadius = _targetRimRadius;
      setState(() {});
      return;
    }

    _rimController.reset();
    _rimController.forward();
  }

  void _onRimTick() {
    final double k = _rimAnim.value;
    setState(() {
      _currentRimOpacity = _lerp(_currentRimOpacity, _targetRimOpacity, k);
      _currentRimRadius = _lerp(_currentRimRadius, _targetRimRadius, k);
    });
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  void _startPulse() {
    if (widget.glowMultiplier <= 0) return;
    _pulseController.stop();
    _pulseController.reset();
    _pulseController.forward();
  }

  void _onPulseTick() {
    final double k = _pulseAnim.value;
    // Use small boosts to avoid overshoot.
    _pulseOpacityBoost = 0.4 * (1.0 - (k - 1).abs()); // peak near mid
    _pulseRadiusBoost = 0.15 * (1.0 - (k - 1).abs());
    setState(() {});
  }

  Duration _rimDuration() {
    final Duration min = widget.tokens.timing.timestampFadeMin;
    final Duration max = widget.tokens.timing.timestampFadeMax;
    return Duration(
      milliseconds: ((min.inMilliseconds + max.inMilliseconds) / 2).round(),
    );
  }

  void _startRipple({required bool forRetry}) {
    if (widget.glowMultiplier <= 0) return;
    if (widget.message.status == UIMessageStatus.deleted) return;
    _rippleColor = forRetry
        ? widget.tokens.colors.failedBubbleRim
        : (widget.message.isOutgoing
            ? widget.tokens.colors.outgoingBubbleStart
            : widget.tokens.colors.incomingBubbleStart);
    final double baseOpacity = (widget.tokens.opacity.rimGlowActiveMin +
            widget.tokens.opacity.rimGlowActiveMax) /
        2;
    _rippleOpacityBase = baseOpacity * widget.glowMultiplier;
    if (_rippleOpacityBase <= 0) return;
    _rippleController.stop();
    _rippleController.reset();
    _rippleController.forward();
  }

  void _onRippleTick() {
    _rippleProgress = _rippleAnim.value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isOutgoing = widget.message.isOutgoing;
    final bool isDeleted = widget.message.status == UIMessageStatus.deleted;
    final bool isFailed = widget.message.status == UIMessageStatus.failed;

    final double bubbleOpacityBase = (widget.tokens.opacity.bubbleBackgroundMin +
            widget.tokens.opacity.bubbleBackgroundMax) /
        2;
    final double bubbleOpacity =
        isDeleted ? widget.tokens.opacity.bubbleBackgroundMin : bubbleOpacityBase;

    // Padding using midpoints.
    final double padV = (widget.tokens.spacing.bubblePaddingVMin +
            widget.tokens.spacing.bubblePaddingVMax) /
        2;
    final double padH = (widget.tokens.spacing.bubblePaddingHMin +
            widget.tokens.spacing.bubblePaddingHMax) /
        2;

    // Max width: use the stricter (min) fraction to avoid overly wide bubbles.
    final double maxFraction = widget.tokens.spacing.bubbleMaxWidthFractionMin;

    final double blurMid =
        (widget.tokens.blur.microMin + widget.tokens.blur.microMax) / 2;
    final double blurReduction =
        widget.tokens.blur.microMin / widget.tokens.blur.microMax;
    final double blurSigma =
        isDeleted ? blurMid * blurReduction : blurMid;

    // Rim color selection precedence: deleted -> failed -> outgoing -> incoming
    final Color rimColor = isDeleted
        ? widget.tokens.colors.incomingBubbleStart
        : isFailed
            ? widget.tokens.colors.failedBubbleRim
            : isOutgoing
                ? widget.tokens.colors.outgoingBubbleStart
                : widget.tokens.colors.incomingBubbleStart;

    final double finalRimOpacity = _currentRimOpacity;
    final double finalRimRadius = _currentRimRadius;

    final NeonGlowPaintHelper glowHelper = const DefaultNeonGlowPaintHelper();

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * maxFraction,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: () => _showContextMenu(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.tokens.radius.bubbleMax),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: CustomPaint(
                painter: _RimPainter(
                  color: rimColor,
                  opacity: finalRimOpacity,
                  glowHelper: glowHelper,
                  radius: widget.tokens.radius.bubbleMax,
                  rimSize: finalRimRadius,
                  pulseOpacityBoost: _pulseOpacityBoost,
                  pulseRadiusBoost: _pulseRadiusBoost,
                  rippleColor: _rippleColor,
                  rippleProgress: _rippleProgress,
                  rippleOpacityBase: _rippleOpacityBase,
                  rippleSuppression: widget.glowMultiplier,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: padV, horizontal: padH),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(bubbleOpacity),
                    borderRadius: BorderRadius.circular(widget.tokens.radius.bubbleMax),
                    border: Border.all(
                      color: widget.tokens.colors.glassStroke,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.tokens.colors.glassStroke.withOpacity(
                          isDeleted
                              ? widget.tokens.shadows.bubbleOpacity *
                                  (widget.tokens.opacity.bubbleBackgroundMin /
                                      widget.tokens.opacity.bubbleBackgroundMax) *
                                  0.3
                              : widget.tokens.shadows.bubbleOpacity,
                        ),
                        blurRadius: widget.tokens.shadows.bubbleBlur,
                        spreadRadius: 0,
                        offset: Offset(0, widget.tokens.shadows.bubbleYOffset),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Opacity(
                          opacity: isDeleted ? 0.6 : 1.0,
                          child: widget.child,
                        ),
                      ),
                      if (isFailed && !isDeleted && widget.onRetry != null)
                        Positioned(
                          left: (widget.tokens.spacing.timestampPaddingFromEdgeMin +
                                  widget.tokens.spacing.timestampPaddingFromEdgeMax) /
                              2,
                          bottom: (widget.tokens.spacing.timestampPaddingFromEdgeMin +
                                  widget.tokens.spacing.timestampPaddingFromEdgeMax) /
                              2,
                          child: _RetryButton(
                            color: widget.tokens.colors.failedBubbleRim,
                            onTap: () {
                              if (widget.message.status == UIMessageStatus.failed) {
                                widget.onRetry?.call(widget.message);
                              }
                            },
                          ),
                        ),
                      Positioned(
                        right: (widget.tokens.spacing.timestampPaddingFromEdgeMin +
                                widget.tokens.spacing.timestampPaddingFromEdgeMax) /
                            2,
                        bottom: (widget.tokens.spacing.timestampPaddingFromEdgeMin +
                                widget.tokens.spacing.timestampPaddingFromEdgeMax) /
                            2,
                        child: BubbleTimestamp(
                          message: widget.message,
                          tokens: widget.tokens,
                          uiState: widget.uiState,
                          opacityMultiplier: widget.timestampOpacityMultiplier,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _RimState _deriveRimState(ChatUiState state, UIMessage message) {
    final bool isDeleted = message.status == UIMessageStatus.deleted;
    if (isDeleted) {
      return const _RimState(mode: _RimMode.idle, isDeleted: true, deletedOpacityMul: 0.0);
    }
    if (state.activeMessageId != null && state.activeMessageId == message.id) {
      return const _RimState(mode: _RimMode.active, isDeleted: false, deletedOpacityMul: 1.0);
    }
    if (state.scrollPhase == ChatScrollPhase.fast) {
      return const _RimState(mode: _RimMode.fast, isDeleted: false, deletedOpacityMul: 1.0);
    }
    return const _RimState(mode: _RimMode.idle, isDeleted: false, deletedOpacityMul: 1.0);
  }

  bool _shouldRipple(UIMessageStatus? prev, UIMessageStatus next) {
    if (widget.glowMultiplier <= 0) return false;
    if (widget.message.status == UIMessageStatus.deleted) return false;
    if (prev == null) return false;
    if (prev == next) return false;
    // Send ripple on pending->sent; retry ripple on failed->pending.
    if (prev == UIMessageStatus.pending && next == UIMessageStatus.sent) {
      return true;
    }
    if (prev == UIMessageStatus.failed && next == UIMessageStatus.pending) {
      return true;
    }
    return false;
  }

  bool _shouldSoundHook(UIMessageStatus? prev, UIMessageStatus next) {
    if (widget.message.status == UIMessageStatus.deleted) return false;
    if (prev == null || prev == next) return false;
    return true;
  }

  bool _shouldHapticHook(UIMessageStatus? prev, UIMessageStatus next) {
    if (widget.message.status == UIMessageStatus.deleted) return false;
    if (prev == null || prev == next) return false;
    return true;
  }

  void _fireSoundHook(UIMessageStatus? prev, UIMessageStatus next) {
    final hooks = widget.soundHooks;
    if (hooks == null) return;
    // Debounce duplicates via prev/next check done earlier.
    if (prev == UIMessageStatus.pending && next == UIMessageStatus.sent) {
      hooks.onMessageSent(widget.message);
    } else if (prev == UIMessageStatus.sent && next == UIMessageStatus.delivered) {
      hooks.onMessageDelivered(widget.message);
    } else if (prev == UIMessageStatus.delivered && next == UIMessageStatus.seen) {
      hooks.onMessageSeen(widget.message);
    } else if (prev == UIMessageStatus.failed && next == UIMessageStatus.pending) {
      hooks.onMessageRetry(widget.message);
    }
  }

  void _fireHapticHook(UIMessageStatus? prev, UIMessageStatus next) {
    final hooks = widget.hapticsHooks;
    if (hooks == null) return;
    if (prev == UIMessageStatus.pending && next == UIMessageStatus.sent) {
      hooks.onSendMessage(widget.message);
    } else if (prev == UIMessageStatus.sent && next == UIMessageStatus.delivered) {
      hooks.onMessageDelivered(widget.message);
    } else if (prev == UIMessageStatus.delivered && next == UIMessageStatus.seen) {
      hooks.onMessageSeen(widget.message);
    } else if (prev == UIMessageStatus.failed && next == UIMessageStatus.pending) {
      hooks.onMessageRetry(widget.message);
    }
  }

  bool _shouldPulse(UIMessageStatus? prev, UIMessageStatus next) {
    if (widget.glowMultiplier <= 0) return false;
    if (widget.message.status == UIMessageStatus.failed ||
        widget.message.status == UIMessageStatus.deleted) {
      return false;
    }
    if (prev == null) return false;
    if (prev == next) return false;
    // Pulse on delivery transitions.
    final transitions = <UIMessageStatus, Set<UIMessageStatus>>{
      UIMessageStatus.pending: {UIMessageStatus.sent},
      UIMessageStatus.sent: {UIMessageStatus.delivered},
      UIMessageStatus.delivered: {UIMessageStatus.seen},
    };
    return transitions[prev]?.contains(next) ?? false;
  }

  Future<void> _showContextMenu(BuildContext context) async {
    if (widget.onBlockUser == null && widget.onReportUser == null) return;
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);
    final RelativeRect rect = RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      position.dx + box.size.width,
      position.dy + box.size.height,
    );

    final selection = await showMenu<String>(
      context: context,
      position: rect,
      items: [
        if (widget.onBlockUser != null)
          const PopupMenuItem<String>(
            value: 'block',
            child: Text('Block User'),
          ),
        if (widget.onReportUser != null)
          const PopupMenuItem<String>(
            value: 'report',
            child: Text('Report User'),
          ),
      ],
    );

    if (selection == 'block') {
      widget.onBlockUser?.call(widget.message);
    } else if (selection == 'report') {
      widget.onReportUser?.call(widget.message);
    }
  }
}

class _RimPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final NeonGlowPaintHelper glowHelper;
  final double radius;
  final double rimSize;
  final double pulseOpacityBoost;
  final double pulseRadiusBoost;
  final Color? rippleColor;
  final double rippleProgress;
  final double rippleOpacityBase;
  final double rippleSuppression;

  const _RimPainter({
    required this.color,
    required this.opacity,
    required this.glowHelper,
    required this.radius,
    required this.rimSize,
    required this.pulseOpacityBoost,
    required this.pulseRadiusBoost,
    required this.rippleColor,
    required this.rippleProgress,
    required this.rippleOpacityBase,
    required this.rippleSuppression,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final double deflate = (rimSize / 8).clamp(0.5, 6.0);

    final double boostedOpacity = (opacity * (1.0 + pulseOpacityBoost)).clamp(0, 1);

    final Paint stroke = glowHelper.rimStrokePaint(color, boostedOpacity * 0.8);
    canvas.drawRRect(rrect.deflate(deflate * 0.5), stroke);

    final Paint glow = glowHelper.rimGlowPaint(color, opacity);
    final double pulseDeflate = deflate / (1.0 + pulseRadiusBoost).clamp(1.0, 1.5);
    canvas.drawRRect(rrect.deflate(pulseDeflate), glow);

    // Ripple overlay
    if (rippleColor != null && rippleProgress > 0 && rippleSuppression > 0) {
      final double rp = rippleProgress.clamp(0, 1);
      final double maxRadius = (size.shortestSide * 0.8).clamp(0, size.shortestSide);
      final double radiusRipple = maxRadius * rp;
      final double rippleOpacity =
          (rippleOpacityBase * (1 - rp) * rippleSuppression).clamp(0, 1);
      final Paint ripplePaint = Paint()
        ..color = rippleColor!.withOpacity(rippleOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(size.center(Offset.zero), radiusRipple, ripplePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RimPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.opacity != opacity ||
        oldDelegate.rimSize != rimSize ||
        oldDelegate.pulseOpacityBoost != pulseOpacityBoost ||
        oldDelegate.pulseRadiusBoost != pulseRadiusBoost ||
        oldDelegate.rippleColor != rippleColor ||
        oldDelegate.rippleProgress != rippleProgress ||
        oldDelegate.rippleOpacityBase != rippleOpacityBase ||
        oldDelegate.rippleSuppression != rippleSuppression;
  }
}

class _RetryButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _RetryButton({
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Center(
            child: Icon(
              Icons.refresh,
              size: 16,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

enum _RimMode { idle, active, fast }

class _RimState {
  final _RimMode mode;
  final bool isDeleted;
  final double? deletedOpacityMul;
  const _RimState({
    required this.mode,
    required this.isDeleted,
    required this.deletedOpacityMul,
  });
}

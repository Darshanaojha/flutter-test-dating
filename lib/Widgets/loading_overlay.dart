import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

/// Internal widget that creates the state
class _LoadingOverlayWidget extends StatefulWidget {
  final List<String>? messages;
  final Duration messageDuration;
  final Color backgroundColor;
  final Color indicatorColor;
  final bool showBrandingAnimation;
  final Function(_LoadingOverlayState) onStateCreated;
  final VoidCallback onDismiss;

  const _LoadingOverlayWidget({
    required this.messages,
    required this.messageDuration,
    required this.backgroundColor,
    required this.indicatorColor,
    required this.showBrandingAnimation,
    required this.onStateCreated,
    required this.onDismiss,
  });

  @override
  State<_LoadingOverlayWidget> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentMessageIndex = 0;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    // Notify parent of state creation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onStateCreated(this);
    });

    // Cycle messages if provided
    if (widget.messages != null && widget.messages!.length > 1) {
      _startMessageCycling();
    }
  }

  void _startMessageCycling() {
    _messageTimer = Timer.periodic(widget.messageDuration, (timer) {
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % widget.messages!.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> hide() async {
    await _fadeController.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Blur background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: widget.backgroundColor,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Branding animation (optional)
                  if (widget.showBrandingAnimation)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: _BrandingAnimation(
                        color: widget.indicatorColor,
                      ),
                    ),
                  // Loading indicator
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.indicatorColor,
                      ),
                    ),
                  ),
                  // Messages
                  if (widget.messages != null && widget.messages!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          widget.messages![_currentMessageIndex],
                          key: ValueKey(_currentMessageIndex),
                          style: TextStyle(
                            color: widget.indicatorColor.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Optional branding micro-animation
class _BrandingAnimation extends StatefulWidget {
  final Color color;

  const _BrandingAnimation({required this.color});

  @override
  State<_BrandingAnimation> createState() => _BrandingAnimationState();
}

class _BrandingAnimationState extends State<_BrandingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.favorite,
          color: widget.color.withOpacity(0.7),
          size: 30,
        ),
      ),
    );
  }
}

/// Global overlay entry for the loading overlay
OverlayEntry? _currentOverlayEntry;
_LoadingOverlayState? _currentOverlayState;

/// Shows the loading overlay with optional messages
Future<void> showLoadingOverlay(
  BuildContext context, {
  List<String>? messages,
  Duration messageDuration = const Duration(seconds: 1),
  Color backgroundColor = Colors.black54,
  Color indicatorColor = Colors.white,
  bool showBrandingAnimation = false,
}) async {
  // Hide existing overlay if any
  await hideLoadingOverlay();

  final overlay = Overlay.of(context);
  _LoadingOverlayState? overlayState;

  _currentOverlayEntry = OverlayEntry(
    builder: (context) {
      return _LoadingOverlayWidget(
        messages: messages,
        messageDuration: messageDuration,
        backgroundColor: backgroundColor,
        indicatorColor: indicatorColor,
        showBrandingAnimation: showBrandingAnimation,
        onStateCreated: (state) {
          overlayState = state;
          _currentOverlayState = state;
        },
        onDismiss: () {
          if (_currentOverlayEntry != null) {
            _currentOverlayEntry!.remove();
            _currentOverlayEntry = null;
            _currentOverlayState = null;
          }
        },
      );
    },
  );

  overlay.insert(_currentOverlayEntry!);
}

/// Hides the loading overlay
Future<void> hideLoadingOverlay() async {
  if (_currentOverlayState != null && _currentOverlayEntry != null) {
    await _currentOverlayState!.hide();
  } else if (_currentOverlayEntry != null) {
    _currentOverlayEntry!.remove();
    _currentOverlayEntry = null;
    _currentOverlayState = null;
  }
}


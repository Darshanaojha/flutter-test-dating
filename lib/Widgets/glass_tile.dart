import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants.dart';

/// Reusable glass tile widget with enhanced glassmorphism effect
/// Features:
/// - Backdrop blur (frosted glass effect)
/// - Multi-layered fuchsia gradient for depth
/// - See-through but slightly opaque
/// - Borderless and shadowless design for seamless blending
/// - Can be used with DecoratedBoxTransition for animations
class GlassTile extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blurSigma;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const GlassTile({
    super.key,
    required this.child,
    this.opacity = 0.15,
    this.borderRadius = 12.0,
    this.padding,
    this.margin,
    this.blurSigma = 20.0,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.5,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // For proper glassmorphism, use white/light colors with transparency
    // The backdrop blur will naturally show the background through
    // Add subtle fuchsia tint for visual interest
    final tintColor = backgroundColor ?? AppColors.fuschia;
    final border = borderColor ?? Colors.white;

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          margin: margin,
          padding: padding ?? const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            // White base with subtle fuchsia tint for frosty glass effect
            // The white creates the frost, tint adds warmth
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                // Mix white with subtle fuchsia tint at top
                Color.lerp(Colors.white, tintColor, 0.15)!.withOpacity(opacity * 1.2),
                // Pure white in middle for maximum frost effect
                Colors.white.withOpacity(opacity),
                // Slightly darker white at bottom
                Colors.white.withOpacity(opacity * 0.85),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}

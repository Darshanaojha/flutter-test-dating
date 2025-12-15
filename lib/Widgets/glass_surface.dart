import 'dart:ui';
import 'package:flutter/material.dart';

/// Reusable glass surface widget with 3D depth effect
/// Features:
/// - Backdrop blur (frosted glass)
/// - Semi-transparent background
/// - 3D shadows (outer, inner highlight, inner shadow)
/// - Customizable opacity and border
class GlassSurface extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double borderOpacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const GlassSurface({
    super.key,
    required this.child,
    this.opacity = 0.2,
    this.borderOpacity = 0.3,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    this.borderColor,
    this.borderWidth = 1.5,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: (borderColor ?? Colors.white).withOpacity(borderOpacity),
              width: borderWidth,
            ),
            boxShadow: [
              // 1. Outer Shadow (Floating Effect)
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 25.0,
                spreadRadius: 0.0,
                offset: const Offset(0, 10), // Below element
              ),
              // 2. Inner Highlight (Top-Left Light Source)
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                blurRadius: 15.0,
                spreadRadius: -3.0, // Negative = inner shadow
                offset: const Offset(-3, -3), // Top-left
              ),
              // 3. Inner Shadow (Bottom-Right Depth)
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12.0,
                spreadRadius: -2.0, // Negative = inner shadow
                offset: const Offset(3, 3), // Bottom-right
              ),
            ],
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

    if (margin != null) {
      return Container(
        margin: margin,
        child: content,
      );
    }

    return content;
  }
}

/// Glass button widget with icon and text
class GlassButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? textColor;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const GlassButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.textColor,
    this.fontSize,
    this.padding,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      onTap: onPressed,
      borderRadius: borderRadius,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: textColor ?? Colors.white.withOpacity(0.9),
              size: fontSize != null ? fontSize! * 1.2 : 20,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor ?? Colors.white.withOpacity(0.9),
              fontSize: fontSize ?? 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

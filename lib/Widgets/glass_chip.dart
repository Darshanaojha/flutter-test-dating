import 'dart:ui';
import 'package:flutter/material.dart';

/// Glass-style chip widget for categories/tags
class GlassChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? selectedColor;
  final double borderRadius;
  final double opacity;
  final double borderOpacity;

  const GlassChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.selectedColor,
    this.borderRadius = 20.0,
    this.opacity = 0.12,
    this.borderOpacity = 0.18,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOpacity = selected ? opacity * 1.5 : opacity;
    final effectiveBorderOpacity = selected ? borderOpacity * 1.5 : borderOpacity;
    final chipColor = selectedColor ?? const Color(0xFF895294); // Purple from app theme instead of red

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? chipColor.withOpacity(0.2)
                  : Colors.white.withOpacity(effectiveOpacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: selected
                    ? chipColor.withOpacity(0.5)
                    : Colors.white.withOpacity(effectiveBorderOpacity),
                width: selected ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12.0,
                  offset: const Offset(0, 4),
                ),
                if (selected)
                  BoxShadow(
                    color: chipColor.withOpacity(0.3),
                    blurRadius: 8.0,
                    spreadRadius: -1.0,
                    offset: const Offset(0, 0),
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? chipColor
                        : Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 6),
                  Icon(
                    icon,
                    size: 16,
                    color: selected
                        ? chipColor
                        : Colors.white.withOpacity(0.9),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants.dart';

/// Multi-layered 3D glassmorphism background widget
/// Creates depth through 5 gradient layers:
/// 1. Base gradient (dark purple foundation)
/// 2. Primary radial glow (center light source)
/// 3. Secondary radial glow (top-right accent)
/// 4. Directional light (top to bottom)
/// 5. Vignette (edge darkening)
class GlassmorphismBackground extends StatelessWidget {
  final Widget child;
  final bool animate;

  const GlassmorphismBackground({
    super.key,
    required this.child,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Layer 1: Base Linear Gradient (Foundation) - Using app theme colors
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.gradientBackgroundList,
                stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
              ),
            ),
          ),
        ),

        // Layer 2: Primary Radial Glow (Center - Creates 3D Depth)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.1), // Center-top
                radius: 1.5, // Large spread
                colors: [
                  AppColors.gradientBackgroundList[3].withOpacity(0.25), // Purple glow
                  AppColors.gradientBackgroundList[2].withOpacity(0.18), // Deep violet
                  AppColors.gradientBackgroundList[1].withOpacity(0.12), // Dark violet
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.6, 1.0],
              ),
            ),
          ),
        ),

        // Layer 3: Secondary Radial Glow (Top-Right)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.8, -0.6), // Top-right corner
                radius: 1.0,
                colors: [
                  AppColors.gradientBackgroundList[4].withOpacity(0.15), // Medium-light purple
                  AppColors.gradientBackgroundList[3].withOpacity(0.10), // Purple
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Layer 4: Directional Light (Top to Bottom)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.gradientBackgroundList[4].withOpacity(0.12), // Light at top
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.15), // Dark at bottom
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
        ),

        // Layer 5: Vignette (Edge Darkening)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.4,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.35),
                ],
                stops: const [0.0, 0.5, 0.8, 1.0],
              ),
            ),
          ),
        ),

        // Content Layer (All UI Elements)
        child,
      ],
    );
  }
}

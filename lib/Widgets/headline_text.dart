import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/shimmer.dart';
import 'package:dating_application/Controllers/controller.dart';

class HeadlineText extends StatelessWidget {
  final int index;
  final double fontSize;
  final TextAlign align;

  const HeadlineText({
    super.key,
    required this.index,
    this.fontSize = 20,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<Controller>();

    return Obx(() {
      // ===== SAFE CHECKS =====

      if (controller.headlines.isEmpty) {
        return const ShimmerBox(height: 28, width: 180);
      }

      if (controller.headlines.length <= index) {
        return const ShimmerBox(height: 28, width: 180); // prevent crash
      }

      final text = controller.headlines[index].title;

      if (text.isEmpty || text.trim().isEmpty) {
        return const ShimmerBox(height: 28, width: 180);
      }

      // ===== FINAL TEXT =====

      return Text(
        text,
        style: TextStyle(
          fontSize: fontSize + 2,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }
}

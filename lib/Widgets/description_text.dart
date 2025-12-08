import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Widgets/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DescriptionText extends StatelessWidget {
  final int index;
  final double fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign align;

  const DescriptionText({
    super.key,
    required this.index,
    this.fontSize = 16,
    this.color = Colors.white70,
    this.fontWeight,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<Controller>();

    return Obx(() {
      if (controller.headlines.isEmpty) {
        return const ShimmerBox(height: 22, width: 260);
      }

      return Text(
        controller.headlines[index].description,
        textAlign: align,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
      );
    });
  }
}

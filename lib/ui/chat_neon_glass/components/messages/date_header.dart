import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../tokens/chat_tokens.dart';

/// Date header between grouped messages.
class DateHeader extends StatelessWidget {
  final DateTime date;
  final ChatTokens tokens;

  const DateHeader({
    super.key,
    required this.date,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final String label = DateFormat.yMMMMd().format(date);
    final double vMargin = MediaQuery.of(context).size.height * 0.004;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: vMargin,
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacing.m,
            vertical: tokens.spacing.xs,
          ),
          decoration: BoxDecoration(
            color: tokens.colors.glassFill,
            borderRadius: BorderRadius.circular(tokens.radius.buttonMin),
            border: Border.all(color: tokens.colors.glassStroke),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: tokens.colors.textSecondary,
              fontSize: tokens.typography.timestampFontSizeMax,
            ),
          ),
        ),
      ),
    );
  }
}

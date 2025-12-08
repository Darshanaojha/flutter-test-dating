import 'package:flutter/material.dart';

class ResponsiveFont {
  /// Large headings / titles
  static double heading(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.065;

  /// Sub-headings / smaller titles
  static double subHeading(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.045;

  /// Normal body text
  static double body(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.035;

  /// Small captions / hints
  static double caption(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.03;
}

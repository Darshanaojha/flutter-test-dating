import 'package:flutter/material.dart';

/// A small reusable refresh wrapper that safely adds pull-to-refresh
/// to pages. If [onRefresh] is null, it will simply return a completed
/// future so pull-to-refresh does nothing but won't crash.
class RefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function()? onRefresh;

  const RefreshWrapper({Key? key, required this.child, this.onRefresh})
      : super(key: key);

  Future<void> _safeRefresh() async {
    try {
      if (onRefresh != null) {
        await onRefresh!();
      }
    } catch (e) {
      // swallow errors so pull-to-refresh never crashes the app
      // consider logging if you have a logger available
    }
  }

  @override
  Widget build(BuildContext context) {
    // Many pages use ListView/CustomScrollView; wrapping with RefreshIndicator
    // is safe as long as the scrollable has an associated ScrollController.
    return RefreshIndicator(
      color: Color(0xFFCCB3F2), // Light purple color
      onRefresh: _safeRefresh,
      child: child,
    );
  }
}

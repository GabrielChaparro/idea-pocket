import 'package:flutter/material.dart';

import 'app_theme.dart';

class RetroPanel extends StatelessWidget {
  const RetroPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = retroPanel,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: retroInk, width: 2),
        boxShadow: shadow
            ? const [
                BoxShadow(
                  color: retroInk,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class RetroScreen extends StatelessWidget {
  const RetroScreen({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return RetroPanel(
      color: retroScreen,
      padding: padding,
      shadow: shadow,
      child: child,
    );
  }
}

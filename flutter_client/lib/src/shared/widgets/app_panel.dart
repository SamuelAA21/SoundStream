import 'package:flutter/material.dart';

import '../../theme/app_box_styles.dart';

class AppPanel extends StatelessWidget {
  const AppPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.width,
  });

  final Widget child;
  final EdgeInsets padding;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppBoxStyles.panel,
      child: child,
    );
  }
}

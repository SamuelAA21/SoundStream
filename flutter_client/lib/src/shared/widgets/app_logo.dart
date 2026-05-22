import 'package:flutter/material.dart';

import '../../theme/app_box_styles.dart';
import '../../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 40,
    this.radius = 14,
    this.iconSize = 22,
  });

  final double size;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: AppBoxStyles.brandIcon(radius: radius),
      child: Icon(
        Icons.graphic_eq_rounded,
        color: AppColors.white,
        size: iconSize,
      ),
    );
  }
}

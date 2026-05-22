import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_gradients.dart';

class AppBoxStyles {
  AppBoxStyles._();

  static BoxDecoration panel = BoxDecoration(
    color: AppColors.darkCard,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration brandIcon({double radius = 14}) => BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    gradient: AppGradients.brandDiagonal,
  );
}

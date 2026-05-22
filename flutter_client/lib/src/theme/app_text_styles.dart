import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const heading = TextStyle(
    color: AppColors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const sectionTitle = TextStyle(
    color: AppColors.white,
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );

  static const body = TextStyle(color: AppColors.white, fontSize: 14);

  static const muted = TextStyle(color: AppColors.textMid, fontSize: 13);
}

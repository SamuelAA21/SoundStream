import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  static const brand = LinearGradient(
    colors: [AppColors.purple, AppColors.pink],
  );

  static const brandDiagonal = LinearGradient(
    colors: [AppColors.purple, AppColors.pink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const heading = LinearGradient(
    colors: [AppColors.white, AppColors.cyan],
  );

  static const homeHero = LinearGradient(
    colors: [Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const album = LinearGradient(
    colors: [AppColors.purple, AppColors.cyan],
  );

  static const playlist = LinearGradient(
    colors: [AppColors.pink, AppColors.purple],
  );
}

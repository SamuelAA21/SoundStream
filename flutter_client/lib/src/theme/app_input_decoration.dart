import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppInputDecoration {
  AppInputDecoration._();

  static InputDecoration dark({
    required String label,
    IconData? icon,
    bool compact = false,
  }) {
    final radius = compact ? 12.0 : 14.0;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: AppColors.textMid,
        fontSize: compact ? 13 : 14,
      ),
      prefixIcon: icon == null
          ? null
          : Icon(icon, color: AppColors.textMid, size: 20),
      filled: true,
      fillColor: compact ? AppColors.dark : AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: AppColors.purple, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 16,
        vertical: compact ? 14 : 16,
      ),
    );
  }
}

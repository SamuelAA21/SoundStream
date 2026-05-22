import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_input_decoration.dart';

class AppDarkTextField extends StatelessWidget {
  const AppDarkTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.white, fontSize: 15),
      decoration: AppInputDecoration.dark(
        label: label,
        icon: icon,
        compact: icon == null,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'app_panel.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Row(
        children: [
          const Icon(Icons.inbox_rounded, color: AppColors.purple),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.textMid),
            ),
          ),
        ],
      ),
    );
  }
}

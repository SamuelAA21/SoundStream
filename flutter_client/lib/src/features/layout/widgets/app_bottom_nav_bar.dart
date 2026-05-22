import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../models/shell_page.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.pages,
    required this.onTap,
  });

  final int selectedIndex;
  final List<ShellPage> pages;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: List.generate(pages.length, (i) {
          final page = pages[i];
          final selected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      page.icon,
                      color: selected ? AppColors.purple : AppColors.textMid,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      page.label,
                      style: TextStyle(
                        color: selected ? AppColors.purple : AppColors.textMid,
                        fontSize: 11,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Header Bar oscuro ────────────────────────────────────────────────────────

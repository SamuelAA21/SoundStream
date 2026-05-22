import 'package:flutter/material.dart';

import '../../../shared/widgets/app_logo.dart';
import '../../../theme/app_colors.dart';
import '../models/shell_page.dart';

class AppSideRail extends StatelessWidget {
  const AppSideRail({
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
      width: 220,
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 32),
            child: Row(
              children: [
                const AppLogo(),
                const SizedBox(width: 10),
                const Text(
                  'SoundStream',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: pages.length,
              itemBuilder: (context, i) {
                final page = pages[i];
                final selected = i == selectedIndex;
                return GestureDetector(
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: selected
                          ? const LinearGradient(
                              colors: [AppColors.purple, AppColors.pink],
                            )
                          : null,
                      color: selected ? null : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          page.icon,
                          color: selected ? AppColors.white : AppColors.textMid,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          page.label,
                          style: TextStyle(
                            color: selected
                                ? AppColors.white
                                : AppColors.textMid,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Nav oscuro ────────────────────────────────────────────────────────

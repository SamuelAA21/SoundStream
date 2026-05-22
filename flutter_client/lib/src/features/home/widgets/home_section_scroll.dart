import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class HomeSectionScroll extends StatelessWidget {
  const HomeSectionScroll({
    super.key,
    required this.child,
    required this.onRefresh,
  });
  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.purple,
      backgroundColor: AppColors.darkCard,
      onRefresh: onRefresh,
      child: ListView(padding: const EdgeInsets.all(20), children: [child]),
    );
  }
}

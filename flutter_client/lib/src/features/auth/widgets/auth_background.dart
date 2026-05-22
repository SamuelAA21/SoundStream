import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import 'glow_orb.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: -120,
          left: -80,
          child: GlowOrb(color: AppColors.purple, size: 380),
        ),
        const Positioned(
          bottom: -100,
          right: -60,
          child: GlowOrb(color: AppColors.pink, size: 320),
        ),
        const Positioned(
          top: 200,
          right: 80,
          child: GlowOrb(color: AppColors.cyan, size: 180),
        ),
        child,
      ],
    );
  }
}

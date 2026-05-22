import 'package:flutter/material.dart';

class GlowOrb extends StatelessWidget {
  const GlowOrb({super.key, required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0.0)],
      ),
    ),
  );
}

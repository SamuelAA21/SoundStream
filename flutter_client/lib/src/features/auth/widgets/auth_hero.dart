import 'package:flutter/material.dart';

import '../../../shared/widgets/app_logo.dart';
import '../../../theme/app_colors.dart';

class AuthHero extends StatelessWidget {
  const AuthHero({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        const AppLogo(size: 64, radius: 20, iconSize: 36),
        const SizedBox(height: 28),
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [AppColors.white, AppColors.cyan],
          ).createShader(b),
          child: const Text(
            'SoundStream',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 44,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tu música, tus reglas.\nStreaming inteligente con\nrecomendaciones personalizadas.',
          style: TextStyle(color: AppColors.textMid, fontSize: 17, height: 1.6),
        ),
        const SizedBox(height: 40),
        _FeatureRow(
          icon: Icons.bolt_rounded,
          color: AppColors.purple,
          label: 'Recomendaciones con IA',
        ),
        const SizedBox(height: 16),
        _FeatureRow(
          icon: Icons.favorite_rounded,
          color: AppColors.pink,
          label: 'Favoritos y playlists',
        ),
        const SizedBox(height: 16),
        _FeatureRow(
          icon: Icons.history_rounded,
          color: AppColors.cyan,
          label: 'Historial de escucha',
        ),
        const SizedBox(height: 16),
        _FeatureRow(
          icon: Icons.mic_rounded,
          color: AppColors.purple,
          label: 'Panel de artista',
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.color,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

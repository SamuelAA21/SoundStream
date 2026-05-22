import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/controllers.dart';
import '../../../theme/app_colors.dart';

class AppHeaderBar extends StatelessWidget {
  const AppHeaderBar({super.key, required this.title, required this.onLogout});
  final String title;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [AppColors.white, AppColors.cyan],
                  ).createShader(b),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Explora, organiza y publica tu catalogo musical.',
                  style: TextStyle(color: AppColors.textMid, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.purple, AppColors.pink],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initialFor(auth.user?.name),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.user?.name ?? '',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      auth.user?.role ?? '',
                      style: TextStyle(color: AppColors.textMid, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onLogout,
                  tooltip: 'Cerrar sesion',
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.textMid,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String initialFor(String? name) {
  if (name == null || name.trim().isEmpty) return 'S';
  return name.trim()[0].toUpperCase();
}

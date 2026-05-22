import 'package:flutter/material.dart';

import '../../../models/domain_models.dart';
import '../../../shared/widgets/app_panel.dart';
import '../../../theme/app_colors.dart';

class PlaylistCard extends StatelessWidget {
  const PlaylistCard({super.key, required this.playlist, required this.onTap});
  final PlaylistSummary playlist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AppPanel(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [AppColors.pink, AppColors.purple],
                ),
              ),
              child: const Icon(
                Icons.queue_music_rounded,
                color: AppColors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              playlist.name,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              playlist.description?.isNotEmpty == true
                  ? playlist.description!
                  : 'Sin descripcion',
              style: TextStyle(color: AppColors.textMid, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Text(
              '${playlist.songCount} canciones • ${playlist.isPublic ? 'Publica' : 'Privada'}',
              style: const TextStyle(
                color: AppColors.cyan,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── HomeHeroBanner ─────────────────────────────────────────────────────────────

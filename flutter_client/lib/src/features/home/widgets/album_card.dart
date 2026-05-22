import 'package:flutter/material.dart';

import '../../../models/domain_models.dart';
import '../../../theme/app_colors.dart';

class AlbumCard extends StatelessWidget {
  const AlbumCard({super.key, required this.album, required this.onTap});
  final Album album;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [AppColors.purple, AppColors.cyan],
                ),
              ),
              child: const Icon(Icons.album_rounded, color: AppColors.white),
            ),
            const SizedBox(height: 14),
            Text(
              album.title,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              album.artist,
              style: TextStyle(color: AppColors.textMid, fontSize: 12),
            ),
            Text(
              album.genre ?? 'Sin genero',
              style: TextStyle(color: AppColors.textMid, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Text(
              '${album.songCount} canciones',
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

// ─── PlaylistCard ────────────────────────────────────────────────────────────

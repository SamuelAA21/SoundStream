import 'package:flutter/material.dart';

import '../../../models/domain_models.dart';
import '../../../shared/widgets/app_panel.dart';
import '../../../theme/app_colors.dart';

class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    required this.isFavorite,
    required this.onPlay,
    required this.onToggleFavorite,
    required this.onAddToPlaylist,
    this.extra,
  });
  final Song song;
  final bool isFavorite;
  final VoidCallback onPlay;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToPlaylist;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [
                  AppColors.purple.withValues(alpha: 0.6),
                  AppColors.pink.withValues(alpha: 0.6),
                ],
              ),
            ),
            child: const Icon(Icons.music_note_rounded, color: AppColors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${song.artist} • ${song.album ?? 'Sin album'} • ${song.genre}',
                  style: TextStyle(color: AppColors.textMid, fontSize: 12),
                ),
                ?extra,
              ],
            ),
          ),
          Wrap(
            spacing: 4,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.purple, AppColors.pink],
                  ),
                ),
                child: IconButton(
                  onPressed: onPlay,
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
              IconButton(
                onPressed: onToggleFavorite,
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? AppColors.pink : AppColors.textMid,
                ),
              ),
              IconButton(
                onPressed: onAddToPlaylist,
                icon: const Icon(
                  Icons.playlist_add_rounded,
                  color: AppColors.textMid,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── EditorialSongCard ───────────────────────────────────────────────────────

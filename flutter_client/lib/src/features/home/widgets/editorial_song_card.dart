import 'package:flutter/material.dart';

import '../../../models/domain_models.dart';
import '../../../shared/widgets/app_panel.dart';
import '../../../theme/app_colors.dart';

class EditorialSongCard extends StatelessWidget {
  const EditorialSongCard({
    super.key,
    required this.song,
    required this.subtitle,
    required this.onDelete,
    required this.onAssignAlbum,
    this.published = false,
    this.showPublicationToggle = true,
    this.onTogglePublication,
  });
  final Song song;
  final String subtitle;
  final bool published;
  final bool showPublicationToggle;
  final ValueChanged<bool>? onTogglePublication;
  final Future<void> Function() onDelete;
  final Future<void> Function() onAssignAlbum;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        children: [
          Row(
            children: [
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
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: AppColors.textMid, fontSize: 12),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: onAssignAlbum,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.purple,
                  side: const BorderSide(color: AppColors.border),
                ),
                icon: const Icon(Icons.album_rounded, size: 16),
                label: const Text('Asignar album'),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => onDelete(),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.textMid,
                ),
              ),
            ],
          ),
          if (showPublicationToggle) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              value: published,
              onChanged: onTogglePublication,
              activeThumbColor: AppColors.purple,
              title: Text(
                published ? 'Publicada' : 'Oculta',
                style: TextStyle(color: AppColors.textMid, fontSize: 13),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── AlbumCard ───────────────────────────────────────────────────────────────

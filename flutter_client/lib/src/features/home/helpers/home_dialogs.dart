import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/controllers.dart';
import '../../../models/domain_models.dart';
import '../../../shared/widgets/app_dark_text_field.dart';
import '../../../shared/widgets/app_gradient_button.dart';
import '../../../theme/app_colors.dart';
import 'home_actions.dart';

Future<void> showPlaylistPicker(BuildContext context, Song song) async {
  final playlists = context.read<PlaylistsController>();
  if (playlists.playlists.isEmpty) {
    await showSnack(context, 'Primero crea una playlist');
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.darkCard,
      title: const Text(
        'Agregar a playlist',
        style: TextStyle(color: AppColors.white),
      ),
      content: SizedBox(
        width: 340,
        child: ListView(
          shrinkWrap: true,
          children: playlists.playlists
              .map(
                (playlist) => ListTile(
                  title: Text(
                    playlist.name,
                    style: const TextStyle(color: AppColors.white),
                  ),
                  subtitle: Text(
                    '${playlist.songCount} canciones',
                    style: TextStyle(color: AppColors.textMid),
                  ),
                  onTap: () async {
                    try {
                      await context.read<PlaylistsController>().addSong(
                        playlistId: playlist.id,
                        songId: song.id,
                      );
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                      if (context.mounted) {
                        await showSnack(
                          context,
                          'Cancion agregada a ${playlist.name}',
                        );
                      }
                    } catch (_) {}
                  },
                ),
              )
              .toList(),
        ),
      ),
    ),
  );
}

Future<void> showCreatePlaylistDialog(BuildContext context) async {
  final name = TextEditingController();
  final description = TextEditingController();
  bool isPublic = false;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text(
          'Nueva playlist',
          style: TextStyle(color: AppColors.white),
        ),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppDarkTextField(controller: name, label: 'Nombre'),
              const SizedBox(height: 12),
              AppDarkTextField(controller: description, label: 'Descripcion'),
              SwitchListTile(
                value: isPublic,
                activeThumbColor: AppColors.purple,
                onChanged: (value) => setState(() => isPublic = value),
                title: const Text(
                  'Publica',
                  style: TextStyle(color: AppColors.white),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textMid),
            ),
          ),
          AppGradientButton(
            label: 'Crear',
            icon: Icons.add_rounded,
            onPressed: () async {
              try {
                await context.read<PlaylistsController>().create(
                  name: name.text.trim(),
                  description: description.text.trim(),
                  isPublic: isPublic,
                );
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              } catch (_) {}
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> showPlaylistDetail(
  BuildContext context,
  PlaylistSummary playlist,
) async {
  final detail = await context.read<PlaylistsController>().open(playlist.id);
  if (detail == null || !context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.darkCard,
      title: Text(
        playlist.name,
        style: const TextStyle(color: AppColors.white),
      ),
      content: SizedBox(
        width: 460,
        child: ListView(
          shrinkWrap: true,
          children: detail.songs
              .map(
                (song) => ListTile(
                  title: Text(
                    song.title,
                    style: const TextStyle(color: AppColors.white),
                  ),
                  subtitle: Text(
                    '${song.artist} • ${song.genre}',
                    style: TextStyle(color: AppColors.textMid),
                  ),
                  trailing: IconButton(
                    onPressed: () => context
                        .read<PlaylistsController>()
                        .removeSong(playlistId: playlist.id, songId: song.id),
                    icon: const Icon(
                      Icons.remove_circle_outline_rounded,
                      color: AppColors.pink,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    ),
  );
}

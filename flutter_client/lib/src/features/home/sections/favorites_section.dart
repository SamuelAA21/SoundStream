import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/controllers.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_box.dart';
import '../../../theme/app_colors.dart';
import '../helpers/home_actions.dart';
import '../helpers/home_dialogs.dart';
import '../widgets/home_hero_banner.dart';
import '../widgets/home_section_scroll.dart';
import '../widgets/song_tile.dart';

class FavoritesSection extends StatelessWidget {
  const FavoritesSection({super.key});
  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesController>();
    return HomeSectionScroll(
      onRefresh: () => context.read<FavoritesController>().load(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeHeroBanner(
            title: 'Favoritos',
            subtitle:
                'Tus canciones marcadas para volver rapido a lo mejor de tu biblioteca.',
          ),
          const SizedBox(height: 20),
          if (favorites.error != null) AppErrorBox(message: favorites.error!),
          if (favorites.loading)
            LinearProgressIndicator(
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(AppColors.purple),
            )
          else if (favorites.favorites.isEmpty)
            const AppEmptyState(
              message: 'Aun no has marcado canciones como favoritas.',
            )
          else
            ...favorites.favorites.map(
              (song) => SongTile(
                song: song,
                isFavorite: true,
                onPlay: () => playSong(context, song, source: 'favorite'),
                onToggleFavorite: () =>
                    context.read<FavoritesController>().toggle(song),
                onAddToPlaylist: () => showPlaylistPicker(context, song),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── PlaylistsSection ─────────────────────────────────────────────────────────

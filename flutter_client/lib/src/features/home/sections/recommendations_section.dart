import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/controllers.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_box.dart';
import '../../../shared/widgets/app_gradient_button.dart';
import '../../../theme/app_colors.dart';
import '../helpers/home_actions.dart';
import '../helpers/home_dialogs.dart';
import '../widgets/home_hero_banner.dart';
import '../widgets/home_section_scroll.dart';
import '../widgets/song_tile.dart';

class RecommendationsSection extends StatelessWidget {
  const RecommendationsSection({super.key});
  @override
  Widget build(BuildContext context) {
    final recommendations = context.watch<RecommendationsController>();
    final favorites = context.watch<FavoritesController>();
    return HomeSectionScroll(
      onRefresh: () => context.read<RecommendationsController>().refresh(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeroBanner(
            title: 'Recomendaciones',
            subtitle:
                'El motor hibrido combina historial, favoritos y patrones de interaccion.',
            trailing: AppGradientButton(
              label: 'Recalcular',
              icon: Icons.refresh_rounded,
              onPressed: () =>
                  context.read<RecommendationsController>().refresh(),
            ),
          ),
          const SizedBox(height: 20),
          if (recommendations.error != null)
            AppErrorBox(message: recommendations.error!),
          if (recommendations.loading)
            LinearProgressIndicator(
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(AppColors.purple),
            )
          else if (recommendations.items.isEmpty)
            const AppEmptyState(message: 'No hay recomendaciones disponibles.')
          else
            ...recommendations.items.map((item) {
              final song = item.toSong();
              return SongTile(
                song: song,
                isFavorite: favorites.contains(item.id),
                onPlay: () => playSong(context, song, source: 'recommendation'),
                onToggleFavorite: () =>
                    context.read<FavoritesController>().toggle(song),
                onAddToPlaylist: () => showPlaylistPicker(context, song),
                extra: item.reason == null
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          item.reason!,
                          style: TextStyle(color: AppColors.cyan, fontSize: 12),
                        ),
                      ),
              );
            }),
        ],
      ),
    );
  }
}

// ─── ArtistSection ────────────────────────────────────────────────────────────

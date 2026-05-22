import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/controllers.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_box.dart';
import '../../../shared/widgets/app_gradient_button.dart';
import '../../../shared/widgets/app_panel.dart';
import '../../../theme/app_colors.dart';
import '../helpers/home_actions.dart';
import '../helpers/home_dialogs.dart';
import '../widgets/album_card.dart';
import '../widgets/home_hero_banner.dart';
import '../widgets/home_metric_chip.dart';
import '../widgets/home_section_scroll.dart';
import '../widgets/home_section_title.dart';
import '../widgets/song_tile.dart';

class CatalogSection extends StatefulWidget {
  const CatalogSection({super.key});
  @override
  State<CatalogSection> createState() => _CatalogSectionState();
}

class _CatalogSectionState extends State<CatalogSection> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogController>();
    final favorites = context.watch<FavoritesController>();

    return HomeSectionScroll(
      onRefresh: () => context.read<CatalogController>().load(
        searchQuery: _searchController.text,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeroBanner(
            title: 'Catalogo vivo',
            subtitle:
                'Busca, reproduce y organiza musica desde una interfaz mas limpia.',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HomeMetricChip(
                  label: 'Canciones',
                  value: '${catalog.songs.length}',
                ),
                const SizedBox(width: 10),
                HomeMetricChip(
                  label: 'Albumes',
                  value: '${catalog.albums.length}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppPanel(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppColors.white),
                        decoration: InputDecoration(
                          hintText: 'Buscar por titulo, artista o genero',
                          hintStyle: TextStyle(color: AppColors.textMid),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppColors.textMid,
                          ),
                          filled: true,
                          fillColor: AppColors.dark,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.purple,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onSubmitted: (value) => context
                            .read<CatalogController>()
                            .load(searchQuery: value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    AppGradientButton(
                      label: 'Buscar',
                      icon: Icons.tune_rounded,
                      onPressed: () => context.read<CatalogController>().load(
                        searchQuery: _searchController.text,
                      ),
                    ),
                  ],
                ),
                if (catalog.loading) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(AppColors.purple),
                  ),
                ],
                if (catalog.error != null) ...[
                  const SizedBox(height: 16),
                  AppErrorBox(message: catalog.error!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          HomeSectionTitle(
            title: 'Canciones',
            subtitle: 'Todo el material disponible para streaming protegido.',
          ),
          const SizedBox(height: 12),
          if (!catalog.loading && catalog.songs.isEmpty)
            const AppEmptyState(message: 'No hay canciones disponibles.')
          else
            ...catalog.songs.map(
              (song) => SongTile(
                song: song,
                isFavorite: favorites.contains(song.id),
                onPlay: () => playSong(context, song),
                onToggleFavorite: () =>
                    context.read<FavoritesController>().toggle(song),
                onAddToPlaylist: () => showPlaylistPicker(context, song),
              ),
            ),
          const SizedBox(height: 28),
          HomeSectionTitle(
            title: 'Albumes',
            subtitle: 'Explora los lanzamientos disponibles en el catalogo.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: catalog.albums
                .map(
                  (album) => AlbumCard(
                    album: album,
                    onTap: () => _showAlbumDetail(context, album.id),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _showAlbumDetail(BuildContext context, String albumId) async {
    final album = await context.read<CatalogController>().loadAlbum(albumId);
    if (album == null || !context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: Text(
          album.title,
          style: const TextStyle(color: AppColors.white),
        ),
        content: SizedBox(
          width: 460,
          child: ListView(
            shrinkWrap: true,
            children: album.songs
                .map(
                  (song) => SongTile(
                    song: song,
                    isFavorite: context.read<FavoritesController>().contains(
                      song.id,
                    ),
                    onPlay: () => playSong(dialogContext, song),
                    onToggleFavorite: () =>
                        context.read<FavoritesController>().toggle(song),
                    onAddToPlaylist: () =>
                        showPlaylistPicker(dialogContext, song),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

// ─── FavoritesSection ─────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/controllers.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_box.dart';
import '../../../shared/widgets/app_gradient_button.dart';
import '../../../theme/app_colors.dart';
import '../helpers/home_dialogs.dart';
import '../widgets/home_hero_banner.dart';
import '../widgets/home_section_scroll.dart';
import '../widgets/playlist_card.dart';

class PlaylistsSection extends StatelessWidget {
  const PlaylistsSection({super.key});
  @override
  Widget build(BuildContext context) {
    final playlists = context.watch<PlaylistsController>();
    return HomeSectionScroll(
      onRefresh: () => context.read<PlaylistsController>().load(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeroBanner(
            title: 'Playlists',
            subtitle:
                'Crea listas privadas o publicas y agrega canciones desde cualquier vista.',
            trailing: AppGradientButton(
              label: 'Nueva playlist',
              icon: Icons.add_rounded,
              onPressed: () => showCreatePlaylistDialog(context),
            ),
          ),
          const SizedBox(height: 20),
          if (playlists.error != null) AppErrorBox(message: playlists.error!),
          if (playlists.loading)
            LinearProgressIndicator(
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(AppColors.purple),
            )
          else if (playlists.playlists.isEmpty)
            const AppEmptyState(message: 'Todavia no has creado playlists.')
          else
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: playlists.playlists
                  .map(
                    (playlist) => PlaylistCard(
                      playlist: playlist,
                      onTap: () => showPlaylistDetail(context, playlist),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

// ─── HistorySection ───────────────────────────────────────────────────────────

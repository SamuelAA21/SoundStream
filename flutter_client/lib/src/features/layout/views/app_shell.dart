import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/controllers.dart';
import '../../../theme/app_colors.dart';
import '../../home/sections/admin_section.dart';
import '../../home/sections/artist_section.dart';
import '../../home/sections/catalog_section.dart';
import '../../home/sections/favorites_section.dart';
import '../../home/sections/history_section.dart';
import '../../home/sections/playlists_section.dart';
import '../../home/sections/recommendations_section.dart';
import '../models/shell_page.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/app_side_rail.dart';
import '../widgets/player_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final catalogController = context.read<CatalogController>();
    final favoritesController = context.read<FavoritesController>();
    final playlistsController = context.read<PlaylistsController>();
    final historyController = context.read<HistoryController>();
    final recommendationsController = context.read<RecommendationsController>();
    final authController = context.read<AuthController>();
    final artistController = context.read<ArtistController>();
    final adminController = context.read<AdminController>();
    Future.microtask(() async {
      await catalogController.load();
      if (!mounted) return;
      await Future.wait([
        favoritesController.load(),
        playlistsController.load(),
        historyController.load(),
        recommendationsController.load(),
      ]);
      if (!mounted) return;
      if (authController.user?.isArtist == true) {
        await artistController.load();
      }
      if (!mounted) return;
      if (authController.user?.isAdmin == true) {
        await adminController.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final pages = <ShellPage>[
      ShellPage(
        label: 'Inicio',
        icon: Icons.home_rounded,
        builder: (_) => const CatalogSection(),
      ),
      ShellPage(
        label: 'Favoritos',
        icon: Icons.favorite_rounded,
        builder: (_) => const FavoritesSection(),
      ),
      ShellPage(
        label: 'Playlists',
        icon: Icons.library_music_rounded,
        builder: (_) => const PlaylistsSection(),
      ),
      ShellPage(
        label: 'Historial',
        icon: Icons.history_rounded,
        builder: (_) => const HistorySection(),
      ),
      ShellPage(
        label: 'Recomendado',
        icon: Icons.auto_awesome_rounded,
        builder: (_) => const RecommendationsSection(),
      ),
      if (auth.user?.isArtist == true)
        ShellPage(
          label: 'Artista',
          icon: Icons.mic_rounded,
          builder: (_) => const ArtistSection(),
        ),
      if (auth.user?.isAdmin == true)
        ShellPage(
          label: 'Admin',
          icon: Icons.admin_panel_settings_rounded,
          builder: (_) => const AdminSection(),
        ),
    ];

    if (_index >= pages.length) _index = 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1100;
        final selectedPage = pages[_index];
        final content = Column(
          children: [
            AppHeaderBar(
              title: selectedPage.label,
              onLogout: () => context.read<AuthController>().logout(),
            ),
            Expanded(child: selectedPage.builder(context)),
            const PlayerBar(),
          ],
        );

        if (!wide) {
          return Scaffold(
            backgroundColor: AppColors.dark,
            body: content,
            bottomNavigationBar: AppBottomNavBar(
              selectedIndex: _index,
              pages: pages,
              onTap: (i) => setState(() => _index = i),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.dark,
          body: Row(
            children: [
              AppSideRail(
                selectedIndex: _index,
                pages: pages,
                onTap: (i) => setState(() => _index = i),
              ),
              Expanded(child: content),
            ],
          ),
        );
      },
    );
  }
}

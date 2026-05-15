import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/controllers.dart';
import 'home_sections.dart';

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
    if (_loaded) {
      return;
    }
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
    final pages = <({String label, IconData icon, Widget page})>[
      (label: 'Inicio', icon: Icons.home_rounded, page: const CatalogSection()),
      (label: 'Favoritos', icon: Icons.favorite_rounded, page: const FavoritesSection()),
      (label: 'Playlists', icon: Icons.library_music_rounded, page: const PlaylistsSection()),
      (label: 'Historial', icon: Icons.history_rounded, page: const HistorySection()),
      (label: 'Recomendado', icon: Icons.auto_awesome_rounded, page: const RecommendationsSection()),
      if (auth.user?.isArtist == true)
        (label: 'Artista', icon: Icons.mic_rounded, page: const ArtistSection()),
      if (auth.user?.isAdmin == true)
        (label: 'Admin', icon: Icons.admin_panel_settings_rounded, page: const AdminSection()),
    ];

    if (_index >= pages.length) {
      _index = 0;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1100;
        final selectedPage = pages[_index];
        final content = Column(
          children: [
            _HeaderBar(
              title: selectedPage.label,
              onLogout: () => context.read<AuthController>().logout(),
            ),
            Expanded(child: selectedPage.page),
            const PlayerBar(),
          ],
        );

        if (!wide) {
          return Scaffold(
            body: content,
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (value) => setState(() => _index = value),
              destinations: [
                for (final page in pages)
                  NavigationDestination(icon: Icon(page.icon), label: page.label),
              ],
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: (value) => setState(() => _index = value),
                extended: true,
                minExtendedWidth: 220,
                leading: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.graphic_eq_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'SoundStream',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                destinations: [
                  for (final page in pages)
                    NavigationRailDestination(
                      icon: Icon(page.icon),
                      label: Text(page.label),
                    ),
                ],
              ),
              Expanded(child: content),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({
    required this.title,
    required this.onLogout,
  });

  final String title;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primaryContainer,
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text('Explora, organiza y publica tu catalogo musical.'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  child: Text(
                    _initialFor(auth.user?.name),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(auth.user?.name ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(auth.user?.role ?? ''),
                  ],
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: onLogout,
                  tooltip: 'Cerrar sesion',
                  icon: const Icon(Icons.logout_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _initialFor(String? name) {
  if (name == null || name.trim().isEmpty) {
    return 'S';
  }
  return name.trim()[0].toUpperCase();
}

class PlayerBar extends StatelessWidget {
  const PlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final song = player.currentSong;
    if (song == null) {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).colorScheme;
    final sliderMax = (player.duration.inSeconds <= 0 ? 1 : player.duration.inSeconds).toDouble();
    final sliderValue = player.position.inSeconds <= 0
        ? 0.0
        : (player.position.inSeconds.toDouble() > sliderMax
            ? sliderMax
            : player.position.inSeconds.toDouble());

    return Material(
      color: colors.surface,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5))),
          gradient: LinearGradient(
            colors: [Colors.white, colors.surfaceContainerLowest],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [colors.primary, colors.secondary],
                    ),
                  ),
                  child: const Icon(Icons.music_note_rounded, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text('${song.artist} • ${song.genre}'),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => player.seekRelative(-10),
                  icon: const Icon(Icons.replay_10_rounded),
                ),
                FilledButton.tonal(
                  onPressed: player.isPlaying ? player.pause : player.resume,
                  child: Icon(player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => player.seekRelative(10),
                  icon: const Icon(Icons.forward_10_rounded),
                ),
              ],
            ),
            Slider(
              value: sliderValue,
              max: sliderMax,
              onChanged: (_) {},
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(player.position)),
                Text(_formatDuration(player.duration)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/controllers.dart';
import 'home_sections.dart';

// ─── Paleta vibrante (igual que auth_page) ────────────────────────────────────
class _C {
  static const purple   = Color(0xFF7C3AED);
  static const pink     = Color(0xFFEC4899);
  static const cyan     = Color(0xFF06B6D4);
  static const dark     = Color(0xFF0F0A1E);
  static const darkCard = Color(0xFF1A1030);
  static const surface  = Color(0xFF231845);
  static const border   = Color(0xFF3D2D6B);
  static const textMid  = Color(0xFFB8A9D9);
  static const white    = Colors.white;
}

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
    final pages = <({String label, IconData icon, Widget page})>[
      (label: 'Inicio',       icon: Icons.home_rounded,               page: const CatalogSection()),
      (label: 'Favoritos',    icon: Icons.favorite_rounded,           page: const FavoritesSection()),
      (label: 'Playlists',    icon: Icons.library_music_rounded,      page: const PlaylistsSection()),
      (label: 'Historial',    icon: Icons.history_rounded,            page: const HistorySection()),
      (label: 'Recomendado',  icon: Icons.auto_awesome_rounded,       page: const RecommendationsSection()),
      if (auth.user?.isArtist == true)
        (label: 'Artista',    icon: Icons.mic_rounded,                page: const ArtistSection()),
      if (auth.user?.isAdmin == true)
        (label: 'Admin',      icon: Icons.admin_panel_settings_rounded, page: const AdminSection()),
    ];

    if (_index >= pages.length) _index = 0;

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
            backgroundColor: _C.dark,
            body: content,
            bottomNavigationBar: _DarkNavBar(
              selectedIndex: _index,
              pages: pages,
              onTap: (i) => setState(() => _index = i),
            ),
          );
        }

        return Scaffold(
          backgroundColor: _C.dark,
          body: Row(
            children: [
              _DarkRail(
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

// ─── Navigation Rail oscuro ───────────────────────────────────────────────────
class _DarkRail extends StatelessWidget {
  const _DarkRail({
    required this.selectedIndex,
    required this.pages,
    required this.onTap,
  });

  final int selectedIndex;
  final List<({String label, IconData icon, Widget page})> pages;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: _C.darkCard,
        border: Border(right: BorderSide(color: _C.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 32),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [_C.purple, _C.pink],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.graphic_eq_rounded, color: _C.white, size: 22),
                ),
                const SizedBox(width: 10),
                const Text('SoundStream',
                  style: TextStyle(
                    color: _C.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: pages.length,
              itemBuilder: (context, i) {
                final page = pages[i];
                final selected = i == selectedIndex;
                return GestureDetector(
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: selected
                          ? const LinearGradient(colors: [_C.purple, _C.pink])
                          : null,
                      color: selected ? null : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Icon(page.icon,
                          color: selected ? _C.white : _C.textMid,
                          size: 20),
                        const SizedBox(width: 12),
                        Text(page.label,
                          style: TextStyle(
                            color: selected ? _C.white : _C.textMid,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Nav oscuro ────────────────────────────────────────────────────────
class _DarkNavBar extends StatelessWidget {
  const _DarkNavBar({
    required this.selectedIndex,
    required this.pages,
    required this.onTap,
  });

  final int selectedIndex;
  final List<({String label, IconData icon, Widget page})> pages;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.darkCard,
        border: Border(top: BorderSide(color: _C.border)),
      ),
      child: Row(
        children: List.generate(pages.length, (i) {
          final page = pages[i];
          final selected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(page.icon,
                      color: selected ? _C.purple : _C.textMid,
                      size: 22),
                    const SizedBox(height: 4),
                    Text(page.label,
                      style: TextStyle(
                        color: selected ? _C.purple : _C.textMid,
                        fontSize: 11,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Header Bar oscuro ────────────────────────────────────────────────────────
class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.title, required this.onLogout});
  final String title;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      decoration: BoxDecoration(
        color: _C.darkCard,
        border: Border(bottom: BorderSide(color: _C.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [_C.white, _C.cyan],
                  ).createShader(b),
                  child: Text(title,
                    style: const TextStyle(
                      color: _C.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text('Explora, organiza y publica tu catalogo musical.',
                  style: TextStyle(color: _C.textMid, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _C.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [_C.purple, _C.pink]),
                  ),
                  child: Center(
                    child: Text(
                      _initialFor(auth.user?.name),
                      style: const TextStyle(color: _C.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(auth.user?.name ?? '',
                      style: const TextStyle(color: _C.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    Text(auth.user?.role ?? '',
                      style: TextStyle(color: _C.textMid, fontSize: 12)),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onLogout,
                  tooltip: 'Cerrar sesion',
                  icon: const Icon(Icons.logout_rounded, color: _C.textMid, size: 20),
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
  if (name == null || name.trim().isEmpty) return 'S';
  return name.trim()[0].toUpperCase();
}

// ─── Player Bar oscuro ────────────────────────────────────────────────────────
class PlayerBar extends StatelessWidget {
  const PlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final song = player.currentSong;
    if (song == null) return const SizedBox.shrink();

    final sliderMax = (player.duration.inSeconds <= 0 ? 1 : player.duration.inSeconds).toDouble();
    final sliderValue = player.position.inSeconds <= 0
        ? 0.0
        : (player.position.inSeconds.toDouble() > sliderMax
            ? sliderMax
            : player.position.inSeconds.toDouble());

    return Container(
      decoration: BoxDecoration(
        color: _C.darkCard,
        border: Border(top: BorderSide(color: _C.border)),
        boxShadow: [
          BoxShadow(
            color: _C.purple.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(colors: [_C.purple, _C.pink]),
                ),
                child: const Icon(Icons.music_note_rounded, color: _C.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(song.title,
                      style: const TextStyle(color: _C.white, fontWeight: FontWeight.w800)),
                    Text('${song.artist} • ${song.genre}',
                      style: TextStyle(color: _C.textMid, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => player.seekRelative(-10),
                icon: const Icon(Icons.replay_10_rounded, color: _C.textMid),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [_C.purple, _C.pink]),
                ),
                child: IconButton(
                  onPressed: player.isPlaying ? player.pause : player.resume,
                  icon: Icon(
                    player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: _C.white,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => player.seekRelative(10),
                icon: const Icon(Icons.forward_10_rounded, color: _C.textMid),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _C.purple,
              inactiveTrackColor: _C.border,
              thumbColor: _C.pink,
              overlayColor: _C.purple.withValues(alpha: 0.2),
              trackHeight: 3,
            ),
            child: Slider(value: sliderValue, max: sliderMax, onChanged: (_) {}),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(player.position),
                style: TextStyle(color: _C.textMid, fontSize: 12)),
              Text(_formatDuration(player.duration),
                style: TextStyle(color: _C.textMid, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration value) {
    final m = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/controllers.dart';
import '../models/domain_models.dart';

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

// ─── CatalogSection ───────────────────────────────────────────────────────────
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

    return _SectionScroll(
      onRefresh: () => context.read<CatalogController>().load(searchQuery: _searchController.text),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroBanner(
            title: 'Catalogo vivo',
            subtitle: 'Busca, reproduce y organiza musica desde una interfaz mas limpia.',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MetricChip(label: 'Canciones', value: '${catalog.songs.length}'),
                const SizedBox(width: 10),
                _MetricChip(label: 'Albumes', value: '${catalog.albums.length}'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _Panel(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: _C.white),
                        decoration: InputDecoration(
                          hintText: 'Buscar por titulo, artista o genero',
                          hintStyle: TextStyle(color: _C.textMid),
                          prefixIcon: Icon(Icons.search_rounded, color: _C.textMid),
                          filled: true,
                          fillColor: _C.dark,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: _C.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: _C.purple, width: 1.5),
                          ),
                        ),
                        onSubmitted: (value) =>
                            context.read<CatalogController>().load(searchQuery: value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _GradientButton(
                      label: 'Buscar',
                      icon: Icons.tune_rounded,
                      onPressed: () => context.read<CatalogController>()
                          .load(searchQuery: _searchController.text),
                    ),
                  ],
                ),
                if (catalog.loading) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    backgroundColor: _C.border,
                    valueColor: AlwaysStoppedAnimation(_C.purple),
                  ),
                ],
                if (catalog.error != null) ...[
                  const SizedBox(height: 16),
                  _ErrorBox(message: catalog.error!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Canciones', subtitle: 'Todo el material disponible para streaming protegido.'),
          const SizedBox(height: 12),
          if (!catalog.loading && catalog.songs.isEmpty)
            const _EmptyState(message: 'No hay canciones disponibles.')
          else
            ...catalog.songs.map((song) => SongTile(
              song: song,
              isFavorite: favorites.contains(song.id),
              onPlay: () => _playSong(context, song),
              onToggleFavorite: () => context.read<FavoritesController>().toggle(song),
              onAddToPlaylist: () => _showPlaylistPicker(context, song),
            )),
          const SizedBox(height: 28),
          _SectionTitle(title: 'Albumes', subtitle: 'Explora los lanzamientos disponibles en el catalogo.'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14, runSpacing: 14,
            children: catalog.albums.map((album) => _AlbumCard(
              album: album,
              onTap: () => _showAlbumDetail(context, album.id),
            )).toList(),
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
        backgroundColor: _C.darkCard,
        title: Text(album.title, style: const TextStyle(color: _C.white)),
        content: SizedBox(
          width: 460,
          child: ListView(
            shrinkWrap: true,
            children: album.songs.map((song) => SongTile(
              song: song,
              isFavorite: context.read<FavoritesController>().contains(song.id),
              onPlay: () => _playSong(dialogContext, song),
              onToggleFavorite: () => context.read<FavoritesController>().toggle(song),
              onAddToPlaylist: () => _showPlaylistPicker(dialogContext, song),
            )).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── FavoritesSection ─────────────────────────────────────────────────────────
class FavoritesSection extends StatelessWidget {
  const FavoritesSection({super.key});
  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesController>();
    return _SectionScroll(
      onRefresh: () => context.read<FavoritesController>().load(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeroBanner(
            title: 'Favoritos',
            subtitle: 'Tus canciones marcadas para volver rapido a lo mejor de tu biblioteca.',
          ),
          const SizedBox(height: 20),
          if (favorites.error != null) _ErrorBox(message: favorites.error!),
          if (favorites.loading)
            LinearProgressIndicator(backgroundColor: _C.border, valueColor: AlwaysStoppedAnimation(_C.purple))
          else if (favorites.favorites.isEmpty)
            const _EmptyState(message: 'Aun no has marcado canciones como favoritas.')
          else
            ...favorites.favorites.map((song) => SongTile(
              song: song,
              isFavorite: true,
              onPlay: () => _playSong(context, song, source: 'favorite'),
              onToggleFavorite: () => context.read<FavoritesController>().toggle(song),
              onAddToPlaylist: () => _showPlaylistPicker(context, song),
            )),
        ],
      ),
    );
  }
}

// ─── PlaylistsSection ─────────────────────────────────────────────────────────
class PlaylistsSection extends StatelessWidget {
  const PlaylistsSection({super.key});
  @override
  Widget build(BuildContext context) {
    final playlists = context.watch<PlaylistsController>();
    return _SectionScroll(
      onRefresh: () => context.read<PlaylistsController>().load(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroBanner(
            title: 'Playlists',
            subtitle: 'Crea listas privadas o publicas y agrega canciones desde cualquier vista.',
            trailing: _GradientButton(
              label: 'Nueva playlist',
              icon: Icons.add_rounded,
              onPressed: () => _showCreatePlaylistDialog(context),
            ),
          ),
          const SizedBox(height: 20),
          if (playlists.error != null) _ErrorBox(message: playlists.error!),
          if (playlists.loading)
            LinearProgressIndicator(backgroundColor: _C.border, valueColor: AlwaysStoppedAnimation(_C.purple))
          else if (playlists.playlists.isEmpty)
            const _EmptyState(message: 'Todavia no has creado playlists.')
          else
            Wrap(
              spacing: 14, runSpacing: 14,
              children: playlists.playlists.map((playlist) => _PlaylistCard(
                playlist: playlist,
                onTap: () => _showPlaylistDetail(context, playlist),
              )).toList(),
            ),
        ],
      ),
    );
  }
}

// ─── HistorySection ───────────────────────────────────────────────────────────
class HistorySection extends StatelessWidget {
  const HistorySection({super.key});
  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryController>();
    return _SectionScroll(
      onRefresh: () => context.read<HistoryController>().load(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeroBanner(
            title: 'Historial',
            subtitle: 'Cada escucha ayuda a trazar el comportamiento musical y alimentar recomendaciones.',
          ),
          const SizedBox(height: 20),
          if (history.error != null) _ErrorBox(message: history.error!),
          if (history.loading)
            LinearProgressIndicator(backgroundColor: _C.border, valueColor: AlwaysStoppedAnimation(_C.purple))
          else if (history.entries.isEmpty)
            const _EmptyState(message: 'No hay reproducciones registradas todavia.')
          else
            ...history.entries.map((entry) => _Panel(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _C.purple.withValues(alpha: 0.18),
                  ),
                  child: const Icon(Icons.history_rounded, color: _C.purple, size: 20),
                ),
                title: Text(entry.title,
                  style: const TextStyle(color: _C.white, fontWeight: FontWeight.w700)),
                subtitle: Text(
                  '${entry.artist} • ${entry.genre} • ${entry.playedSeconds}s • ${entry.completionRate.toStringAsFixed(1)}%',
                  style: TextStyle(color: _C.textMid, fontSize: 12),
                ),
                trailing: Text(_formatDate(entry.startedAt),
                  style: TextStyle(color: _C.textMid, fontSize: 11)),
              ),
            )),
        ],
      ),
    );
  }
}

// ─── RecommendationsSection ───────────────────────────────────────────────────
class RecommendationsSection extends StatelessWidget {
  const RecommendationsSection({super.key});
  @override
  Widget build(BuildContext context) {
    final recommendations = context.watch<RecommendationsController>();
    final favorites = context.watch<FavoritesController>();
    return _SectionScroll(
      onRefresh: () => context.read<RecommendationsController>().refresh(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroBanner(
            title: 'Recomendaciones',
            subtitle: 'El motor hibrido combina historial, favoritos y patrones de interaccion.',
            trailing: _GradientButton(
              label: 'Recalcular',
              icon: Icons.refresh_rounded,
              onPressed: () => context.read<RecommendationsController>().refresh(),
            ),
          ),
          const SizedBox(height: 20),
          if (recommendations.error != null) _ErrorBox(message: recommendations.error!),
          if (recommendations.loading)
            LinearProgressIndicator(backgroundColor: _C.border, valueColor: AlwaysStoppedAnimation(_C.purple))
          else if (recommendations.items.isEmpty)
            const _EmptyState(message: 'No hay recomendaciones disponibles.')
          else
            ...recommendations.items.map((item) {
              final song = item.toSong();
              return SongTile(
                song: song,
                isFavorite: favorites.contains(item.id),
                onPlay: () => _playSong(context, song, source: 'recommendation'),
                onToggleFavorite: () => context.read<FavoritesController>().toggle(song),
                onAddToPlaylist: () => _showPlaylistPicker(context, song),
                extra: item.reason == null ? null : Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(item.reason!,
                    style: TextStyle(color: _C.cyan, fontSize: 12)),
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ─── ArtistSection ────────────────────────────────────────────────────────────
class ArtistSection extends StatefulWidget {
  const ArtistSection({super.key});
  @override
  State<ArtistSection> createState() => _ArtistSectionState();
}

class _ArtistSectionState extends State<ArtistSection> {
  final _title = TextEditingController();
  final _genre = TextEditingController();
  final _duration = TextEditingController();
  final _collaborators = TextEditingController();
  final _albumTitle = TextEditingController();
  final _albumGenre = TextEditingController();
  final Set<String> _selectedSongs = {};

  @override
  void dispose() {
    _title.dispose(); _genre.dispose(); _duration.dispose();
    _collaborators.dispose(); _albumTitle.dispose(); _albumGenre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final artist = context.watch<ArtistController>();
    final auth = context.watch<AuthController>();
    final catalog = context.watch<CatalogController>();
    final ownAlbums = catalog.albums.where((a) => a.artist == auth.user?.artist?.name).toList();

    return _SectionScroll(
      onRefresh: () async {
        await context.read<ArtistController>().load();
        if (!context.mounted) return;
        await context.read<CatalogController>().load();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroBanner(
            title: 'Estudio del artista',
            subtitle: 'Sube canciones sueltas, crea albumes vacios o arma un lanzamiento con el material actual.',
            trailing: _MetricChip(label: 'Mis canciones', value: '${artist.songs.length}'),
          ),
          const SizedBox(height: 20),
          if (artist.error != null) _ErrorBox(message: artist.error!),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(title: 'Nueva cancion', subtitle: 'Puedes subirla sola y asignarla al album despues.'),
                const SizedBox(height: 14),
                Wrap(spacing: 12, runSpacing: 12, children: [
                  _FieldBox(width: 240, child: _DarkTextField(controller: _title, label: 'Titulo')),
                  _FieldBox(width: 180, child: _DarkTextField(controller: _genre, label: 'Genero')),
                  _FieldBox(width: 180, child: _DarkTextField(controller: _duration, label: 'Duracion en segundos')),
                  _FieldBox(width: 260, child: _DarkTextField(controller: _collaborators, label: 'Colaboradores separados por coma')),
                ]),
                const SizedBox(height: 14),
                Wrap(spacing: 12, runSpacing: 12, children: [
                  OutlinedButton.icon(
                    onPressed: artist.pickFile,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _C.textMid,
                      side: const BorderSide(color: _C.border),
                    ),
                    icon: const Icon(Icons.audio_file_rounded),
                    label: Text(artist.selectedFile?.name ?? 'Seleccionar audio'),
                  ),
                  _GradientButton(
                    label: 'Subir cancion',
                    icon: Icons.cloud_upload_rounded,
                    onPressed: artist.submitting ? null : () async {
                      await context.read<ArtistController>().uploadSong(
                        title: _title.text.trim(),
                        genreName: _genre.text.trim(),
                        durationSeconds: _duration.text.trim(),
                        collaboratorNames: _collaborators.text.trim(),
                      );
                      if (!context.mounted) return;
                      await context.read<CatalogController>().load();
                    },
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(title: 'Nuevo album', subtitle: 'Puedes crearlo vacio o inicializarlo con canciones ya subidas.'),
                const SizedBox(height: 14),
                Wrap(spacing: 12, runSpacing: 12, children: [
                  _FieldBox(width: 260, child: _DarkTextField(controller: _albumTitle, label: 'Titulo del album')),
                  _FieldBox(width: 200, child: _DarkTextField(controller: _albumGenre, label: 'Genero opcional')),
                ]),
                const SizedBox(height: 12),
                Wrap(spacing: 10, runSpacing: 10,
                  children: artist.songs.map((song) => FilterChip(
                    label: Text(song.title, style: const TextStyle(color: _C.white, fontSize: 13)),
                    selected: _selectedSongs.contains(song.id),
                    backgroundColor: _C.surface,
                    selectedColor: _C.purple.withValues(alpha: 0.35),
                    side: BorderSide(color: _selectedSongs.contains(song.id) ? _C.purple : _C.border),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) _selectedSongs.add(song.id);
                        else _selectedSongs.remove(song.id);
                      });
                    },
                  )).toList(),
                ),
                const SizedBox(height: 14),
                _GradientButton(
                  label: 'Crear album',
                  icon: Icons.album_rounded,
                  onPressed: artist.submitting ? null : () async {
                    try {
                      await context.read<ArtistController>().createAlbum(
                        title: _albumTitle.text.trim(),
                        genreName: _albumGenre.text.trim(),
                        songIds: _selectedSongs.toList(),
                      );
                      if (!context.mounted) return;
                      _selectedSongs.clear();
                      await context.read<CatalogController>().load();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Album creado correctamente')));
                      setState(() {});
                    } catch (_) {}
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Mis canciones', subtitle: 'Publica, elimina o asigna cada cancion a un album existente.'),
          const SizedBox(height: 12),
          ...artist.songs.map((song) => _EditorialSongCard(
            song: song,
            subtitle: '${song.genre} • ${song.album ?? 'Sin album'}',
            published: song.isPublished ?? false,
            onTogglePublication: (value) => context.read<ArtistController>().setPublication(song.id, value),
            onDelete: () async {
              await context.read<ArtistController>().deleteSong(song.id);
              if (!context.mounted) return;
              await context.read<CatalogController>().load();
            },
            onAssignAlbum: () => _showArtistAlbumAssignmentDialog(context, song: song, albums: ownAlbums),
          )),
        ],
      ),
    );
  }
}

// ─── AdminSection ─────────────────────────────────────────────────────────────
class AdminSection extends StatefulWidget {
  const AdminSection({super.key});
  @override
  State<AdminSection> createState() => _AdminSectionState();
}

class _AdminSectionState extends State<AdminSection> {
  final _songTitle = TextEditingController();
  final _artistName = TextEditingController();
  final _genreName = TextEditingController();
  final _duration = TextEditingController();
  final _albumTitle = TextEditingController();
  final _albumArtistName = TextEditingController();
  final _albumGenre = TextEditingController();
  final Set<String> _selectedSongIds = {};

  @override
  void dispose() {
    _songTitle.dispose(); _artistName.dispose(); _genreName.dispose();
    _duration.dispose(); _albumTitle.dispose(); _albumArtistName.dispose();
    _albumGenre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final catalog = context.watch<CatalogController>();

    return _SectionScroll(
      onRefresh: () async {
        await context.read<AdminController>().load();
        if (!context.mounted) return;
        await context.read<CatalogController>().load();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroBanner(
            title: 'Consola administrativa',
            subtitle: 'Gestiona usuarios y cataloga canciones sueltas o albumes con mas flexibilidad.',
            trailing: _MetricChip(label: 'Usuarios', value: '${admin.users.length}'),
          ),
          const SizedBox(height: 20),
          if (admin.error != null) _ErrorBox(message: admin.error!),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(title: 'Usuarios', subtitle: 'Actualiza el estado sin salir del panel principal.'),
                const SizedBox(height: 10),
                ...admin.users.map((user) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _C.dark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _C.purple.withValues(alpha: 0.2),
                        ),
                        child: const Icon(Icons.person_rounded, color: _C.purple, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: const TextStyle(color: _C.white, fontWeight: FontWeight.w700)),
                            Text('${user.email} • ${user.role}',
                              style: TextStyle(color: _C.textMid, fontSize: 12)),
                          ],
                        ),
                      ),
                      DropdownButton<String>(
                        value: user.status,
                        dropdownColor: _C.darkCard,
                        style: const TextStyle(color: _C.white),
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'active', child: Text('active')),
                          DropdownMenuItem(value: 'inactive', child: Text('inactive')),
                          DropdownMenuItem(value: 'blocked', child: Text('blocked')),
                        ],
                        onChanged: (value) {
                          if (value != null) context.read<AdminController>().updateUserStatus(user.id, value);
                        },
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(title: 'Subir cancion al catalogo', subtitle: 'Una cancion puede existir sola y luego sumarse a un album.'),
                const SizedBox(height: 14),
                Wrap(spacing: 12, runSpacing: 12, children: [
                  _FieldBox(width: 220, child: _DarkTextField(controller: _songTitle, label: 'Titulo')),
                  _FieldBox(width: 220, child: _DarkTextField(controller: _artistName, label: 'Artista')),
                  _FieldBox(width: 180, child: _DarkTextField(controller: _genreName, label: 'Genero')),
                  _FieldBox(width: 160, child: _DarkTextField(controller: _duration, label: 'Duracion')),
                ]),
                const SizedBox(height: 14),
                Wrap(spacing: 12, runSpacing: 12, children: [
                  OutlinedButton.icon(
                    onPressed: admin.pickFile,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _C.textMid,
                      side: const BorderSide(color: _C.border),
                    ),
                    icon: const Icon(Icons.audio_file_rounded),
                    label: Text(admin.selectedFile?.name ?? 'Seleccionar audio'),
                  ),
                  _GradientButton(
                    label: 'Subir cancion',
                    icon: Icons.library_add_rounded,
                    onPressed: admin.submitting ? null : () async {
                      try {
                        await context.read<AdminController>().uploadSong(
                          title: _songTitle.text.trim(),
                          artistName: _artistName.text.trim(),
                          genreName: _genreName.text.trim(),
                          durationSeconds: _duration.text.trim(),
                        );
                        if (!context.mounted) return;
                        await context.read<CatalogController>().load();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cancion subida al catalogo')));
                      } catch (_) {}
                    },
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(title: 'Crear album', subtitle: 'Puedes crearlo vacio si defines el artista, o con canciones seleccionadas.'),
                const SizedBox(height: 14),
                Wrap(spacing: 12, runSpacing: 12, children: [
                  _FieldBox(width: 240, child: _DarkTextField(controller: _albumTitle, label: 'Titulo del album')),
                  _FieldBox(width: 220, child: _DarkTextField(controller: _albumArtistName, label: 'Artista para album vacio')),
                  _FieldBox(width: 180, child: _DarkTextField(controller: _albumGenre, label: 'Genero opcional')),
                ]),
                const SizedBox(height: 12),
                Wrap(spacing: 10, runSpacing: 10,
                  children: catalog.songs.map((song) => FilterChip(
                    label: Text('${song.title} • ${song.artist}',
                      style: const TextStyle(color: _C.white, fontSize: 13)),
                    selected: _selectedSongIds.contains(song.id),
                    backgroundColor: _C.surface,
                    selectedColor: _C.purple.withValues(alpha: 0.35),
                    side: BorderSide(color: _selectedSongIds.contains(song.id) ? _C.purple : _C.border),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) _selectedSongIds.add(song.id);
                        else _selectedSongIds.remove(song.id);
                      });
                    },
                  )).toList(),
                ),
                const SizedBox(height: 14),
                _GradientButton(
                  label: 'Crear album',
                  icon: Icons.album_outlined,
                  onPressed: admin.submitting ? null : () async {
                    try {
                      await context.read<AdminController>().createAlbum(
                        title: _albumTitle.text.trim(),
                        artistName: _albumArtistName.text.trim(),
                        genreName: _albumGenre.text.trim(),
                        songIds: _selectedSongIds.toList(),
                      );
                      if (!context.mounted) return;
                      _selectedSongIds.clear();
                      await context.read<CatalogController>().load();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Album creado correctamente')));
                      setState(() {});
                    } catch (_) {}
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Catalogo administrable', subtitle: 'Asigna canciones a albumes, quitalas de un album o desactivalas.'),
          const SizedBox(height: 12),
          ...catalog.songs.map((song) => _EditorialSongCard(
            song: song,
            subtitle: '${song.artist} • ${song.genre} • ${song.album ?? 'Sin album'}',
            published: true,
            showPublicationToggle: false,
            onDelete: () async {
              await context.read<AdminController>().deleteSong(song.id);
              if (!context.mounted) return;
              await context.read<CatalogController>().load();
            },
            onAssignAlbum: () => _showAdminAlbumAssignmentDialog(
              context,
              song: song,
              albums: catalog.albums.where((a) => a.artist == song.artist).toList(),
            ),
          )),
        ],
      ),
    );
  }
}

// ─── SongTile ─────────────────────────────────────────────────────────────────
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
    return _Panel(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [_C.purple.withValues(alpha: 0.6), _C.pink.withValues(alpha: 0.6)],
              ),
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
                const SizedBox(height: 3),
                Text('${song.artist} • ${song.album ?? 'Sin album'} • ${song.genre}',
                  style: TextStyle(color: _C.textMid, fontSize: 12)),
                if (extra != null) extra!,
              ],
            ),
          ),
          Wrap(spacing: 4, children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [_C.purple, _C.pink]),
              ),
              child: IconButton(
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow_rounded, color: _C.white, size: 20),
              ),
            ),
            IconButton(
              onPressed: onToggleFavorite,
              icon: Icon(
                isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFavorite ? _C.pink : _C.textMid,
              ),
            ),
            IconButton(
              onPressed: onAddToPlaylist,
              icon: const Icon(Icons.playlist_add_rounded, color: _C.textMid),
            ),
          ]),
        ],
      ),
    );
  }
}

// ─── _EditorialSongCard ───────────────────────────────────────────────────────
class _EditorialSongCard extends StatelessWidget {
  const _EditorialSongCard({
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
    return _Panel(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(song.title,
                      style: const TextStyle(color: _C.white, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: _C.textMid, fontSize: 12)),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: onAssignAlbum,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _C.purple,
                  side: const BorderSide(color: _C.border),
                ),
                icon: const Icon(Icons.album_rounded, size: 16),
                label: const Text('Asignar album'),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => onDelete(),
                icon: const Icon(Icons.delete_outline_rounded, color: _C.textMid),
              ),
            ],
          ),
          if (showPublicationToggle) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              value: published,
              onChanged: onTogglePublication,
              activeColor: _C.purple,
              title: Text(published ? 'Publicada' : 'Oculta',
                style: TextStyle(color: _C.textMid, fontSize: 13)),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── _AlbumCard ───────────────────────────────────────────────────────────────
class _AlbumCard extends StatelessWidget {
  const _AlbumCard({required this.album, required this.onTap});
  final Album album;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _C.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.border),
          boxShadow: [
            BoxShadow(
              color: _C.purple.withValues(alpha: 0.1),
              blurRadius: 20, offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(colors: [_C.purple, _C.cyan]),
              ),
              child: const Icon(Icons.album_rounded, color: _C.white),
            ),
            const SizedBox(height: 14),
            Text(album.title,
              style: const TextStyle(color: _C.white, fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 6),
            Text(album.artist, style: TextStyle(color: _C.textMid, fontSize: 12)),
            Text(album.genre ?? 'Sin genero', style: TextStyle(color: _C.textMid, fontSize: 12)),
            const SizedBox(height: 10),
            Text('${album.songCount} canciones',
              style: const TextStyle(color: _C.cyan, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─── _PlaylistCard ────────────────────────────────────────────────────────────
class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({required this.playlist, required this.onTap});
  final PlaylistSummary playlist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: _Panel(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(colors: [_C.pink, _C.purple]),
              ),
              child: const Icon(Icons.queue_music_rounded, color: _C.white, size: 22),
            ),
            const SizedBox(height: 12),
            Text(playlist.name,
              style: const TextStyle(color: _C.white, fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 6),
            Text(playlist.description?.isNotEmpty == true ? playlist.description! : 'Sin descripcion',
              style: TextStyle(color: _C.textMid, fontSize: 12)),
            const SizedBox(height: 10),
            Text('${playlist.songCount} canciones • ${playlist.isPublic ? 'Publica' : 'Privada'}',
              style: const TextStyle(color: _C.cyan, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─── _HeroBanner ─────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.title, required this.subtitle, this.trailing});
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _C.purple.withValues(alpha: 0.3),
            blurRadius: 30, offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Wrap(
        spacing: 20, runSpacing: 20,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: const TextStyle(
                    color: _C.white, fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(subtitle,
                  style: TextStyle(color: _C.white.withValues(alpha: 0.85), fontSize: 14, height: 1.5)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── _MetricChip ─────────────────────────────────────────────────────────────
class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: _C.white, fontWeight: FontWeight.w800, fontSize: 18)),
          Text(label, style: TextStyle(color: _C.white.withValues(alpha: 0.85), fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── _SectionTitle ────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
          style: const TextStyle(color: _C.white, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: _C.textMid, fontSize: 13)),
      ],
    );
  }
}

// ─── _Panel ───────────────────────────────────────────────────────────────────
class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(18), this.width});
  final Widget child;
  final EdgeInsets padding;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _C.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── _GradientButton ─────────────────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.icon, required this.onPressed});
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: onPressed == null
            ? null
            : const LinearGradient(colors: [_C.purple, _C.pink]),
        color: onPressed == null ? _C.border : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: _C.white, size: 18),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(
                color: _C.white, fontWeight: FontWeight.w700, fontSize: 14)),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── _DarkTextField ───────────────────────────────────────────────────────────
class _DarkTextField extends StatelessWidget {
  const _DarkTextField({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: _C.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _C.textMid, fontSize: 13),
        filled: true,
        fillColor: _C.dark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.purple, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

// ─── _FieldBox ───────────────────────────────────────────────────────────────
class _FieldBox extends StatelessWidget {
  const _FieldBox({required this.width, required this.child});
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(width: width, child: child);
}

// ─── _ErrorBox ───────────────────────────────────────────────────────────────
class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
      ]),
    );
  }
}

// ─── _EmptyState ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(children: [
        const Icon(Icons.inbox_rounded, color: _C.purple),
        const SizedBox(width: 12),
        Expanded(child: Text(message, style: TextStyle(color: _C.textMid))),
      ]),
    );
  }
}

// ─── _SectionScroll ───────────────────────────────────────────────────────────
class _SectionScroll extends StatelessWidget {
  const _SectionScroll({required this.child, required this.onRefresh});
  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _C.purple,
      backgroundColor: _C.darkCard,
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [child],
      ),
    );
  }
}

// ─── Dialogs y helpers ────────────────────────────────────────────────────────
Future<void> _showPlaylistPicker(BuildContext context, Song song) async {
  final playlists = context.read<PlaylistsController>();
  if (playlists.playlists.isEmpty) {
    await _showSnack(context, 'Primero crea una playlist');
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: _C.darkCard,
      title: const Text('Agregar a playlist', style: TextStyle(color: _C.white)),
      content: SizedBox(
        width: 340,
        child: ListView(
          shrinkWrap: true,
          children: playlists.playlists.map((playlist) => ListTile(
            title: Text(playlist.name, style: const TextStyle(color: _C.white)),
            subtitle: Text('${playlist.songCount} canciones',
              style: TextStyle(color: _C.textMid)),
            onTap: () async {
              try {
                await context.read<PlaylistsController>().addSong(
                  playlistId: playlist.id, songId: song.id);
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                if (context.mounted) await _showSnack(context, 'Cancion agregada a ${playlist.name}');
              } catch (_) {}
            },
          )).toList(),
        ),
      ),
    ),
  );
}

Future<void> _showCreatePlaylistDialog(BuildContext context) async {
  final name = TextEditingController();
  final description = TextEditingController();
  bool isPublic = false;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: _C.darkCard,
        title: const Text('Nueva playlist', style: TextStyle(color: _C.white)),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DarkTextField(controller: name, label: 'Nombre'),
              const SizedBox(height: 12),
              _DarkTextField(controller: description, label: 'Descripcion'),
              SwitchListTile(
                value: isPublic,
                activeColor: _C.purple,
                onChanged: (value) => setState(() => isPublic = value),
                title: const Text('Publica', style: TextStyle(color: _C.white)),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar', style: TextStyle(color: _C.textMid)),
          ),
          _GradientButton(
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

Future<void> _showPlaylistDetail(BuildContext context, PlaylistSummary playlist) async {
  final detail = await context.read<PlaylistsController>().open(playlist.id);
  if (detail == null || !context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: _C.darkCard,
      title: Text(playlist.name, style: const TextStyle(color: _C.white)),
      content: SizedBox(
        width: 460,
        child: ListView(
          shrinkWrap: true,
          children: detail.songs.map((song) => ListTile(
            title: Text(song.title, style: const TextStyle(color: _C.white)),
            subtitle: Text('${song.artist} • ${song.genre}',
              style: TextStyle(color: _C.textMid)),
            trailing: IconButton(
              onPressed: () => context.read<PlaylistsController>().removeSong(
                playlistId: playlist.id, songId: song.id),
              icon: const Icon(Icons.remove_circle_outline_rounded, color: _C.pink),
            ),
          )).toList(),
        ),
      ),
    ),
  );
}

Future<void> _showArtistAlbumAssignmentDialog(
  BuildContext context, {required Song song, required List<Album> albums}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: _C.darkCard,
      title: Text('Asignar album a ${song.title}', style: const TextStyle(color: _C.white)),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Quitar del album', style: TextStyle(color: _C.white)),
              subtitle: Text('Dejar la cancion como lanzamiento suelto',
                style: TextStyle(color: _C.textMid)),
              onTap: () async {
                await context.read<ArtistController>().assignSongToAlbum(songId: song.id, albumId: null);
                if (!context.mounted) return;
                await context.read<CatalogController>().load();
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
            ),
            Divider(color: _C.border),
            if (albums.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Todavia no tienes albumes creados.',
                  style: TextStyle(color: _C.textMid)),
              )
            else
              ...albums.map((album) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(album.title, style: const TextStyle(color: _C.white)),
                subtitle: Text('${album.songCount} canciones',
                  style: TextStyle(color: _C.textMid)),
                onTap: () async {
                  await context.read<ArtistController>()
                      .assignSongToAlbum(songId: song.id, albumId: album.id);
                  if (!context.mounted) return;
                  await context.read<CatalogController>().load();
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                },
              )),
          ],
        ),
      ),
    ),
  );
}

Future<void> _showAdminAlbumAssignmentDialog(
  BuildContext context, {required Song song, required List<Album> albums}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: _C.darkCard,
      title: Text('Asignar album a ${song.title}', style: const TextStyle(color: _C.white)),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Quitar del album', style: TextStyle(color: _C.white)),
              subtitle: Text('Mantener la cancion como single',
                style: TextStyle(color: _C.textMid)),
              onTap: () async {
                await context.read<AdminController>().assignSongToAlbum(songId: song.id, albumId: null);
                if (!context.mounted) return;
                await context.read<CatalogController>().load();
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
            ),
            Divider(color: _C.border),
            if (albums.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('No hay albumes para este artista.',
                  style: TextStyle(color: _C.textMid)),
              )
            else
              ...albums.map((album) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(album.title, style: const TextStyle(color: _C.white)),
                subtitle: Text('${album.artist} • ${album.songCount} canciones',
                  style: TextStyle(color: _C.textMid)),
                onTap: () async {
                  await context.read<AdminController>()
                      .assignSongToAlbum(songId: song.id, albumId: album.id);
                  if (!context.mounted) return;
                  await context.read<CatalogController>().load();
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                },
              )),
          ],
        ),
      ),
    ),
  );
}

String _formatDate(DateTime? value) {
  if (value == null) return '-';
  return DateFormat('yyyy-MM-dd HH:mm').format(value.toLocal());
}

Future<void> _showSnack(BuildContext context, String message) async {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<void> _playSong(BuildContext context, Song song, {String source = 'catalog'}) async {
  await context.read<PlayerController>().playSong(song, source: source);
  if (!context.mounted) return;
  await context.read<HistoryController>().load();
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/controllers.dart';
import '../models/domain_models.dart';

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
                        decoration: const InputDecoration(
                          hintText: 'Buscar por titulo, artista o genero',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                        onSubmitted: (value) =>
                            context.read<CatalogController>().load(searchQuery: value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: () => context
                          .read<CatalogController>()
                          .load(searchQuery: _searchController.text),
                      icon: const Icon(Icons.tune_rounded),
                      label: const Text('Buscar'),
                    ),
                  ],
                ),
                if (catalog.loading) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                ],
                if (catalog.error != null) ...[
                  const SizedBox(height: 16),
                  _ErrorBox(message: catalog.error!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle(
            title: 'Canciones',
            subtitle: 'Todo el material disponible para streaming protegido.',
          ),
          const SizedBox(height: 12),
          if (!catalog.loading && catalog.songs.isEmpty)
            const _EmptyState(message: 'No hay canciones disponibles.')
          else
            ...catalog.songs.map(
              (song) => SongTile(
                song: song,
                isFavorite: favorites.contains(song.id),
                onPlay: () => _playSong(context, song),
                onToggleFavorite: () => context.read<FavoritesController>().toggle(song),
                onAddToPlaylist: () => _showPlaylistPicker(context, song),
              ),
            ),
          const SizedBox(height: 28),
          _SectionTitle(
            title: 'Albumes',
            subtitle: 'Explora los lanzamientos disponibles en el catalogo.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: catalog.albums
                .map(
                  (album) => _AlbumCard(
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
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(album.title),
          content: SizedBox(
            width: 460,
            child: ListView(
              shrinkWrap: true,
              children: album.songs
                  .map(
                    (song) => SongTile(
                      song: song,
                      isFavorite: context.read<FavoritesController>().contains(song.id),
                      onPlay: () => _playSong(dialogContext, song),
                      onToggleFavorite: () => context.read<FavoritesController>().toggle(song),
                      onAddToPlaylist: () => _showPlaylistPicker(dialogContext, song),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }

}

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
            const LinearProgressIndicator()
          else if (favorites.favorites.isEmpty)
            const _EmptyState(message: 'Aun no has marcado canciones como favoritas.')
          else
            ...favorites.favorites.map(
              (song) => SongTile(
                song: song,
                isFavorite: true,
                onPlay: () => _playSong(context, song, source: 'favorite'),
                onToggleFavorite: () => context.read<FavoritesController>().toggle(song),
                onAddToPlaylist: () => _showPlaylistPicker(context, song),
              ),
            ),
        ],
      ),
    );
  }

}

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
            trailing: FilledButton.icon(
              onPressed: () => _showCreatePlaylistDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nueva playlist'),
            ),
          ),
          const SizedBox(height: 20),
          if (playlists.error != null) _ErrorBox(message: playlists.error!),
          if (playlists.loading)
            const LinearProgressIndicator()
          else if (playlists.playlists.isEmpty)
            const _EmptyState(message: 'Todavia no has creado playlists.')
          else
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: playlists.playlists
                  .map(
                    (playlist) => _PlaylistCard(
                      playlist: playlist,
                      onTap: () => _showPlaylistDetail(context, playlist),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

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
            const LinearProgressIndicator()
          else if (history.entries.isEmpty)
            const _EmptyState(message: 'No hay reproducciones registradas todavia.')
          else
            ...history.entries.map(
              (entry) => _Panel(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    '${entry.artist} • ${entry.genre} • ${entry.playedSeconds}s • ${entry.completionRate.toStringAsFixed(1)}%',
                  ),
                  trailing: Text(_formatDate(entry.startedAt)),
                ),
              ),
            ),
        ],
      ),
    );
  }

}

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
            trailing: FilledButton.tonalIcon(
              onPressed: () => context.read<RecommendationsController>().refresh(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Recalcular'),
            ),
          ),
          const SizedBox(height: 20),
          if (recommendations.error != null) _ErrorBox(message: recommendations.error!),
          if (recommendations.loading)
            const LinearProgressIndicator()
          else if (recommendations.items.isEmpty)
            const _EmptyState(message: 'No hay recomendaciones disponibles.')
          else
            ...recommendations.items.map(
              (item) {
                final song = item.toSong();
                return SongTile(
                  song: song,
                  isFavorite: favorites.contains(item.id),
                  onPlay: () => _playSong(context, song, source: 'recommendation'),
                  onToggleFavorite: () => context.read<FavoritesController>().toggle(song),
                  onAddToPlaylist: () => _showPlaylistPicker(context, song),
                  extra: item.reason == null
                      ? null
                      : Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            item.reason!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                );
              },
            ),
        ],
      ),
    );
  }

}

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
    _title.dispose();
    _genre.dispose();
    _duration.dispose();
    _collaborators.dispose();
    _albumTitle.dispose();
    _albumGenre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final artist = context.watch<ArtistController>();
    final auth = context.watch<AuthController>();
    final catalog = context.watch<CatalogController>();
    final ownAlbums = catalog.albums
        .where((album) => album.artist == auth.user?.artist?.name)
        .toList();

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
                const _SectionTitle(
                  title: 'Nueva cancion',
                  subtitle: 'Puedes subirla sola y asignarla al album despues.',
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _FieldBox(width: 240, child: TextField(controller: _title, decoration: const InputDecoration(labelText: 'Titulo'))),
                    _FieldBox(width: 180, child: TextField(controller: _genre, decoration: const InputDecoration(labelText: 'Genero'))),
                    _FieldBox(width: 180, child: TextField(controller: _duration, decoration: const InputDecoration(labelText: 'Duracion en segundos'))),
                    _FieldBox(width: 260, child: TextField(controller: _collaborators, decoration: const InputDecoration(labelText: 'Colaboradores separados por coma'))),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: artist.pickFile,
                      icon: const Icon(Icons.audio_file_rounded),
                      label: Text(artist.selectedFile?.name ?? 'Seleccionar audio'),
                    ),
                    FilledButton.icon(
                      onPressed: artist.submitting
                          ? null
                          : () async {
                              await context.read<ArtistController>().uploadSong(
                                    title: _title.text.trim(),
                                    genreName: _genre.text.trim(),
                                    durationSeconds: _duration.text.trim(),
                                    collaboratorNames: _collaborators.text.trim(),
                                  );
                              if (!context.mounted) return;
                              await context.read<CatalogController>().load();
                            },
                      icon: const Icon(Icons.cloud_upload_rounded),
                      label: const Text('Subir cancion'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(
                  title: 'Nuevo album',
                  subtitle: 'Puedes crearlo vacio o inicializarlo con canciones ya subidas.',
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _FieldBox(width: 260, child: TextField(controller: _albumTitle, decoration: const InputDecoration(labelText: 'Titulo del album'))),
                    _FieldBox(width: 200, child: TextField(controller: _albumGenre, decoration: const InputDecoration(labelText: 'Genero opcional'))),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: artist.songs
                      .map(
                        (song) => FilterChip(
                          label: Text(song.title),
                          selected: _selectedSongs.contains(song.id),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSongs.add(song.id);
                              } else {
                                _selectedSongs.remove(song.id);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                FilledButton.tonalIcon(
                  onPressed: artist.submitting
                      ? null
                      : () async {
                          final artistController = context.read<ArtistController>();
                          final catalogController = context.read<CatalogController>();
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await artistController.createAlbum(
                                  title: _albumTitle.text.trim(),
                                  genreName: _albumGenre.text.trim(),
                                  songIds: _selectedSongs.toList(),
                                );
                            if (!context.mounted) return;
                            _selectedSongs.clear();
                            await catalogController.load();
                            messenger.showSnackBar(const SnackBar(content: Text('Album creado correctamente')));
                            setState(() {});
                          } catch (_) {}
                        },
                  icon: const Icon(Icons.album_rounded),
                  label: const Text('Crear album'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const _SectionTitle(
            title: 'Mis canciones',
            subtitle: 'Publica, elimina o asigna cada cancion a un album existente.',
          ),
          const SizedBox(height: 12),
          ...artist.songs.map(
            (song) => _EditorialSongCard(
              song: song,
              subtitle: '${song.genre} • ${song.album ?? 'Sin album'}',
              published: song.isPublished ?? false,
              onTogglePublication: (value) => context.read<ArtistController>().setPublication(song.id, value),
              onDelete: () async {
                await context.read<ArtistController>().deleteSong(song.id);
                if (!context.mounted) return;
                await context.read<CatalogController>().load();
              },
              onAssignAlbum: () => _showArtistAlbumAssignmentDialog(
                context,
                song: song,
                albums: ownAlbums,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
    _songTitle.dispose();
    _artistName.dispose();
    _genreName.dispose();
    _duration.dispose();
    _albumTitle.dispose();
    _albumArtistName.dispose();
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
                const _SectionTitle(
                  title: 'Usuarios',
                  subtitle: 'Actualiza el estado sin salir del panel principal.',
                ),
                const SizedBox(height: 10),
                ...admin.users.map(
                  (user) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${user.email} • ${user.role}'),
                    trailing: DropdownButton<String>(
                      value: user.status,
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text('active')),
                        DropdownMenuItem(value: 'inactive', child: Text('inactive')),
                        DropdownMenuItem(value: 'blocked', child: Text('blocked')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          context.read<AdminController>().updateUserStatus(user.id, value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(
                  title: 'Subir cancion al catalogo',
                  subtitle: 'Una cancion puede existir sola y luego sumarse a un album.',
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _FieldBox(width: 220, child: TextField(controller: _songTitle, decoration: const InputDecoration(labelText: 'Titulo'))),
                    _FieldBox(width: 220, child: TextField(controller: _artistName, decoration: const InputDecoration(labelText: 'Artista'))),
                    _FieldBox(width: 180, child: TextField(controller: _genreName, decoration: const InputDecoration(labelText: 'Genero'))),
                    _FieldBox(width: 160, child: TextField(controller: _duration, decoration: const InputDecoration(labelText: 'Duracion'))),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: admin.pickFile,
                      icon: const Icon(Icons.audio_file_rounded),
                      label: Text(admin.selectedFile?.name ?? 'Seleccionar audio'),
                    ),
                    FilledButton.icon(
                      onPressed: admin.submitting
                          ? null
                          : () async {
                              final adminController = context.read<AdminController>();
                              final catalogController = context.read<CatalogController>();
                              final messenger = ScaffoldMessenger.of(context);
                              try {
                                await adminController.uploadSong(
                                      title: _songTitle.text.trim(),
                                      artistName: _artistName.text.trim(),
                                      genreName: _genreName.text.trim(),
                                      durationSeconds: _duration.text.trim(),
                                    );
                                if (!context.mounted) return;
                                await catalogController.load();
                                messenger.showSnackBar(const SnackBar(content: Text('Cancion subida al catalogo')));
                              } catch (_) {}
                            },
                      icon: const Icon(Icons.library_add_rounded),
                      label: const Text('Subir cancion'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(
                  title: 'Crear album',
                  subtitle: 'Puedes crearlo vacio si defines el artista, o con canciones seleccionadas.',
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _FieldBox(width: 240, child: TextField(controller: _albumTitle, decoration: const InputDecoration(labelText: 'Titulo del album'))),
                    _FieldBox(width: 220, child: TextField(controller: _albumArtistName, decoration: const InputDecoration(labelText: 'Artista para album vacio'))),
                    _FieldBox(width: 180, child: TextField(controller: _albumGenre, decoration: const InputDecoration(labelText: 'Genero opcional'))),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: catalog.songs
                      .map(
                        (song) => FilterChip(
                          label: Text('${song.title} • ${song.artist}'),
                          selected: _selectedSongIds.contains(song.id),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSongIds.add(song.id);
                              } else {
                                _selectedSongIds.remove(song.id);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                FilledButton.tonalIcon(
                  onPressed: admin.submitting
                      ? null
                      : () async {
                          final adminController = context.read<AdminController>();
                          final catalogController = context.read<CatalogController>();
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await adminController.createAlbum(
                                  title: _albumTitle.text.trim(),
                                  artistName: _albumArtistName.text.trim(),
                                  genreName: _albumGenre.text.trim(),
                                  songIds: _selectedSongIds.toList(),
                                );
                            if (!context.mounted) return;
                            _selectedSongIds.clear();
                            await catalogController.load();
                            messenger.showSnackBar(const SnackBar(content: Text('Album creado correctamente')));
                            setState(() {});
                          } catch (_) {}
                        },
                  icon: const Icon(Icons.album_outlined),
                  label: const Text('Crear album'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const _SectionTitle(
            title: 'Catalogo administrable',
            subtitle: 'Asigna canciones a albumes, quitalas de un album o desactivalas.',
          ),
          const SizedBox(height: 12),
          ...catalog.songs.map(
            (song) => _EditorialSongCard(
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
                albums: catalog.albums.where((album) => album.artist == song.artist).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
    final colors = Theme.of(context).colorScheme;
    return _Panel(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: colors.primaryContainer,
            ),
            child: Icon(Icons.music_note_rounded, color: colors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(song.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('${song.artist} • ${song.album ?? 'Sin album'} • ${song.genre}'),
                if (extra != null) extra!,
              ],
            ),
          ),
          Wrap(
            spacing: 4,
            children: [
              IconButton.filledTonal(
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow_rounded),
              ),
              IconButton(
                onPressed: onToggleFavorite,
                icon: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
              ),
              IconButton(
                onPressed: onAddToPlaylist,
                icon: const Icon(Icons.playlist_add_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
                    Text(song.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onAssignAlbum,
                icon: const Icon(Icons.album_rounded),
                label: const Text('Asignar album'),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => onDelete(),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          if (showPublicationToggle) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              value: published,
              onChanged: onTogglePublication,
              title: Text(published ? 'Publicada' : 'Oculta'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({
    required this.album,
    required this.onTap,
  });

  final Album album;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.secondaryContainer,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: colors.primary.withValues(alpha: 0.12),
              ),
              child: Icon(Icons.album_rounded, color: colors.primary),
            ),
            const SizedBox(height: 18),
            Text(album.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            Text(album.artist),
            Text(album.genre ?? 'Sin genero'),
            const SizedBox(height: 10),
            Text('${album.songCount} canciones', style: TextStyle(color: colors.primary)),
          ],
        ),
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({
    required this.playlist,
    required this.onTap,
  });

  final PlaylistSummary playlist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: _Panel(
        width: 260,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(playlist.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            Text(playlist.description?.isNotEmpty == true ? playlist.description! : 'Sin descripcion'),
            const SizedBox(height: 12),
            Text('${playlist.songCount} canciones • ${playlist.isPublic ? 'Publica' : 'Privada'}'),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.22),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.94),
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(subtitle),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.width,
  });

  final Widget child;
  final EdgeInsets padding;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: width,
      padding: padding,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FieldBox extends StatelessWidget {
  const _FieldBox({
    required this.width,
    required this.child,
  });

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, child: child);
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(message, style: TextStyle(color: colors.onErrorContainer)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        children: [
          Icon(Icons.inbox_rounded, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _SectionScroll extends StatelessWidget {
  const _SectionScroll({
    required this.child,
    required this.onRefresh,
  });

  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [child],
      ),
    );
  }
}

Future<void> _showPlaylistPicker(BuildContext context, Song song) async {
  final playlists = context.read<PlaylistsController>();
  if (playlists.playlists.isEmpty) {
    await _showSnack(context, 'Primero crea una playlist');
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Agregar a playlist'),
        content: SizedBox(
          width: 340,
          child: ListView(
            shrinkWrap: true,
            children: playlists.playlists
                .map(
                  (playlist) => ListTile(
                    title: Text(playlist.name),
                    subtitle: Text('${playlist.songCount} canciones'),
                    onTap: () async {
                      try {
                        await context.read<PlaylistsController>().addSong(
                              playlistId: playlist.id,
                              songId: song.id,
                            );
                        if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                        if (context.mounted) {
                          await _showSnack(context, 'Cancion agregada a ${playlist.name}');
                        }
                      } catch (_) {}
                    },
                  ),
                )
                .toList(),
          ),
        ),
      );
    },
  );
}

Future<void> _showCreatePlaylistDialog(BuildContext context) async {
  final name = TextEditingController();
  final description = TextEditingController();
  bool isPublic = false;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Nueva playlist'),
            content: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre')),
                  const SizedBox(height: 12),
                  TextField(controller: description, decoration: const InputDecoration(labelText: 'Descripcion')),
                  SwitchListTile(
                    value: isPublic,
                    onChanged: (value) => setState(() => isPublic = value),
                    title: const Text('Publica'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
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
                child: const Text('Crear'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _showPlaylistDetail(BuildContext context, PlaylistSummary playlist) async {
  final playlistsController = context.read<PlaylistsController>();
  final detail = await playlistsController.open(playlist.id);
  if (detail == null || !context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(playlist.name),
        content: SizedBox(
          width: 460,
          child: ListView(
            shrinkWrap: true,
            children: detail.songs
                .map(
                  (song) => ListTile(
                    title: Text(song.title),
                    subtitle: Text('${song.artist} • ${song.genre}'),
                    trailing: IconButton(
                      onPressed: () => context.read<PlaylistsController>().removeSong(
                            playlistId: playlist.id,
                            songId: song.id,
                          ),
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      );
    },
  );
}

Future<void> _showArtistAlbumAssignmentDialog(
  BuildContext context, {
  required Song song,
  required List<Album> albums,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text('Asignar album a ${song.title}'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Quitar del album'),
                subtitle: const Text('Dejar la cancion como lanzamiento suelto'),
                onTap: () async {
                  await context.read<ArtistController>().assignSongToAlbum(songId: song.id, albumId: null);
                  if (!context.mounted) return;
                  await context.read<CatalogController>().load();
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                },
              ),
              const Divider(),
              if (albums.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Todavia no tienes albumes creados.'),
                )
              else
                ...albums.map(
                  (album) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(album.title),
                    subtitle: Text('${album.songCount} canciones'),
                    onTap: () async {
                      await context
                          .read<ArtistController>()
                          .assignSongToAlbum(songId: song.id, albumId: album.id);
                      if (!context.mounted) return;
                      await context.read<CatalogController>().load();
                      if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _showAdminAlbumAssignmentDialog(
  BuildContext context, {
  required Song song,
  required List<Album> albums,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text('Asignar album a ${song.title}'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Quitar del album'),
                subtitle: const Text('Mantener la cancion como single'),
                onTap: () async {
                  await context.read<AdminController>().assignSongToAlbum(songId: song.id, albumId: null);
                  if (!context.mounted) return;
                  await context.read<CatalogController>().load();
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                },
              ),
              const Divider(),
              if (albums.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('No hay albumes para este artista.'),
                )
              else
                ...albums.map(
                  (album) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(album.title),
                    subtitle: Text('${album.artist} • ${album.songCount} canciones'),
                    onTap: () async {
                      await context
                          .read<AdminController>()
                          .assignSongToAlbum(songId: song.id, albumId: album.id);
                      if (!context.mounted) return;
                      await context.read<CatalogController>().load();
                      if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

String _formatDate(DateTime? value) {
  if (value == null) return '-';
  return DateFormat('yyyy-MM-dd HH:mm').format(value.toLocal());
}

Future<void> _showSnack(BuildContext context, String message) async {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<void> _playSong(
  BuildContext context,
  Song song, {
  String source = 'catalog',
}) async {
  await context.read<PlayerController>().playSong(song, source: source);
  if (!context.mounted) return;
  await context.read<HistoryController>().load();
}

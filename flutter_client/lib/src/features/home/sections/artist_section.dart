import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/controllers.dart';
import '../../../models/domain_models.dart';
import '../../../shared/widgets/app_dark_text_field.dart';
import '../../../shared/widgets/app_error_box.dart';
import '../../../shared/widgets/app_gradient_button.dart';
import '../../../shared/widgets/app_panel.dart';
import '../../../theme/app_colors.dart';
import '../widgets/editorial_song_card.dart';
import '../widgets/home_hero_banner.dart';
import '../widgets/home_metric_chip.dart';
import '../widgets/home_section_scroll.dart';
import '../widgets/home_section_title.dart';

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
        .where((a) => a.artist == auth.user?.artist?.name)
        .toList();

    return HomeSectionScroll(
      onRefresh: () async {
        await context.read<ArtistController>().load();
        if (!context.mounted) return;
        await context.read<CatalogController>().load();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeroBanner(
            title: 'Estudio del artista',
            subtitle:
                'Sube canciones sueltas, crea albumes vacios o arma un lanzamiento con el material actual.',
            trailing: HomeMetricChip(
              label: 'Mis canciones',
              value: '${artist.songs.length}',
            ),
          ),
          const SizedBox(height: 20),
          if (artist.error != null) AppErrorBox(message: artist.error!),
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeSectionTitle(
                  title: 'Nueva cancion',
                  subtitle: 'Puedes subirla sola y asignarla al album despues.',
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _FieldBox(
                      width: 240,
                      child: AppDarkTextField(
                        controller: _title,
                        label: 'Titulo',
                      ),
                    ),
                    _FieldBox(
                      width: 180,
                      child: AppDarkTextField(
                        controller: _genre,
                        label: 'Genero',
                      ),
                    ),
                    _FieldBox(
                      width: 180,
                      child: AppDarkTextField(
                        controller: _duration,
                        label: 'Duracion en segundos',
                      ),
                    ),
                    _FieldBox(
                      width: 260,
                      child: AppDarkTextField(
                        controller: _collaborators,
                        label: 'Colaboradores separados por coma',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: artist.pickFile,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textMid,
                        side: const BorderSide(color: AppColors.border),
                      ),
                      icon: const Icon(Icons.audio_file_rounded),
                      label: Text(
                        artist.selectedFile?.name ?? 'Seleccionar audio',
                      ),
                    ),
                    AppGradientButton(
                      label: 'Subir cancion',
                      icon: Icons.cloud_upload_rounded,
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
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeSectionTitle(
                  title: 'Nuevo album',
                  subtitle:
                      'Puedes crearlo vacio o inicializarlo con canciones ya subidas.',
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _FieldBox(
                      width: 260,
                      child: AppDarkTextField(
                        controller: _albumTitle,
                        label: 'Titulo del album',
                      ),
                    ),
                    _FieldBox(
                      width: 200,
                      child: AppDarkTextField(
                        controller: _albumGenre,
                        label: 'Genero opcional',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: artist.songs
                      .map(
                        (song) => FilterChip(
                          label: Text(
                            song.title,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                            ),
                          ),
                          selected: _selectedSongs.contains(song.id),
                          backgroundColor: AppColors.surface,
                          selectedColor: AppColors.purple.withValues(
                            alpha: 0.35,
                          ),
                          side: BorderSide(
                            color: _selectedSongs.contains(song.id)
                                ? AppColors.purple
                                : AppColors.border,
                          ),
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
                AppGradientButton(
                  label: 'Crear album',
                  icon: Icons.album_rounded,
                  onPressed: artist.submitting
                      ? null
                      : () async {
                          try {
                            await context.read<ArtistController>().createAlbum(
                              title: _albumTitle.text.trim(),
                              genreName: _albumGenre.text.trim(),
                              songIds: _selectedSongs.toList(),
                            );
                            if (!context.mounted) return;
                            _selectedSongs.clear();
                            await context.read<CatalogController>().load();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Album creado correctamente'),
                              ),
                            );
                            setState(() {});
                          } catch (_) {}
                        },
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const HomeSectionTitle(
            title: 'Mis canciones',
            subtitle:
                'Publica, elimina o asigna cada cancion a un album existente.',
          ),
          const SizedBox(height: 12),
          ...artist.songs.map(
            (song) => EditorialSongCard(
              song: song,
              subtitle: '${song.genre} • ${song.album ?? 'Sin album'}',
              published: song.isPublished ?? false,
              onTogglePublication: (value) => context
                  .read<ArtistController>()
                  .setPublication(song.id, value),
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

// ─── AdminSection ─────────────────────────────────────────────────────────────

Future<void> _showArtistAlbumAssignmentDialog(
  BuildContext context, {
  required Song song,
  required List<Album> albums,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.darkCard,
      title: Text(
        'Asignar album a ${song.title}',
        style: const TextStyle(color: AppColors.white),
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Quitar del album',
                style: TextStyle(color: AppColors.white),
              ),
              subtitle: Text(
                'Dejar la cancion como lanzamiento suelto',
                style: TextStyle(color: AppColors.textMid),
              ),
              onTap: () async {
                await context.read<ArtistController>().assignSongToAlbum(
                  songId: song.id,
                  albumId: null,
                );
                if (!context.mounted) return;
                await context.read<CatalogController>().load();
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
              },
            ),
            Divider(color: AppColors.border),
            if (albums.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Todavia no tienes albumes creados.',
                  style: TextStyle(color: AppColors.textMid),
                ),
              )
            else
              ...albums.map(
                (album) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    album.title,
                    style: const TextStyle(color: AppColors.white),
                  ),
                  subtitle: Text(
                    '${album.songCount} canciones',
                    style: TextStyle(color: AppColors.textMid),
                  ),
                  onTap: () async {
                    await context.read<ArtistController>().assignSongToAlbum(
                      songId: song.id,
                      albumId: album.id,
                    );
                    if (!context.mounted) return;
                    await context.read<CatalogController>().load();
                    if (!dialogContext.mounted) return;
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _FieldBox extends StatelessWidget {
  const _FieldBox({required this.width, required this.child});
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(width: width, child: child);
}

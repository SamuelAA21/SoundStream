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

    return HomeSectionScroll(
      onRefresh: () async {
        await context.read<AdminController>().load();
        if (!context.mounted) return;
        await context.read<CatalogController>().load();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeroBanner(
            title: 'Consola administrativa',
            subtitle:
                'Gestiona usuarios y cataloga canciones sueltas o albumes con mas flexibilidad.',
            trailing: HomeMetricChip(
              label: 'Usuarios',
              value: '${admin.users.length}',
            ),
          ),
          const SizedBox(height: 20),
          if (admin.error != null) AppErrorBox(message: admin.error!),
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeSectionTitle(
                  title: 'Usuarios',
                  subtitle:
                      'Actualiza el estado sin salir del panel principal.',
                ),
                const SizedBox(height: 10),
                ...admin.users.map(
                  (user) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.dark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.purple.withValues(alpha: 0.2),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppColors.purple,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${user.email} • ${user.role}',
                                style: TextStyle(
                                  color: AppColors.textMid,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownButton<String>(
                          value: user.status,
                          dropdownColor: AppColors.darkCard,
                          style: const TextStyle(color: AppColors.white),
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                              value: 'active',
                              child: Text('active'),
                            ),
                            DropdownMenuItem(
                              value: 'inactive',
                              child: Text('inactive'),
                            ),
                            DropdownMenuItem(
                              value: 'blocked',
                              child: Text('blocked'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              context.read<AdminController>().updateUserStatus(
                                user.id,
                                value,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
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
                  title: 'Subir cancion al catalogo',
                  subtitle:
                      'Una cancion puede existir sola y luego sumarse a un album.',
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _FieldBox(
                      width: 220,
                      child: AppDarkTextField(
                        controller: _songTitle,
                        label: 'Titulo',
                      ),
                    ),
                    _FieldBox(
                      width: 220,
                      child: AppDarkTextField(
                        controller: _artistName,
                        label: 'Artista',
                      ),
                    ),
                    _FieldBox(
                      width: 180,
                      child: AppDarkTextField(
                        controller: _genreName,
                        label: 'Genero',
                      ),
                    ),
                    _FieldBox(
                      width: 160,
                      child: AppDarkTextField(
                        controller: _duration,
                        label: 'Duracion',
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
                      onPressed: admin.pickFile,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textMid,
                        side: const BorderSide(color: AppColors.border),
                      ),
                      icon: const Icon(Icons.audio_file_rounded),
                      label: Text(
                        admin.selectedFile?.name ?? 'Seleccionar audio',
                      ),
                    ),
                    AppGradientButton(
                      label: 'Subir cancion',
                      icon: Icons.library_add_rounded,
                      onPressed: admin.submitting
                          ? null
                          : () async {
                              try {
                                await context
                                    .read<AdminController>()
                                    .uploadSong(
                                      title: _songTitle.text.trim(),
                                      artistName: _artistName.text.trim(),
                                      genreName: _genreName.text.trim(),
                                      durationSeconds: _duration.text.trim(),
                                    );
                                if (!context.mounted) return;
                                await context.read<CatalogController>().load();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Cancion subida al catalogo'),
                                  ),
                                );
                              } catch (_) {}
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
                  title: 'Crear album',
                  subtitle:
                      'Puedes crearlo vacio si defines el artista, o con canciones seleccionadas.',
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _FieldBox(
                      width: 240,
                      child: AppDarkTextField(
                        controller: _albumTitle,
                        label: 'Titulo del album',
                      ),
                    ),
                    _FieldBox(
                      width: 220,
                      child: AppDarkTextField(
                        controller: _albumArtistName,
                        label: 'Artista para album vacio',
                      ),
                    ),
                    _FieldBox(
                      width: 180,
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
                  children: catalog.songs
                      .map(
                        (song) => FilterChip(
                          label: Text(
                            '${song.title} • ${song.artist}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                            ),
                          ),
                          selected: _selectedSongIds.contains(song.id),
                          backgroundColor: AppColors.surface,
                          selectedColor: AppColors.purple.withValues(
                            alpha: 0.35,
                          ),
                          side: BorderSide(
                            color: _selectedSongIds.contains(song.id)
                                ? AppColors.purple
                                : AppColors.border,
                          ),
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
                AppGradientButton(
                  label: 'Crear album',
                  icon: Icons.album_outlined,
                  onPressed: admin.submitting
                      ? null
                      : () async {
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
            title: 'Catalogo administrable',
            subtitle:
                'Asigna canciones a albumes, quitalas de un album o desactivalas.',
          ),
          const SizedBox(height: 12),
          ...catalog.songs.map(
            (song) => EditorialSongCard(
              song: song,
              subtitle:
                  '${song.artist} • ${song.genre} • ${song.album ?? 'Sin album'}',
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
                albums: catalog.albums
                    .where((a) => a.artist == song.artist)
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SongTile ─────────────────────────────────────────────────────────────────

Future<void> _showAdminAlbumAssignmentDialog(
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
                'Mantener la cancion como single',
                style: TextStyle(color: AppColors.textMid),
              ),
              onTap: () async {
                await context.read<AdminController>().assignSongToAlbum(
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
                  'No hay albumes para este artista.',
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
                    '${album.artist} • ${album.songCount} canciones',
                    style: TextStyle(color: AppColors.textMid),
                  ),
                  onTap: () async {
                    await context.read<AdminController>().assignSongToAlbum(
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

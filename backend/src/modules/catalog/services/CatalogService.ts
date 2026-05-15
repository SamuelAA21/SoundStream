import { AppError } from "../../../utils/AppError.js";
import { getPagination } from "../../../utils/pagination.js";
import { CatalogRepository } from "../repositories/CatalogRepository.js";

const repository = new CatalogRepository();

export class CatalogService {
  async listSongs(query: { q?: string; page?: string; limit?: string }) {
    const pagination = getPagination(query);
    const songs = await repository.listSongs({
      query: query.q,
      skip: pagination.skip,
      limit: pagination.limit
    });

    return {
      page: pagination.page,
      limit: pagination.limit,
      data: songs.map((song) => this.toSongDto(song))
    };
  }

  async getSong(songId: string) {
    const song = await repository.findSong(BigInt(songId));
    if (!song) {
      throw new AppError(404, "song_not_found", "Song was not found");
    }
    return this.toSongDto(song);
  }

  async listAlbums() {
    const albums = await repository.listAlbums();
    return albums.map((album) => ({
      id: album.id.toString(),
      title: album.title,
      artist: album.artist.name,
      genre: album.genre?.name ?? null,
      songCount: album._count.songs
    }));
  }

  async getAlbum(albumId: string) {
    const album = await repository.findAlbum(BigInt(albumId));
    if (!album) {
      throw new AppError(404, "album_not_found", "Album was not found");
    }

    return {
      id: album.id.toString(),
      title: album.title,
      artist: album.artist.name,
      genre: album.genre?.name ?? null,
      songs: album.songs.map((song) => this.toSongDto({ ...song, album, artist: song.artist, genre: song.genre }))
    };
  }

  private toSongDto(song: any) {
    return {
      id: song.id.toString(),
      title: song.title,
      durationSeconds: song.durationSeconds,
      artist: song.artist.name,
      album: song.album?.title ?? null,
      albumId: song.album?.id?.toString() ?? null,
      genre: song.genre.name,
      collaborators: song.collaborators?.map((item: any) => ({
        id: item.artist.id.toString(),
        name: item.artist.name,
        role: item.role
      })) ?? [],
      streamUrl: `/api/stream/songs/${song.id.toString()}`
    };
  }
}

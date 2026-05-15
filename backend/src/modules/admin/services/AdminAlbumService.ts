import { AppError } from "../../../utils/AppError.js";
import { AdminAlbumRepository } from "../repositories/AdminAlbumRepository.js";

const repository = new AdminAlbumRepository();

export class AdminAlbumService {
  async createAlbum(input: { title: string; genreName?: string; artistName?: string; songIds: string[] }) {
    const title = input.title.trim();
    if (title.length < 2) {
      throw new AppError(422, "invalid_album_title", "Album title must have at least 2 characters");
    }

    const uniqueSongIds = [...new Set(input.songIds)].map((id) => BigInt(id));
    const songs = uniqueSongIds.length === 0 ? [] : await repository.findSongs(uniqueSongIds);
    if (songs.length !== uniqueSongIds.length) {
      throw new AppError(422, "invalid_album_songs", "All selected songs must exist and be available");
    }

    const [firstSong] = songs;
    const differentArtist = firstSong == null
      ? false
      : songs.some((song) => song.artistId !== firstSong.artistId);
    if (differentArtist) {
      throw new AppError(422, "album_artist_mismatch", "All album songs must belong to the same artist");
    }

    const artistName = input.artistName?.trim();
    const genreName = input.genreName?.trim();
    const genre = genreName
      ? await repository.findOrCreateGenre(genreName)
      : firstSong?.genre ?? await repository.findOrCreateGenre("Uncategorized");

    const artistId = firstSong?.artistId ?? (artistName ? (await repository.findOrCreateArtist(artistName)).id : null);
    if (!artistId) {
      throw new AppError(422, "album_artist_required", "Select at least one song or provide an artistName");
    }

    const album = await repository.createAlbumFromSongs({
      title,
      artistId,
      genreId: genre.id,
      songIds: uniqueSongIds
    });

    return {
      id: album.id.toString(),
      title: album.title,
      artist: album.artist.name,
      genre: album.genre?.name ?? null,
      songs: album.songs.map((song) => ({
        id: song.id.toString(),
        title: song.title,
        artist: song.artist.name,
        genre: song.genre.name,
        durationSeconds: song.durationSeconds
      }))
    };
  }

  async assignSongToAlbum(input: { songId: string; albumId?: string | null }) {
    const song = await repository.findSong(BigInt(input.songId));
    if (!song) {
      throw new AppError(404, "song_not_found", "Song was not found");
    }

    if (!input.albumId) {
      return this.toSongDto(await repository.updateSongAlbum({
        songId: song.id,
        albumId: null
      }));
    }

    const album = await repository.findAlbum(BigInt(input.albumId));
    if (!album) {
      throw new AppError(404, "album_not_found", "Album was not found");
    }

    if (album.artistId !== song.artistId) {
      throw new AppError(422, "album_artist_mismatch", "Song and album must belong to the same artist");
    }

    return this.toSongDto(await repository.updateSongAlbum({
      songId: song.id,
      albumId: album.id,
      artistId: album.artistId,
      genreId: album.genreId ?? song.genreId
    }));
  }

  private toSongDto(song: { id: bigint; title: string; artist: { name: string }; album: { title: string } | null; genre: { name: string }; durationSeconds: number }) {
    return {
      id: song.id.toString(),
      title: song.title,
      artist: song.artist.name,
      album: song.album?.title ?? null,
      genre: song.genre.name,
      durationSeconds: song.durationSeconds
    };
  }
}

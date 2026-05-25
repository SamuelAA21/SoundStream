import { PrismaClientKnownRequestError } from "@prisma/client/runtime/library";
import { AppError } from "../../../utils/AppError.js";
import { PlaylistRepository } from "../repositories/PlaylistRepository.js";

const repository = new PlaylistRepository();

export class PlaylistService {
  async create(userId: string, input: { name: string; description?: string; isPublic?: boolean }) {
    const name = input.name.trim();
    if (name.length < 2) {
      throw new AppError(422, "invalid_playlist_name", "Playlist name must have at least 2 characters");
    }

    try {
      const playlist = await repository.create({
        userId: BigInt(userId),
        name,
        description: input.description?.trim() || undefined,
        isPublic: input.isPublic ?? false
      });
      return this.toPlaylistDto(playlist);
    } catch (error) {
      if (error instanceof PrismaClientKnownRequestError && error.code === "P2002") {
        throw new AppError(409, "playlist_already_exists", "You already have a playlist with this name");
      }
      throw error;
    }
  }

  async list(userId: string) {
    const playlists = await repository.listByUser(BigInt(userId));
    return playlists.map((playlist) => this.toPlaylistDto(playlist));
  }

  async detail(userId: string, playlistId: string) {
    const playlist = await repository.findOwned({
      userId: BigInt(userId),
      playlistId: BigInt(playlistId)
    });
    if (!playlist) {
      throw new AppError(404, "playlist_not_found", "Playlist was not found");
    }

    return {
      ...this.toPlaylistDto(playlist),
      songs: playlist.songs.map(({ song, position, addedAt }) => ({
        id: song.id.toString(),
        title: song.title,
        artist: song.artist.name,
        album: song.album?.title ?? null,
        genre: song.genre.name,
        durationSeconds: song.durationSeconds,
        position,
        addedAt
      }))
    };
  }

  async addSong(userId: string, playlistId: string, songId: string) {
    const playlist = await repository.findOwned({
      userId: BigInt(userId),
      playlistId: BigInt(playlistId)
    });
    if (!playlist) {
      throw new AppError(404, "playlist_not_found", "Playlist was not found");
    }

    const song = await repository.findSong(BigInt(songId));
    if (!song) {
      throw new AppError(404, "song_not_found", "Song was not found");
    }

    try {
      await repository.addSong({
        playlistId: BigInt(playlistId),
        songId: BigInt(songId),
        position: await repository.nextPosition(BigInt(playlistId))
      });
      return this.detail(userId, playlistId);
    } catch (error) {
      if (error instanceof PrismaClientKnownRequestError && error.code === "P2002") {
        throw new AppError(409, "song_already_in_playlist", "Song is already in this playlist");
      }
      throw error;
    }
  }

  async removeSong(userId: string, playlistId: string, songId: string) {
    const playlist = await repository.findOwned({
      userId: BigInt(userId),
      playlistId: BigInt(playlistId)
    });
    if (!playlist) {
      throw new AppError(404, "playlist_not_found", "Playlist was not found");
    }

    await repository.removeSong({
      playlistId: BigInt(playlistId),
      songId: BigInt(songId)
    });

    return this.detail(userId, playlistId);
  }

  private toPlaylistDto(playlist: { id: bigint; name: string; description: string | null; isPublic: boolean; songs: unknown[] }) {
    return {
      id: playlist.id.toString(),
      name: playlist.name,
      description: playlist.description,
      isPublic: playlist.isPublic,
      songCount: playlist.songs.length
    };
  }
}

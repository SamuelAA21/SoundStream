import { PrismaClientKnownRequestError } from "@prisma/client/runtime/library";
import { AppError } from "../../../utils/AppError.js";
import { eventBus } from "../../../events/DomainEventBus.js";
import { FavoriteRepository } from "../repositories/FavoriteRepository.js";

const repository = new FavoriteRepository();

/**
 * FavoriteService
 *
 * Al agregar/quitar un favorito emite eventos de dominio (Observer).
 * RecommendationService escucha esos eventos y actualiza las
 * recomendaciones sin necesidad de una dependencia directa.
 */
export class FavoriteService {
  async add(userId: string, songId: string) {
    const song = await repository.findSong(BigInt(songId));
    if (!song) {
      throw new AppError(404, "song_not_found", "Song was not found");
    }

    try {
      await repository.add(BigInt(userId), BigInt(songId));

      // Patrón Observer: notifica al bus, no llama a RecommendationService
      await eventBus.emit("favorite.added", { userId, songId });

      return { ok: true };
    } catch (error) {
      if (
        error instanceof PrismaClientKnownRequestError &&
        error.code === "P2002"
      ) {
        throw new AppError(
          409,
          "favorite_already_exists",
          "Song is already marked as favorite"
        );
      }
      throw error;
    }
  }

  async remove(userId: string, songId: string) {
    await repository.remove(BigInt(userId), BigInt(songId));
    await eventBus.emit("favorite.removed", { userId, songId });
    return { ok: true };
  }

  async list(userId: string) {
    const rows = await repository.list(BigInt(userId));
    return rows.map(({ song, createdAt }) => this.toSongDto(song, createdAt));
  }

  private toSongDto(song: any, favoritedAt: Date) {
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
      favoritedAt
    };
  }
}

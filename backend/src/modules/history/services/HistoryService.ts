import { HistoryRepository } from "../repositories/HistoryRepository.js";
import { eventBus } from "../../../events/DomainEventBus.js";

const repository = new HistoryRepository();

/**
 * HistoryService
 *
 * Emite eventos de dominio al registrar reproducciones (Observer),
 * permitiendo que RecommendationService reaccione sin acoplamiento directo.
 */
export class HistoryService {
  async registerPlay(input: {
    userId: string;
    songId: string;
    playedSeconds: number;
    completionRate: number;
    deviceType: "web" | "android";
  }) {
    await repository.registerPlay({
      userId: BigInt(input.userId),
      songId: BigInt(input.songId),
      playedSeconds: input.playedSeconds,
      completionRate: input.completionRate,
      deviceType: input.deviceType,
    });
    await repository.registerInteraction({
      userId: BigInt(input.userId),
      songId: BigInt(input.songId),
      interactionType: "play",
      metadata: {
        playedSeconds: input.playedSeconds,
        completionRate: input.completionRate,
      },
    });

    // Patrón Observer: emite el evento al bus central
    await eventBus.emit("song.played", {
      userId: input.userId,
      songId: input.songId,
      completionRate: input.completionRate,
    });

    return { ok: true };
  }

  async registerInteraction(input: {
    userId: string;
    songId?: string;
    interactionType: string;
    interactionValue?: string;
    metadata?: unknown;
  }) {
    await repository.registerInteraction({
      userId: BigInt(input.userId),
      songId: input.songId ? BigInt(input.songId) : undefined,
      interactionType: input.interactionType,
      interactionValue: input.interactionValue,
      metadata: input.metadata,
    });
    return { ok: true };
  }

  async list(userId: string) {
    const rows = await repository.list(BigInt(userId));
    return rows.map((row) => ({
      id: row.id.toString(),
      songId: row.songId.toString(),
      title: row.song.title,
      artist: row.song.artist.name,
      genre: row.song.genre.name,
      playedSeconds: row.playedSeconds,
      completionRate: row.completionRate,
      startedAt: row.startedAt,
    }));
  }
}

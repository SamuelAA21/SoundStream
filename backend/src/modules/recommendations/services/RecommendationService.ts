import { RecommendationEngine } from "../../../engines/RecommendationEngine/RecommendationEngine.js";
import { eventBus } from "../../../events/DomainEventBus.js";
import { logger } from "../../../config/logger.js";
import { RecommendationRepository } from "../repositories/RecommendationRepository.js";

const repository = new RecommendationRepository();

/**
 * RecommendationService
 *
 * Usa el Singleton de RecommendationEngine y se suscribe al
 * DomainEventBus (Observer) para refrescar recomendaciones
 * automáticamente cuando el usuario agrega favoritos o termina
 * de escuchar una canción.
 */
export class RecommendationService {
  constructor() {
    this.registerEventListeners();
  }

  /** Patrón Observer: escucha eventos de dominio relevantes. */
  private registerEventListeners(): void {
    eventBus.on("favorite.added", async ({ userId }) => {
      logger.debug("Refrescando recomendaciones por nuevo favorito", { userId });
      await this.refresh(userId);
    });

    eventBus.on("song.played", async ({ userId, completionRate }) => {
      // Solo refrescar si la canción fue escuchada casi completa
      if (completionRate >= 0.8) {
        logger.debug("Refrescando recomendaciones por canción completada", { userId });
        await this.refresh(userId);
      }
    });

    eventBus.on("recommendation.refresh_requested", async ({ userId }) => {
      await this.refresh(userId);
    });
  }

  async list(userId: string) {
    let rows = await repository.getActive(BigInt(userId));
    if (rows.length === 0) {
      await this.refresh(userId);
      rows = await repository.getActive(BigInt(userId));
    }
    return rows.map((row) => ({
      id: row.song.id.toString(),
      title: row.song.title,
      artist: row.song.artist.name,
      album: row.song.album?.title ?? null,
      genre: row.song.genre.name,
      score: row.score,
      reason: row.reasonText,
    }));
  }

  async refresh(userId: string) {
    const id = BigInt(userId);
    const signals = await repository.buildSignals(id);
    const candidates = await repository.selectCandidates(id);

    // Singleton del motor — Strategy se elige dentro de engine.score()
    const engine = RecommendationEngine.getInstance();
    logger.info("Ejecutando scoring", { strategy: engine.currentStrategy, userId });

    const scored = engine.score(
      candidates.map((candidate) => ({
        songId: candidate.id,
        genreId: candidate.genreId,
        artistId: candidate.artistId,
        title: candidate.title,
      })),
      signals
    );

    await repository.replaceForUser(id, scored);
    return { ok: true, count: Math.min(scored.length, 20) };
  }
}

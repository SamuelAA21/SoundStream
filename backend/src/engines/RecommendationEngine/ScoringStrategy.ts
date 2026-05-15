/**
 * Patrón Strategy — Estrategias de puntuación para recomendaciones
 *
 * Permite intercambiar el algoritmo de scoring sin modificar la clase
 * RecommendationEngine (principio Open/Closed). Nuevas estrategias
 * (p.ej. basada en ML, collaborative filtering, trending) se agregan
 * implementando la interfaz IScoringStrategy.
 */

import type {
  RecommendationCandidate,
  RecommendationSignal,
  ScoredResult,
} from "./types.js";

// ─── Interfaz (contrato de la estrategia) ─────────────────────────────────────

export interface IScoringStrategy {
  readonly name: string;
  score(
    candidates: RecommendationCandidate[],
    signals: RecommendationSignal[]
  ): ScoredResult[];
}

// ─── Estrategia 1: Híbrida (la original, ahora encapsulada) ──────────────────

export class HybridScoringStrategy implements IScoringStrategy {
  readonly name = "hybrid";

  score(
    candidates: RecommendationCandidate[],
    signals: RecommendationSignal[]
  ): ScoredResult[] {
    if (signals.length === 0) return [];

    const maxPlays = Math.max(...signals.map((s) => s.playCount), 1);
    const maxFavorites = Math.max(...signals.map((s) => s.favoriteCount), 1);
    const maxInteractions = Math.max(
      ...signals.map((s) => s.interactionCount),
      1
    );

    return candidates
      .map((candidate) => {
        const genreSignal = signals.find(
          (s) => s.genreId === candidate.genreId
        );
        const artistSignal = signals.find(
          (s) => s.artistId === candidate.artistId
        );

        const scoreHistory = genreSignal
          ? genreSignal.playCount / maxPlays
          : 0;
        const scoreFavorites = genreSignal
          ? genreSignal.favoriteCount / maxFavorites
          : 0;
        const scoreArtist = artistSignal
          ? artistSignal.playCount / maxPlays
          : 0;
        const scoreGenre = genreSignal ? 1 : 0;
        const scoreInteraction = genreSignal
          ? genreSignal.interactionCount / maxInteractions
          : 0;
        const scoreSimilarity = scoreGenre * 0.6 + scoreArtist * 0.4;

        const score =
          0.25 * scoreHistory +
          0.2 * scoreFavorites +
          0.15 * scoreGenre +
          0.15 * scoreArtist +
          0.15 * scoreSimilarity +
          0.1 * scoreInteraction;

        return {
          songId: candidate.songId,
          score,
          reasonText: this.reason(candidate, scoreGenre > 0, scoreArtist > 0),
        };
      })
      .filter((item) => item.score > 0)
      .sort((a, b) => b.score - a.score);
  }

  private reason(
    candidate: RecommendationCandidate,
    genreMatch: boolean,
    artistMatch: boolean
  ): string {
    if (artistMatch)
      return `Porque escuchas artistas similares a ${candidate.title}`;
    if (genreMatch) return "Porque coincide con tus géneros más escuchados";
    return "Recomendación basada en tu actividad reciente";
  }
}

// ─── Estrategia 2: Solo popularidad (para usuarios nuevos sin historial) ──────

export class PopularityScoringStrategy implements IScoringStrategy {
  readonly name = "popularity";

  score(
    candidates: RecommendationCandidate[],
    _signals: RecommendationSignal[]
  ): ScoredResult[] {
    // Sin señales del usuario: asigna score aleatorio uniforme (cold start)
    return candidates
      .map((candidate) => ({
        songId: candidate.songId,
        score: Math.random(), // En producción vendría de un campo "plays_total" en la BD
        reasonText: "Tendencias en SoundStream",
      }))
      .sort((a, b) => b.score - a.score);
  }
}

// ─── Estrategia 3: Género favorito (simple, alta precisión) ──────────────────

export class GenreFocusedScoringStrategy implements IScoringStrategy {
  readonly name = "genre_focused";

  score(
    candidates: RecommendationCandidate[],
    signals: RecommendationSignal[]
  ): ScoredResult[] {
    if (signals.length === 0) return [];

    const topGenre = signals.sort(
      (a, b) => b.playCount + b.favoriteCount - (a.playCount + a.favoriteCount)
    )[0];

    return candidates
      .filter((c) => c.genreId === topGenre.genreId)
      .map((candidate) => ({
        songId: candidate.songId,
        score: 1,
        reasonText: "Basado en tu género favorito",
      }));
  }
}

/** Tipos compartidos entre el motor de recomendaciones y sus estrategias. */

export type RecommendationSignal = {
  genreId: bigint;
  artistId: bigint;
  playCount: number;
  favoriteCount: number;
  interactionCount: number;
};

export type RecommendationCandidate = {
  songId: bigint;
  genreId: bigint;
  artistId: bigint;
  title: string;
};

export type ScoredResult = {
  songId: bigint;
  score: number;
  reasonText: string;
};

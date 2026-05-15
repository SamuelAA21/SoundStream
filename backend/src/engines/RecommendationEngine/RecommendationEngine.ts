/**
 * RecommendationEngine — Singleton + Strategy
 *
 * Singleton: una única instancia del motor en toda la app.
 * Strategy:  la estrategia de scoring es intercambiable en tiempo de
 *            ejecución (p.ej. cold-start vs usuario con historial).
 */

import type { RecommendationCandidate, RecommendationSignal, ScoredResult } from "./types.js";
import {
  HybridScoringStrategy,
  PopularityScoringStrategy,
  type IScoringStrategy,
} from "./ScoringStrategy.js";

// Re-exportamos los tipos para que los importadores externos no cambien
export type { RecommendationSignal, RecommendationCandidate };

export class RecommendationEngine {
  private static instance: RecommendationEngine | null = null;

  private strategy: IScoringStrategy;

  private constructor() {
    // Estrategia por defecto
    this.strategy = new HybridScoringStrategy();
  }

  /** Punto de acceso global al Singleton. */
  static getInstance(): RecommendationEngine {
    if (!RecommendationEngine.instance) {
      RecommendationEngine.instance = new RecommendationEngine();
    }
    return RecommendationEngine.instance;
  }

  /**
   * Cambia la estrategia de scoring en tiempo de ejecución.
   * Útil para cold-start (usuario nuevo sin historial).
   */
  setStrategy(strategy: IScoringStrategy): void {
    this.strategy = strategy;
  }

  get currentStrategy(): string {
    return this.strategy.name;
  }

  /**
   * Puntúa candidatos usando la estrategia activa.
   * Si el usuario no tiene señales, cambia automáticamente a popularidad.
   */
  score(
    candidates: RecommendationCandidate[],
    signals: RecommendationSignal[]
  ): ScoredResult[] {
    // Cold-start: sin historial → estrategia de popularidad
    if (signals.length === 0) {
      const fallback = new PopularityScoringStrategy();
      return fallback.score(candidates, signals);
    }

    return this.strategy.score(candidates, signals);
  }

  /** Solo para tests. */
  static reset(): void {
    RecommendationEngine.instance = null;
  }
}

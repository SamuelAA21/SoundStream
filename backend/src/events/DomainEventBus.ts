/**
 * Patrón Observer (EventEmitter) — DomainEventBus
 *
 * Bus de eventos de dominio que desacopla los módulos entre sí.
 * En lugar de que FavoriteService importe RecommendationService
 * directamente (acoplamiento fuerte), emite un evento y cualquier
 * suscriptor reacciona de forma independiente.
 *
 * También es un Singleton: un único bus centraliza todos los eventos
 * de la aplicación, lo que facilita debugging y monitoreo.
 *
 * Ejemplo de flujo:
 *   FavoriteService  →  emite "favorite.added"
 *   RecommendationService  ←  escucha "favorite.added" y refresca
 */

// ─── Definición de eventos ────────────────────────────────────────────────────

export interface DomainEvents {
  "song.played": { userId: string; songId: string; completionRate: number };
  "favorite.added": { userId: string; songId: string };
  "favorite.removed": { userId: string; songId: string };
  "recommendation.refresh_requested": { userId: string };
  "user.registered": { userId: string; role: string };
}

export type DomainEventName = keyof DomainEvents;
export type DomainEventPayload<T extends DomainEventName> = DomainEvents[T];

type Listener<T extends DomainEventName> = (
  payload: DomainEventPayload<T>
) => void | Promise<void>;

// ─── Singleton ────────────────────────────────────────────────────────────────

class DomainEventBus {
  private static instance: DomainEventBus | null = null;

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  private readonly listeners = new Map<string, Set<Listener<any>>>();

  private constructor() {}

  static getInstance(): DomainEventBus {
    if (!DomainEventBus.instance) {
      DomainEventBus.instance = new DomainEventBus();
    }
    return DomainEventBus.instance;
  }

  /** Suscribe un listener a un evento de dominio. */
  on<T extends DomainEventName>(event: T, listener: Listener<T>): void {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, new Set());
    }
    this.listeners.get(event)!.add(listener as Listener<DomainEventName>);
  }

  /** Elimina un listener específico. */
  off<T extends DomainEventName>(event: T, listener: Listener<T>): void {
    this.listeners.get(event)?.delete(listener as Listener<DomainEventName>);
  }

  /**
   * Emite un evento de dominio.
   * Los listeners se ejecutan de forma concurrente (Promise.allSettled)
   * para que un fallo en uno no bloquee a los demás.
   */
  async emit<T extends DomainEventName>(
    event: T,
    payload: DomainEventPayload<T>
  ): Promise<void> {
    const handlers = this.listeners.get(event);
    if (!handlers || handlers.size === 0) return;

    const results = await Promise.allSettled(
      [...handlers].map((handler) => handler(payload))
    );

    // Loguear errores sin propagar (no rompemos el flujo principal)
    results.forEach((result) => {
      if (result.status === "rejected") {
        console.error(`[DomainEventBus] Error en listener de "${event}":`, result.reason);
      }
    });
  }

  /** Solo para tests. */
  static reset(): void {
    DomainEventBus.instance = null;
  }
}

export const eventBus = DomainEventBus.getInstance();

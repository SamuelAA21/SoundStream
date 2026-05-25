import { PrismaClient } from "@prisma/client";

/**
 * Patrón Singleton para PrismaClient.
 *
 * Garantiza una única instancia de conexión a la base de datos durante
 * todo el ciclo de vida de la aplicación, evitando agotamiento de
 * conexiones en entornos serverless o con hot-reload (desarrollo).
 *
 * En producción el módulo ya actúa como singleton gracias al sistema
 * de caché de módulos de Node.js; el globalThis lo extiende a entornos
 * de desarrollo donde el módulo puede volver a evaluarse.
 */
class PrismaClientSingleton {
  private static instance: PrismaClient | null = null;

  private constructor() {}

  static getInstance(): PrismaClient {
    if (PrismaClientSingleton.instance) {
      return PrismaClientSingleton.instance;
    }

    PrismaClientSingleton.instance = new PrismaClient({
      log:
        process.env.NODE_ENV === "development"
          ? ["query", "error", "warn"]
          : ["error"],
    });

    return PrismaClientSingleton.instance;
  }

  /** Solo para tests: permite reiniciar la instancia entre suites. */
  static reset(): void {
    PrismaClientSingleton.instance = null;
  }
}

// Soporte para hot-reload en desarrollo (evita múltiples instancias)
const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient };

export const prisma =
  globalForPrisma.prisma ?? PrismaClientSingleton.getInstance();

if (process.env.NODE_ENV !== "production") {
  globalForPrisma.prisma = prisma;
}

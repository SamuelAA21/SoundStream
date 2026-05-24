import { PrismaClient } from "@prisma/client";

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

const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient };

export const prisma =
  globalForPrisma.prisma ?? PrismaClientSingleton.getInstance();

if (process.env.NODE_ENV !== "production") {
  globalForPrisma.prisma = prisma;
}

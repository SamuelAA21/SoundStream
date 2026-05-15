/**
 * Patrón Singleton — AppLogger
 *
 * Logger centralizado para toda la aplicación. Una sola instancia
 * garantiza consistencia en el formato de logs y facilita cambiar
 * el destino (consola, archivo, servicio externo) desde un único lugar.
 */

type LogLevel = "debug" | "info" | "warn" | "error";

interface LogEntry {
  level: LogLevel;
  message: string;
  timestamp: string;
  context?: Record<string, unknown>;
}

class AppLogger {
  private static instance: AppLogger | null = null;
  private readonly isDev: boolean;

  private constructor() {
    this.isDev = process.env.NODE_ENV !== "production";
  }

  /** Punto de acceso global al singleton. */
  static getInstance(): AppLogger {
    if (!AppLogger.instance) {
      AppLogger.instance = new AppLogger();
    }
    return AppLogger.instance;
  }

  private format(entry: LogEntry): string {
    const base = `[${entry.timestamp}] ${entry.level.toUpperCase()} - ${entry.message}`;
    if (entry.context && Object.keys(entry.context).length > 0) {
      return `${base} ${JSON.stringify(entry.context)}`;
    }
    return base;
  }

  private log(level: LogLevel, message: string, context?: Record<string, unknown>) {
    const entry: LogEntry = {
      level,
      message,
      timestamp: new Date().toISOString(),
      context,
    };

    const formatted = this.format(entry);

    switch (level) {
      case "debug":
        if (this.isDev) console.debug(formatted);
        break;
      case "info":
        console.info(formatted);
        break;
      case "warn":
        console.warn(formatted);
        break;
      case "error":
        console.error(formatted);
        break;
    }
  }

  debug(message: string, context?: Record<string, unknown>) {
    this.log("debug", message, context);
  }

  info(message: string, context?: Record<string, unknown>) {
    this.log("info", message, context);
  }

  warn(message: string, context?: Record<string, unknown>) {
    this.log("warn", message, context);
  }

  error(message: string, context?: Record<string, unknown>) {
    this.log("error", message, context);
  }
}

/** Instancia singleton exportada para uso directo en módulos. */
export const logger = AppLogger.getInstance();

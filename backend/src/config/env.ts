import { z } from "zod";
import "./loadEnv.js";

const envSchema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  PORT: z.coerce.number().int().positive().default(3000),
  HOST: z.string().default("0.0.0.0"),
  DATABASE_URL: z.string().min(1),
  JWT_SECRET: z.string().min(16),
  JWT_EXPIRES_IN: z.string().default("15m"),
  REFRESH_TOKEN_DAYS: z.coerce.number().int().positive().default(30),
  AUDIO_STORAGE_PATH: z.string().default("./storage/audio"),
  STATIC_PATH: z.string().optional(),
  WEB_ORIGIN: z.string().default("http://localhost:5173"),
  WEB_ORIGINS: z.string().optional()
});

export const env = envSchema.parse(process.env);

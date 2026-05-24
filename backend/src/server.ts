import cors from "@fastify/cors";
import jwt from "@fastify/jwt";
import multipart from "@fastify/multipart";
import rateLimit from "@fastify/rate-limit";
import fastifyStatic from "@fastify/static";
import Fastify from "fastify";
import { existsSync } from "fs";
import { resolve } from "path";
import { env } from "./config/env.js";
import { errorHandler } from "./middlewares/errorHandler.js";
import { registerRoutes } from "./routes/index.js";

const app = Fastify({
  logger: {
    level: env.NODE_ENV === "development" ? "info" : "warn"
  }
});

const allowedOrigins = new Set(
  (env.WEB_ORIGINS?.split(",") ?? [env.WEB_ORIGIN])
    .map((origin) => origin.trim())
    .filter(Boolean)
);

app.register(cors, {
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.has(origin)) {
      callback(null, true);
      return;
    }

    callback(new Error("Origin not allowed"), false);
  },
  credentials: true,
  exposedHeaders: ["Content-Range", "Accept-Ranges", "Content-Length"]
});

app.register(rateLimit, {
  max: 120,
  timeWindow: "1 minute"
});

app.register(multipart, {
  limits: {
    fileSize: 50 * 1024 * 1024,
    files: 1
  }
});

app.register(jwt, {
  secret: env.JWT_SECRET,
  sign: {
    expiresIn: env.JWT_EXPIRES_IN
  }
});

app.setErrorHandler(errorHandler);

const staticRoot = env.STATIC_PATH ? resolve(env.STATIC_PATH) : null;
const serveStatic = staticRoot !== null && existsSync(staticRoot);

if (serveStatic) {
  app.register(fastifyStatic, {
    root: staticRoot,
    prefix: "/",
    wildcard: false,
  });
}

app.get("/health", async () => ({ status: "ok", service: "soundstream-backend" }));
app.register(registerRoutes, { prefix: "/api" });

if (serveStatic) {
  app.setNotFoundHandler(async (request, reply) => {
    if (request.url.startsWith("/api")) {
      return reply.code(404).send({ statusCode: 404, error: "Not Found", message: "Route not found" });
    }
    return reply.sendFile("index.html");
  });
}

await app.listen({ port: env.PORT, host: env.HOST });

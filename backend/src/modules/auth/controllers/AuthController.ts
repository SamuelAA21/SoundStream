import type { FastifyInstance } from "fastify";
import { z } from "zod";
import { requireAuth } from "../../../middlewares/auth.js";
import { AuthService } from "../services/AuthService.js";

const service = new AuthService();

const registerSchema = z.object({
  name: z.string().min(2).max(120),
  email: z.string().email().max(150),
  password: z.string().min(8).max(100),
  accountType: z.enum(["user", "artist"]).default("user"),
  artistName: z.string().min(2).max(150).optional()
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1)
});

const refreshSchema = z.object({
  refreshToken: z.string().min(32)
});

export async function registerAuthRoutes(app: FastifyInstance) {
  app.get("/me", { preHandler: requireAuth }, async (request) => {
    return service.me((request.user as { sub: string }).sub);
  });

  app.post("/register", async (request, reply) => {
    const body = registerSchema.parse(request.body);
    return reply.status(201).send(await service.register(app, body));
  });

  app.post("/login", async (request) => {
    const body = loginSchema.parse(request.body);
    return service.login(app, body);
  });

  app.post("/refresh", async (request) => {
    const body = refreshSchema.parse(request.body);
    return service.refresh(app, body.refreshToken);
  });

  app.post("/logout", async (request) => {
    const body = refreshSchema.parse(request.body);
    return service.logout(body.refreshToken);
  });
}

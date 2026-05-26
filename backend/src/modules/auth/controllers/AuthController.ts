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

const totpCodeSchema = z.object({
  code: z.string().length(6).regex(/^\d{6}$/)
});

const totpValidateSchema = z.object({
  tempToken: z.string().min(1),
  code: z.string().length(6).regex(/^\d{6}$/)
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

  app.post("/2fa/setup", { preHandler: requireAuth }, async (request) => {
    const userId = (request.user as { sub: string }).sub;
    return service.setupTotp(userId);
  });

  app.post("/2fa/confirm", { preHandler: requireAuth }, async (request) => {
    const userId = (request.user as { sub: string }).sub;
    const { code } = totpCodeSchema.parse(request.body);
    return service.confirmTotp(userId, code);
  });

  app.delete("/2fa/disable", { preHandler: requireAuth }, async (request) => {
    const userId = (request.user as { sub: string }).sub;
    const { code } = totpCodeSchema.parse(request.body);
    return service.disableTotp(userId, code);
  });

  app.post("/2fa/validate", async (request) => {
    const body = totpValidateSchema.parse(request.body);
    return service.validateTotp(app, body);
  });

  app.post("/2fa/confirm-setup", async (request) => {
    const body = totpValidateSchema.parse(request.body);
    return service.confirmSetupTotp(app, body);
  });
}

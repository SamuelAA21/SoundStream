import type { FastifyInstance } from "fastify";
import { z } from "zod";
import { requireAuth } from "../../../middlewares/auth.js";
import { HistoryService } from "../services/HistoryService.js";

const service = new HistoryService();

const playSchema = z.object({
  songId: z.string().regex(/^\d+$/),
  playedSeconds: z.number().int().min(0),
  completionRate: z.number().min(0).max(100),
  deviceType: z.enum(["web", "android"]).default("web")
});

const interactionSchema = z.object({
  songId: z.string().regex(/^\d+$/).optional(),
  interactionType: z.enum([
    "search",
    "play",
    "pause",
    "resume",
    "skip_forward",
    "skip_backward",
    "favorite",
    "unfavorite",
    "playlist_add",
    "playlist_remove",
    "recommendation_click"
  ]),
  interactionValue: z.string().max(255).optional(),
  metadata: z.unknown().optional()
});

export async function registerHistoryRoutes(app: FastifyInstance) {
  app.addHook("preHandler", requireAuth);

  app.get("/", async (request) => {
    return service.list((request.user as { sub: string }).sub);
  });

  app.post("/plays", async (request) => {
    const body = playSchema.parse(request.body);
    return service.registerPlay({ userId: (request.user as { sub: string }).sub, ...body });
  });

  app.post("/interactions", async (request) => {
    const body = interactionSchema.parse(request.body);
    return service.registerInteraction({ userId: (request.user as { sub: string }).sub, ...body });
  });
}

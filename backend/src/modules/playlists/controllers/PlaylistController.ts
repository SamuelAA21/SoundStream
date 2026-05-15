import type { FastifyInstance } from "fastify";
import { z } from "zod";
import { requireAuth } from "../../../middlewares/auth.js";
import { PlaylistService } from "../services/PlaylistService.js";

const service = new PlaylistService();

const createSchema = z.object({
  name: z.string().min(2).max(150),
  description: z.string().max(255).optional(),
  isPublic: z.boolean().optional()
});

const playlistParamsSchema = z.object({
  playlistId: z.string().regex(/^\d+$/)
});

const songParamsSchema = z.object({
  playlistId: z.string().regex(/^\d+$/),
  songId: z.string().regex(/^\d+$/)
});

export async function registerPlaylistRoutes(app: FastifyInstance) {
  app.addHook("preHandler", requireAuth);

  app.get("/", async (request) => {
    return service.list((request.user as { sub: string }).sub);
  });

  app.post("/", async (request, reply) => {
    const body = createSchema.parse(request.body);
    const playlist = await service.create((request.user as { sub: string }).sub, body);
    return reply.status(201).send(playlist);
  });

  app.get("/:playlistId", async (request) => {
    const { playlistId } = playlistParamsSchema.parse(request.params);
    return service.detail((request.user as { sub: string }).sub, playlistId);
  });

  app.post("/:playlistId/songs/:songId", async (request) => {
    const { playlistId, songId } = songParamsSchema.parse(request.params);
    return service.addSong((request.user as { sub: string }).sub, playlistId, songId);
  });

  app.delete("/:playlistId/songs/:songId", async (request) => {
    const { playlistId, songId } = songParamsSchema.parse(request.params);
    return service.removeSong((request.user as { sub: string }).sub, playlistId, songId);
  });
}

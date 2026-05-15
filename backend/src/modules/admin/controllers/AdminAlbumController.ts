import type { FastifyInstance } from "fastify";
import { z } from "zod";
import { requireAdmin } from "../../../middlewares/auth.js";
import { AdminAlbumService } from "../services/AdminAlbumService.js";

const service = new AdminAlbumService();

const createAlbumSchema = z.object({
  title: z.string().min(2).max(180),
  artistName: z.string().min(2).max(150).optional(),
  genreName: z.string().max(100).optional(),
  songIds: z.array(z.string().regex(/^\d+$/)).default([])
});

export async function registerAdminAlbumRoutes(app: FastifyInstance) {
  app.post("/albums", { preHandler: requireAdmin }, async (request, reply) => {
    const body = createAlbumSchema.parse(request.body);
    const album = await service.createAlbum(body);
    return reply.status(201).send(album);
  });
}

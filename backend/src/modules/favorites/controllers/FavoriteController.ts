import type { FastifyInstance } from "fastify";
import { z } from "zod";
import { requireAuth } from "../../../middlewares/auth.js";
import { FavoriteService } from "../services/FavoriteService.js";

const service = new FavoriteService();
const paramsSchema = z.object({ songId: z.string().regex(/^\d+$/) });

export async function registerFavoriteRoutes(app: FastifyInstance) {
  app.addHook("preHandler", requireAuth);

  app.get("/", async (request) => {
    return service.list((request.user as { sub: string }).sub);
  });

  app.post("/:songId", async (request) => {
    const { songId } = paramsSchema.parse(request.params);
    return service.add((request.user as { sub: string }).sub, songId);
  });

  app.delete("/:songId", async (request) => {
    const { songId } = paramsSchema.parse(request.params);
    return service.remove((request.user as { sub: string }).sub, songId);
  });
}

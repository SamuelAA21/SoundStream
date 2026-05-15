import type { FastifyInstance } from "fastify";
import { requireAuth } from "../../../middlewares/auth.js";
import { RecommendationService } from "../services/RecommendationService.js";

const service = new RecommendationService();

export async function registerRecommendationRoutes(app: FastifyInstance) {
  app.addHook("preHandler", requireAuth);

  app.get("/", async (request) => {
    return service.list((request.user as { sub: string }).sub);
  });

  app.post("/refresh", async (request) => {
    return service.refresh((request.user as { sub: string }).sub);
  });
}

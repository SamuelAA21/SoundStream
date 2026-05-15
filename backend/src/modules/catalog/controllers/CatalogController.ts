import type { FastifyInstance } from "fastify";
import { CatalogService } from "../services/CatalogService.js";

const service = new CatalogService();

export async function registerCatalogRoutes(app: FastifyInstance) {
  app.get("/albums", async () => {
    return service.listAlbums();
  });

  app.get("/albums/:albumId", async (request) => {
    const { albumId } = request.params as { albumId: string };
    return service.getAlbum(albumId);
  });

  app.get("/songs", async (request) => {
    return service.listSongs(request.query as { q?: string; page?: string; limit?: string });
  });

  app.get("/songs/:songId", async (request) => {
    const { songId } = request.params as { songId: string };
    return service.getSong(songId);
  });
}

import type { FastifyInstance } from "fastify";
import { registerAdminAlbumRoutes } from "../modules/admin/controllers/AdminAlbumController.js";
import { registerAdminDeployRoutes } from "../modules/admin/controllers/AdminDeployController.js";
import { registerAdminSongRoutes } from "../modules/admin/controllers/AdminSongController.js";
import { registerAdminUserRoutes } from "../modules/admin/controllers/AdminUserController.js";
import { registerAuthRoutes } from "../modules/auth/controllers/AuthController.js";
import { registerArtistRoutes } from "../modules/artist/controllers/ArtistController.js";
import { registerCatalogRoutes } from "../modules/catalog/controllers/CatalogController.js";
import { registerFavoriteRoutes } from "../modules/favorites/controllers/FavoriteController.js";
import { registerHistoryRoutes } from "../modules/history/controllers/HistoryController.js";
import { registerPlaylistRoutes } from "../modules/playlists/controllers/PlaylistController.js";
import { registerRecommendationRoutes } from "../modules/recommendations/controllers/RecommendationController.js";
import { registerStreamingRoutes } from "../modules/streaming/controllers/StreamingController.js";

export async function registerRoutes(app: FastifyInstance) {
  app.register(registerAdminSongRoutes, { prefix: "/admin" });
  app.register(registerAdminAlbumRoutes, { prefix: "/admin" });
  app.register(registerAdminUserRoutes, { prefix: "/admin" });
  app.register(registerAdminDeployRoutes, { prefix: "/admin" });
  app.register(registerAuthRoutes, { prefix: "/auth" });
  app.register(registerArtistRoutes, { prefix: "/artist" });
  app.register(registerCatalogRoutes, { prefix: "/catalog" });
  app.register(registerFavoriteRoutes, { prefix: "/favorites" });
  app.register(registerHistoryRoutes, { prefix: "/history" });
  app.register(registerPlaylistRoutes, { prefix: "/playlists" });
  app.register(registerRecommendationRoutes, { prefix: "/recommendations" });
  app.register(registerStreamingRoutes, { prefix: "/stream" });
}

import type { FastifyInstance } from "fastify";
import { z } from "zod";
import { requireAdmin } from "../../../middlewares/auth.js";
import { AppError } from "../../../utils/AppError.js";
import { AdminAlbumService } from "../services/AdminAlbumService.js";
import { AdminSongService } from "../services/AdminSongService.js";

const service = new AdminSongService();
const albumService = new AdminAlbumService();
const songParamsSchema = z.object({ songId: z.string().regex(/^\d+$/) });
const albumAssignmentSchema = z.object({
  albumId: z.string().regex(/^\d+$/).nullable().optional()
});

export async function registerAdminSongRoutes(app: FastifyInstance) {
  app.post("/songs", { preHandler: requireAdmin }, async (request, reply) => {
    const parts = request.parts();
    const fields: Record<string, string> = {};

    for await (const part of parts) {
      if (part.type === "file") {
        if (part.fieldname === "audioFile") {
          const song = await service.uploadSong({ fields, file: part });
          return reply.status(201).send(song);
        } else {
          part.file.resume();
        }
      } else {
        fields[part.fieldname] = String(part.value);
      }
    }

    throw new AppError(422, "missing_audio_file", "audioFile is required");
  });

  app.delete("/songs/:songId", { preHandler: requireAdmin }, async (request) => {
    const { songId } = songParamsSchema.parse(request.params);
    return service.deleteSong(songId);
  });

  app.patch("/songs/:songId/album", { preHandler: requireAdmin }, async (request) => {
    const { songId } = songParamsSchema.parse(request.params);
    const body = albumAssignmentSchema.parse(request.body);
    return albumService.assignSongToAlbum({
      songId,
      albumId: body.albumId ?? null
    });
  });
}

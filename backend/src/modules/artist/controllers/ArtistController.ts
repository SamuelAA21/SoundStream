import type { FastifyInstance } from "fastify";
import { z } from "zod";
import { requireArtist } from "../../../middlewares/artist.js";
import { AppError } from "../../../utils/AppError.js";
import { ArtistService } from "../services/ArtistService.js";

const service = new ArtistService();

const createAlbumSchema = z.object({
  title: z.string().min(2).max(180),
  genreName: z.string().max(100).optional(),
  songIds: z.array(z.string().regex(/^\d+$/)).default([])
});

const songParamsSchema = z.object({
  songId: z.string().regex(/^\d+$/)
});

const publicationSchema = z.object({
  isPublished: z.boolean()
});

const albumAssignmentSchema = z.object({
  albumId: z.string().regex(/^\d+$/).nullable().optional()
});

export async function registerArtistRoutes(app: FastifyInstance) {
  app.addHook("preHandler", requireArtist);

  app.get("/songs", async (request) => {
    return service.listMySongs((request.user as { sub: string }).sub);
  });

  app.post("/songs", async (request, reply) => {
    const parts = request.parts();
    const fields: Record<string, string> = {};

    for await (const part of parts) {
      if (part.type === "file") {
        if (part.fieldname === "audioFile") {
          const song = await service.uploadSong({
            userId: (request.user as { sub: string }).sub,
            fields,
            file: part
          });
          return reply.status(201).send(song);
        }
        part.file.resume();
      } else {
        fields[part.fieldname] = String(part.value);
      }
    }

    throw new AppError(422, "missing_audio_file", "audioFile is required");
  });

  app.patch("/songs/:songId/publication", async (request) => {
    const params = songParamsSchema.parse(request.params);
    const body = publicationSchema.parse(request.body);
    return service.publishSong({
      userId: (request.user as { sub: string }).sub,
      songId: params.songId,
      isPublished: body.isPublished
    });
  });

  app.delete("/songs/:songId", async (request) => {
    const params = songParamsSchema.parse(request.params);
    return service.deleteSong({
      userId: (request.user as { sub: string }).sub,
      songId: params.songId
    });
  });

  app.patch("/songs/:songId/album", async (request) => {
    const params = songParamsSchema.parse(request.params);
    const body = albumAssignmentSchema.parse(request.body);
    return service.assignSongToAlbum({
      userId: (request.user as { sub: string }).sub,
      songId: params.songId,
      albumId: body.albumId ?? null
    });
  });

  app.post("/albums", async (request, reply) => {
    const body = createAlbumSchema.parse(request.body);
    const album = await service.createAlbum({
      userId: (request.user as { sub: string }).sub,
      ...body
    });
    return reply.status(201).send(album);
  });
}

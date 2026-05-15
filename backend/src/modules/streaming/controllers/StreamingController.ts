import type { FastifyInstance } from "fastify";
import { z } from "zod";
import { requireAuth } from "../../../middlewares/auth.js";
import { StreamingService } from "../services/StreamingService.js";

const service = new StreamingService();
const paramsSchema = z.object({ songId: z.string().regex(/^\d+$/) });

export async function registerStreamingRoutes(app: FastifyInstance) {
  app.get("/songs/:songId", { preHandler: requireAuth }, async (request, reply) => {
    const { songId } = paramsSchema.parse(request.params);
    const rangeHeader = request.headers.range;
    const payload = await service.prepareStream({
      userId: (request.user as { sub: string }).sub,
      songId,
      range: rangeHeader
    });

    reply
      .status(payload.range.isPartial ? 206 : 200)
      .header("Content-Type", payload.mimeType)
      .header("Accept-Ranges", "bytes")
      .header("Content-Length", payload.range.length)
      .header("Cache-Control", "no-store, no-cache, must-revalidate")
      .header("X-Content-Type-Options", "nosniff")
      .header("Content-Disposition", "inline");

    if (payload.range.isPartial) {
      reply.header("Content-Range", `bytes ${payload.range.start}-${payload.range.end}/${payload.fileSize}`);
    }

    return reply.send(payload.stream);
  });
}

import type { FastifyReply, FastifyRequest } from "fastify";
import { AppError } from "../utils/AppError.js";
import { requireAuth } from "./auth.js";

export async function requireArtist(request: FastifyRequest, reply: FastifyReply) {
  await requireAuth(request, reply);
  const user = request.user as { role?: string };
  if (user.role !== "artist") {
    throw new AppError(403, "artist_only", "Artist role is required");
  }
}

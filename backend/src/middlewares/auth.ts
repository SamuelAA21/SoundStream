import type { FastifyReply, FastifyRequest } from "fastify";
import { AppError } from "../utils/AppError.js";

export async function requireAuth(request: FastifyRequest, _reply: FastifyReply) {
  try {
    await request.jwtVerify();
  } catch {
    throw new AppError(401, "unauthorized", "Authentication token is missing or invalid");
  }
}

export async function requireAdmin(request: FastifyRequest, _reply: FastifyReply) {
  await requireAuth(request, _reply);
  const user = request.user as { role?: string };
  if (user.role !== "admin") {
    throw new AppError(403, "admin_only", "Administrator role is required");
  }
}

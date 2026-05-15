import type { FastifyInstance } from "fastify";
import { z } from "zod";
import { requireAdmin } from "../../../middlewares/auth.js";
import { AdminUserService } from "../services/AdminUserService.js";

const service = new AdminUserService();

const paramsSchema = z.object({
  userId: z.string().regex(/^\d+$/)
});

const statusSchema = z.object({
  status: z.enum(["active", "inactive", "blocked"])
});

export async function registerAdminUserRoutes(app: FastifyInstance) {
  app.addHook("preHandler", requireAdmin);

  app.get("/users", async () => {
    return service.listUsers();
  });

  app.patch("/users/:userId/status", async (request) => {
    const { userId } = paramsSchema.parse(request.params);
    const body = statusSchema.parse(request.body);
    return service.updateStatus({
      adminUserId: (request.user as { sub: string }).sub,
      targetUserId: userId,
      status: body.status
    });
  });
}

import { prisma } from "../../../config/prisma.js";

export class AdminUserRepository {
  listUsers() {
    return prisma.user.findMany({
      include: { role: true },
      orderBy: { createdAt: "desc" }
    });
  }

  findUser(userId: bigint) {
    return prisma.user.findUnique({
      where: { id: userId },
      include: { role: true }
    });
  }

  updateStatus(input: { userId: bigint; status: string }) {
    return prisma.user.update({
      where: { id: input.userId },
      data: { status: input.status },
      include: { role: true }
    });
  }

  revokeUserTokens(userId: bigint) {
    return prisma.refreshToken.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() }
    });
  }
}

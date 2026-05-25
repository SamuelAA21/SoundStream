import { prisma } from "../../../config/prisma.js";

export class AuthRepository {
  findUserByEmail(email: string) {
    return prisma.user.findUnique({
      where: { email },
      include: { role: true, artistProfile: true }
    });
  }

  findUserById(id: bigint) {
    return prisma.user.findUnique({
      where: { id },
      include: { role: true, artistProfile: true }
    });
  }

  createUser(input: { name: string; email: string; passwordHash: string; roleId: bigint; artistName?: string }) {
    return prisma.user.create({
      data: {
        name: input.name,
        email: input.email,
        passwordHash: input.passwordHash,
        roleId: input.roleId,
        artistProfile: input.artistName
          ? {
              create: {
                name: input.artistName
              }
            }
          : undefined
      },
      include: { role: true, artistProfile: true }
    });
  }

  updateLastLogin(userId: bigint) {
    return prisma.user.update({
      where: { id: userId },
      data: { lastLoginAt: new Date() }
    });
  }

  findRoleByName(name: string) {
    return prisma.role.findUnique({ where: { name } });
  }

  saveRefreshToken(input: { userId: bigint; tokenHash: string; expiresAt: Date }) {
    return prisma.refreshToken.create({
      data: input
    });
  }

  findRefreshToken(tokenHash: string) {
    return prisma.refreshToken.findUnique({
      where: { tokenHash },
      include: { user: { include: { role: true, artistProfile: true } } }
    });
  }

  revokeRefreshToken(tokenHash: string) {
    return prisma.refreshToken.updateMany({
      where: { tokenHash },
      data: { revokedAt: new Date() }
    });
  }

  saveTotpSecret(userId: bigint, secret: string) {
    return prisma.user.update({
      where: { id: userId },
      data: { totpSecret: secret, totpEnabled: false }
    });
  }

  enableTotp(userId: bigint) {
    return prisma.user.update({
      where: { id: userId },
      data: { totpEnabled: true }
    });
  }

  disableTotp(userId: bigint) {
    return prisma.user.update({
      where: { id: userId },
      data: { totpEnabled: false, totpSecret: null }
    });
  }
}

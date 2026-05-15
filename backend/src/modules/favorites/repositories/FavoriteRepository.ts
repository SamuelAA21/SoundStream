import { prisma } from "../../../config/prisma.js";

export class FavoriteRepository {
  add(userId: bigint, songId: bigint) {
    return prisma.favorite.create({
      data: { userId, songId }
    });
  }

  remove(userId: bigint, songId: bigint) {
    return prisma.favorite.deleteMany({
      where: { userId, songId }
    });
  }

  list(userId: bigint) {
    return prisma.favorite.findMany({
      where: { userId },
      include: {
        song: {
          include: { artist: true, album: true, genre: true }
        }
      },
      orderBy: { createdAt: "desc" }
    });
  }
}

import { prisma } from "../../../config/prisma.js";

export class FavoriteRepository {
  add(userId: bigint, songId: bigint) {
    return prisma.favorite.create({
      data: { userId, songId }
    });
  }

  findSong(songId: bigint) {
    return prisma.song.findFirst({
      where: {
        id: songId,
        isActive: true,
        audioFile: { isAvailable: true }
      },
      include: {
        artist: true,
        album: true,
        genre: true,
        collaborators: { include: { artist: true } }
      }
    });
  }

  remove(userId: bigint, songId: bigint) {
    return prisma.favorite.deleteMany({
      where: { userId, songId }
    });
  }

  list(userId: bigint) {
    return prisma.favorite.findMany({
      where: {
        userId,
        song: {
          isActive: true,
          audioFile: { isAvailable: true }
        }
      },
      include: {
        song: {
          include: {
            artist: true,
            album: true,
            genre: true,
            collaborators: { include: { artist: true } }
          }
        }
      },
      orderBy: { createdAt: "desc" }
    });
  }
}

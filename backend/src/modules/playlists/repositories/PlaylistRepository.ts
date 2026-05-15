import { prisma } from "../../../config/prisma.js";

export class PlaylistRepository {
  create(input: { userId: bigint; name: string; description?: string; isPublic: boolean }) {
    return prisma.playlist.create({
      data: input,
      include: { songs: true }
    });
  }

  listByUser(userId: bigint) {
    return prisma.playlist.findMany({
      where: { userId },
      include: { songs: true },
      orderBy: { createdAt: "desc" }
    });
  }

  findOwned(input: { playlistId: bigint; userId: bigint }) {
    return prisma.playlist.findFirst({
      where: { id: input.playlistId, userId: input.userId },
      include: {
        songs: {
          include: {
            song: {
              include: { artist: true, album: true, genre: true }
            }
          },
          orderBy: { position: "asc" }
        }
      }
    });
  }

  findSong(songId: bigint) {
    return prisma.song.findFirst({
      where: {
        id: songId,
        isActive: true,
        audioFile: { isAvailable: true }
      }
    });
  }

  async nextPosition(playlistId: bigint) {
    const last = await prisma.playlistSong.findFirst({
      where: { playlistId },
      orderBy: { position: "desc" }
    });
    return (last?.position ?? 0) + 1;
  }

  addSong(input: { playlistId: bigint; songId: bigint; position: number }) {
    return prisma.playlistSong.create({
      data: input
    });
  }

  removeSong(input: { playlistId: bigint; songId: bigint }) {
    return prisma.playlistSong.deleteMany({
      where: input
    });
  }
}

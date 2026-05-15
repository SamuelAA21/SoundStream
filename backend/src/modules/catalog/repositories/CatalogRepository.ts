import { prisma } from "../../../config/prisma.js";

export class CatalogRepository {
  listSongs(input: { query?: string; skip: number; limit: number }) {
    return prisma.song.findMany({
      where: {
        isActive: true,
        audioFile: { isAvailable: true },
        OR: input.query
          ? [
              { title: { contains: input.query, mode: "insensitive" } },
              { artist: { name: { contains: input.query, mode: "insensitive" } } },
              { genre: { name: { contains: input.query, mode: "insensitive" } } }
            ]
          : undefined
      },
      include: { artist: true, album: true, genre: true, collaborators: { include: { artist: true } } },
      orderBy: { title: "asc" },
      skip: input.skip,
      take: input.limit
    });
  }

  findSong(songId: bigint) {
    return prisma.song.findFirst({
      where: { id: songId, isActive: true },
      include: { artist: true, album: true, genre: true, audioFile: true, collaborators: { include: { artist: true } } }
    });
  }

  listAlbums() {
    return prisma.album.findMany({
      include: {
        artist: true,
        genre: true,
        _count: { select: { songs: true } }
      },
      orderBy: { title: "asc" }
    });
  }

  findAlbum(albumId: bigint) {
    return prisma.album.findUnique({
      where: { id: albumId },
      include: {
        artist: true,
        genre: true,
        songs: {
          where: { isActive: true },
          include: { artist: true, genre: true, collaborators: { include: { artist: true } } },
          orderBy: { title: "asc" }
        }
      }
    });
  }
}

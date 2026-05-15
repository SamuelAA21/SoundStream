import { prisma } from "../../../config/prisma.js";

export class AdminAlbumRepository {
  async findOrCreateArtist(name: string) {
    const existing = await prisma.artist.findFirst({ where: { name } });
    if (existing) return existing;
    return prisma.artist.create({ data: { name } });
  }

  findOrCreateGenre(name: string) {
    return prisma.genre.upsert({
      where: { name },
      update: {},
      create: { name }
    });
  }

  findSongs(songIds: bigint[]) {
    return prisma.song.findMany({
      where: {
        id: { in: songIds },
        isActive: true,
        audioFile: { isAvailable: true }
      },
      include: { artist: true, genre: true, album: true }
    });
  }

  findSong(songId: bigint) {
    return prisma.song.findFirst({
      where: {
        id: songId,
        isActive: true,
        audioFile: { isAvailable: true }
      },
      include: { artist: true, genre: true, album: true }
    });
  }

  findAlbum(albumId: bigint) {
    return prisma.album.findUnique({
      where: { id: albumId },
      include: { artist: true, genre: true, songs: true }
    });
  }

  updateSongAlbum(input: {
    songId: bigint;
    albumId: bigint | null;
    artistId?: bigint;
    genreId?: bigint;
  }) {
    return prisma.song.update({
      where: { id: input.songId },
      data: {
        albumId: input.albumId,
        artistId: input.artistId,
        genreId: input.genreId
      },
      include: { artist: true, album: true, genre: true }
    });
  }

  createAlbumFromSongs(input: {
    title: string;
    artistId: bigint;
    genreId: bigint;
    songIds: bigint[];
  }) {
    return prisma.$transaction(async (tx) => {
      const album = await tx.album.create({
        data: {
          title: input.title,
          artistId: input.artistId,
          genreId: input.genreId
        }
      });

      if (input.songIds.length > 0) {
        await tx.song.updateMany({
          where: { id: { in: input.songIds } },
          data: { albumId: album.id }
        });
      }

      return tx.album.findUniqueOrThrow({
        where: { id: album.id },
        include: {
          artist: true,
          genre: true,
          songs: {
            include: { artist: true, genre: true },
            orderBy: { title: "asc" }
          }
        }
      });
    });
  }
}

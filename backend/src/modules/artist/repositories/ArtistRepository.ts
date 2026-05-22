import { prisma } from "../../../config/prisma.js";

export class ArtistRepository {
  findProfileByUser(userId: bigint) {
    return prisma.artist.findUnique({ where: { ownerUserId: userId } });
  }

  findOrCreateGenre(name: string) {
    return prisma.genre.upsert({
      where: { name },
      update: {},
      create: { name }
    });
  }

  async findOrCreateCollaborator(name: string) {
    const existing = await prisma.artist.findFirst({ where: { name } });
    if (existing) return existing;
    return prisma.artist.create({ data: { name } });
  }

  findAudioByChecksum(checksumSha256: string) {
    return prisma.audioFile.findUnique({
      where: { checksumSha256 },
      include: { song: { include: { artist: true } } }
    });
  }

  createSong(input: {
    artistId: bigint;
    genreId: bigint;
    title: string;
    durationSeconds: number;
    storagePath: string;
    mimeType: string;
    fileSizeBytes: bigint;
    checksumSha256: string;
    collaboratorIds: bigint[];
  }) {
    return prisma.song.create({
      data: {
        title: input.title,
        artistId: input.artistId,
        genreId: input.genreId,
        durationSeconds: input.durationSeconds,
        collaborators: {
          create: input.collaboratorIds.map((artistId) => ({
            artistId,
            role: "featured"
          }))
        },
        audioFile: {
          create: {
            storagePath: input.storagePath,
            mimeType: input.mimeType,
            fileSizeBytes: input.fileSizeBytes,
            durationSeconds: input.durationSeconds,
            checksumSha256: input.checksumSha256,
            isAvailable: true
          }
        }
      },
      include: {
        artist: true,
        album: true,
        genre: true,
        audioFile: true,
        collaborators: { include: { artist: true } }
      }
    });
  }

  listOwnSongs(artistId: bigint) {
    return prisma.song.findMany({
      where: { artistId },
      include: {
        artist: true,
        album: true,
        genre: true,
        audioFile: true,
        collaborators: { include: { artist: true } }
      },
      orderBy: { createdAt: "desc" }
    });
  }

  listOwnAlbums(artistId: bigint) {
    return prisma.album.findMany({
      where: { artistId },
      include: {
        artist: true,
        genre: true,
        _count: { select: { songs: true } }
      },
      orderBy: { title: "asc" }
    });
  }

  setOwnSongPublication(artistId: bigint, songId: bigint, isPublished: boolean) {
    return prisma.$transaction(async (tx) => {
      const song = await tx.song.findFirst({
        where: { id: songId, artistId },
        include: { audioFile: true }
      });

      if (!song) return null;

      await tx.song.update({
        where: { id: song.id },
        data: { isActive: isPublished }
      });

      if (song.audioFile) {
        await tx.audioFile.update({
          where: { songId: song.id },
          data: { isAvailable: isPublished }
        });
      }

      return tx.song.findUniqueOrThrow({
        where: { id: song.id },
        include: {
          artist: true,
          album: true,
          genre: true,
          audioFile: true,
          collaborators: { include: { artist: true } }
        }
      });
    });
  }

  removeOwnSong(artistId: bigint, songId: bigint) {
    return prisma.$transaction(async (tx) => {
      const song = await tx.song.findFirst({
        where: { id: songId, artistId },
        include: { audioFile: true }
      });

      if (!song) return null;

      await tx.song.update({
        where: { id: song.id },
        data: { isActive: false, albumId: null }
      });

      if (song.audioFile) {
        await tx.audioFile.update({
          where: { songId: song.id },
          data: { isAvailable: false }
        });
      }

      return song;
    });
  }

  reactivateOwnSongFromAudio(input: {
    songId: bigint;
    artistId: bigint;
    genreId: bigint;
    title: string;
    durationSeconds: number;
    collaboratorIds: bigint[];
  }) {
    return prisma.$transaction(async (tx) => {
      await tx.songCollaborator.deleteMany({ where: { songId: input.songId } });
      await tx.song.update({
        where: { id: input.songId },
        data: {
          title: input.title,
          artistId: input.artistId,
          genreId: input.genreId,
          durationSeconds: input.durationSeconds,
          albumId: null,
          isActive: true,
          collaborators: {
            create: input.collaboratorIds.map((artistId) => ({
              artistId,
              role: "featured"
            }))
          }
        }
      });
      await tx.audioFile.update({
        where: { songId: input.songId },
        data: {
          durationSeconds: input.durationSeconds,
          isAvailable: true
        }
      });

      return tx.song.findUniqueOrThrow({
        where: { id: input.songId },
        include: {
          artist: true,
          album: true,
          genre: true,
          audioFile: true,
          collaborators: { include: { artist: true } }
        }
      });
    });
  }

  findOwnSongs(artistId: bigint, songIds: bigint[]) {
    return prisma.song.findMany({
      where: { id: { in: songIds }, artistId, isActive: true, audioFile: { isAvailable: true } },
      include: { genre: true }
    });
  }

  findOwnSongWithRelations(artistId: bigint, songId: bigint) {
    return prisma.song.findFirst({
      where: { id: songId, artistId, isActive: true },
      include: {
        artist: true,
        album: true,
        genre: true,
        audioFile: true,
        collaborators: { include: { artist: true } }
      }
    });
  }

  findOwnedAlbum(artistId: bigint, albumId: bigint) {
    return prisma.album.findFirst({
      where: { id: albumId, artistId },
      include: { artist: true, genre: true, songs: true }
    });
  }

  updateOwnSongAlbum(input: {
    artistId: bigint;
    songId: bigint;
    albumId: bigint | null;
    genreId?: bigint;
  }) {
    return prisma.song.updateMany({
      where: { id: input.songId, artistId: input.artistId },
      data: {
        albumId: input.albumId,
        genreId: input.genreId
      }
    });
  }

  createAlbum(input: { artistId: bigint; genreId: bigint; title: string; songIds: bigint[] }) {
    return prisma.$transaction(async (tx) => {
      const album = await tx.album.create({
        data: {
          artistId: input.artistId,
          genreId: input.genreId,
          title: input.title
        }
      });

      if (input.songIds.length > 0) {
        await tx.song.updateMany({
          where: { id: { in: input.songIds }, artistId: input.artistId },
          data: { albumId: album.id }
        });
      }

      return tx.album.findUniqueOrThrow({
        where: { id: album.id },
        include: { artist: true, genre: true, songs: { include: { artist: true, genre: true } } }
      });
    });
  }
}

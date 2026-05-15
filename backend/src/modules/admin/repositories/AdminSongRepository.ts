import { prisma } from "../../../config/prisma.js";

export class AdminSongRepository {
  findOrCreateGenre(name: string) {
    return prisma.genre.upsert({
      where: { name },
      update: {},
      create: { name }
    });
  }

  async findOrCreateArtist(name: string) {
    const existing = await prisma.artist.findFirst({ where: { name } });
    if (existing) return existing;
    return prisma.artist.create({ data: { name } });
  }

  findAlbum(albumId: bigint) {
    return prisma.album.findUnique({
      where: { id: albumId },
      include: { artist: true, genre: true }
    });
  }

  findSong(songId: bigint) {
    return prisma.song.findFirst({
      where: { id: songId, isActive: true },
      include: { artist: true, album: true, genre: true }
    });
  }

  findAnySong(songId: bigint) {
    return prisma.song.findUnique({
      where: { id: songId },
      include: { artist: true, album: true, genre: true, audioFile: true }
    });
  }

  findAudioFileByChecksum(checksumSha256: string) {
    return prisma.audioFile.findUnique({
      where: { checksumSha256 },
      include: {
        song: {
          include: { artist: true, album: true, genre: true, audioFile: true }
        }
      }
    });
  }

  updateSongAlbum(input: { songId: bigint; albumId: bigint | null; artistId?: bigint; genreId?: bigint }) {
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

  deactivateSong(songId: bigint) {
    return prisma.song.update({
      where: { id: songId },
      data: {
        isActive: false,
        audioFile: {
          update: {
            isAvailable: false
          }
        }
      },
      include: { artist: true, album: true, genre: true, audioFile: true }
    });
  }

  reactivateSongFromAudio(input: {
    songId: bigint;
    title: string;
    artistId: bigint;
    genreId: bigint;
    durationSeconds: number;
    storagePath: string;
    mimeType: string;
    fileSizeBytes: bigint;
    checksumSha256: string;
  }) {
    return prisma.song.update({
      where: { id: input.songId },
      data: {
        title: input.title,
        artistId: input.artistId,
        genreId: input.genreId,
        albumId: null,
        durationSeconds: input.durationSeconds,
        isActive: true,
        audioFile: {
          update: {
            storagePath: input.storagePath,
            mimeType: input.mimeType,
            fileSizeBytes: input.fileSizeBytes,
            durationSeconds: input.durationSeconds,
            checksumSha256: input.checksumSha256,
            isAvailable: true
          }
        }
      },
      include: { artist: true, album: true, genre: true, audioFile: true }
    });
  }

  createSongWithAudio(input: {
    title: string;
    artistId: bigint;
    genreId: bigint;
    durationSeconds: number;
    storagePath: string;
    mimeType: string;
    fileSizeBytes: bigint;
    checksumSha256: string;
  }) {
    return prisma.song.create({
      data: {
        title: input.title,
        artistId: input.artistId,
        genreId: input.genreId,
        durationSeconds: input.durationSeconds,
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
        audioFile: true
      }
    });
  }
}

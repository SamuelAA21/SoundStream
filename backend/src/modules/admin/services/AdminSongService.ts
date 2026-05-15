import { createHash, randomUUID } from "node:crypto";
import { createWriteStream, existsSync, mkdirSync, unlinkSync } from "node:fs";
import path from "node:path";
import { pipeline } from "node:stream/promises";
import type { MultipartFile } from "@fastify/multipart";
import { Prisma } from "@prisma/client";
import { env } from "../../../config/env.js";
import { AppError } from "../../../utils/AppError.js";
import { AdminSongRepository } from "../repositories/AdminSongRepository.js";

const repository = new AdminSongRepository();
const allowedMimeTypes = new Set(["audio/mpeg", "audio/mp3", "audio/wav", "audio/ogg"]);

export class AdminSongService {
  async uploadSong(input: {
    fields: Record<string, string>;
    file: MultipartFile;
  }) {
    const title = this.required(input.fields.title, "title");
    const artistName = this.required(input.fields.artistName, "artistName");
    const genreName = this.required(input.fields.genreName, "genreName");
    const durationSeconds = Number(input.fields.durationSeconds);

    if (!Number.isInteger(durationSeconds) || durationSeconds <= 0) {
      throw new AppError(422, "invalid_duration", "durationSeconds must be a positive integer");
    }

    if (!allowedMimeTypes.has(input.file.mimetype)) {
      throw new AppError(422, "invalid_audio_type", "Only MP3, WAV or OGG files are allowed");
    }

    const audioRoot = path.resolve(env.AUDIO_STORAGE_PATH);
    if (!existsSync(audioRoot)) mkdirSync(audioRoot, { recursive: true });

    const extension = this.extensionFor(input.file.filename, input.file.mimetype);
    const storagePath = `${randomUUID()}${extension}`;
    const absolutePath = path.join(audioRoot, storagePath);
    const hash = createHash("sha256");
    let size = 0n;

    input.file.file.on("data", (chunk: Buffer) => {
      size += BigInt(chunk.length);
      hash.update(chunk);
    });

    await pipeline(input.file.file, createWriteStream(absolutePath));

    try {
      const genre = await repository.findOrCreateGenre(genreName);
      const artist = await repository.findOrCreateArtist(artistName);
      const checksumSha256 = hash.digest("hex");
      const existingAudio = await repository.findAudioFileByChecksum(checksumSha256);

      if (existingAudio?.song.isActive) {
        throw new AppError(409, "duplicate_audio_file", "This audio file is already registered");
      }

      if (existingAudio?.song && !existingAudio.song.isActive) {
        const song = await repository.reactivateSongFromAudio({
          songId: existingAudio.songId,
          title,
          artistId: artist.id,
          genreId: genre.id,
          durationSeconds,
          storagePath,
          mimeType: this.normalizeMimeType(input.file.mimetype),
          fileSizeBytes: size,
          checksumSha256
        });

        return {
          id: song.id.toString(),
          title: song.title,
          artist: song.artist.name,
          album: null,
          genre: song.genre.name,
          durationSeconds: song.durationSeconds,
          audioAvailable: song.audioFile?.isAvailable ?? false,
          restored: true
        };
      }

      const song = await repository.createSongWithAudio({
        title,
        artistId: artist.id,
        genreId: genre.id,
        durationSeconds,
        storagePath,
        mimeType: this.normalizeMimeType(input.file.mimetype),
        fileSizeBytes: size,
        checksumSha256
      });

      return {
        id: song.id.toString(),
        title: song.title,
        artist: song.artist.name,
        album: null,
        genre: song.genre.name,
        durationSeconds: song.durationSeconds,
        audioAvailable: song.audioFile?.isAvailable ?? false
      };
    } catch (error) {
      if (existsSync(absolutePath)) unlinkSync(absolutePath);
      if (error instanceof AppError) {
        throw error;
      }
      if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === "P2002") {
        throw new AppError(409, "duplicate_audio_file", "This audio file is already registered");
      }
      throw error;
    }
  }

  async assignSongToAlbum(input: { songId: string; albumId: string | null }) {
    const song = await repository.findSong(BigInt(input.songId));
    if (!song) {
      throw new AppError(404, "song_not_found", "Song was not found");
    }

    if (!input.albumId) {
      const updated = await repository.updateSongAlbum({ songId: song.id, albumId: null });
      return this.toSongDto(updated);
    }

    const album = await repository.findAlbum(BigInt(input.albumId));
    if (!album) {
      throw new AppError(404, "album_not_found", "Album was not found");
    }

    const updated = await repository.updateSongAlbum({
      songId: song.id,
      albumId: album.id,
      artistId: album.artistId,
      genreId: album.genreId ?? song.genreId
    });

    return this.toSongDto(updated);
  }

  async deleteSong(songId: string) {
    const song = await repository.findAnySong(BigInt(songId));
    if (!song || !song.isActive) {
      throw new AppError(404, "song_not_found", "Song was not found");
    }

    const updated = await repository.deactivateSong(song.id);
    return {
      ...this.toSongDto(updated),
      isActive: updated.isActive,
      audioAvailable: updated.audioFile?.isAvailable ?? false
    };
  }

  private required(value: string | undefined, field: string) {
    const trimmed = value?.trim();
    if (!trimmed) throw new AppError(422, "missing_field", `${field} is required`);
    return trimmed;
  }

  private extensionFor(filename: string, mimetype: string) {
    const extension = path.extname(filename).toLowerCase();
    if (extension) return extension;
    if (mimetype === "audio/wav") return ".wav";
    if (mimetype === "audio/ogg") return ".ogg";
    return ".mp3";
  }

  private normalizeMimeType(mimetype: string) {
    return mimetype === "audio/mp3" ? "audio/mpeg" : mimetype;
  }

  private toSongDto(song: { id: bigint; title: string; artist: { name: string }; album: { title: string } | null; genre: { name: string }; durationSeconds: number }) {
    return {
      id: song.id.toString(),
      title: song.title,
      artist: song.artist.name,
      album: song.album?.title ?? null,
      genre: song.genre.name,
      durationSeconds: song.durationSeconds
    };
  }
}

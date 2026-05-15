import { createHash, randomUUID } from "node:crypto";
import { createWriteStream, existsSync, mkdirSync, unlinkSync } from "node:fs";
import path from "node:path";
import { pipeline } from "node:stream/promises";
import type { MultipartFile } from "@fastify/multipart";
import { env } from "../../../config/env.js";
import { AppError } from "../../../utils/AppError.js";
import { ArtistRepository } from "../repositories/ArtistRepository.js";

const repository = new ArtistRepository();
const allowedMimeTypes = new Set(["audio/mpeg", "audio/mp3", "audio/wav", "audio/ogg"]);

export class ArtistService {
  async listMySongs(userId: string) {
    const profile = await this.getProfile(userId);
    const songs = await repository.listOwnSongs(profile.id);
    return songs.map((song) => this.toSongDto(song));
  }

  async uploadSong(input: { userId: string; fields: Record<string, string>; file: MultipartFile }) {
    const profile = await this.getProfile(input.userId);
    const title = this.required(input.fields.title, "title");
    const genreName = this.required(input.fields.genreName, "genreName");
    const durationSeconds = Number(input.fields.durationSeconds);
    const collaboratorNames = (input.fields.collaboratorNames ?? "")
      .split(",")
      .map((name) => name.trim())
      .filter(Boolean);

    if (!Number.isInteger(durationSeconds) || durationSeconds <= 0) {
      throw new AppError(422, "invalid_duration", "durationSeconds must be a positive integer");
    }

    if (!allowedMimeTypes.has(input.file.mimetype)) {
      throw new AppError(422, "invalid_audio_type", "Only MP3, WAV or OGG files are allowed");
    }

    const audioRoot = path.resolve(env.AUDIO_STORAGE_PATH);
    if (!existsSync(audioRoot)) mkdirSync(audioRoot, { recursive: true });

    const extension = path.extname(input.file.filename).toLowerCase() || ".mp3";
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
      const checksumSha256 = hash.digest("hex");
      const existingAudio = await repository.findAudioByChecksum(checksumSha256);
      if (existingAudio?.song.isActive) {
        throw new AppError(409, "duplicate_audio_file", "This audio file is already registered");
      }

      const genre = await repository.findOrCreateGenre(genreName);
      const collaborators = await Promise.all(
        collaboratorNames
          .filter((name) => name.toLowerCase() !== profile.name.toLowerCase())
          .map((name) => repository.findOrCreateCollaborator(name))
      );

      if (existingAudio) {
        if (existingAudio.song.artistId !== profile.id) {
          throw new AppError(409, "duplicate_audio_file", "This audio file belongs to another artist");
        }

        if (existsSync(absolutePath)) unlinkSync(absolutePath);
        const song = await repository.reactivateOwnSongFromAudio({
          songId: existingAudio.song.id,
          artistId: profile.id,
          genreId: genre.id,
          title,
          durationSeconds,
          collaboratorIds: collaborators.map((artist) => artist.id)
        });

        return this.toSongDto(song);
      }

      const song = await repository.createSong({
        artistId: profile.id,
        genreId: genre.id,
        title,
        durationSeconds,
        storagePath,
        mimeType: input.file.mimetype === "audio/mp3" ? "audio/mpeg" : input.file.mimetype,
        fileSizeBytes: size,
        checksumSha256,
        collaboratorIds: collaborators.map((artist) => artist.id)
      });

      return this.toSongDto(song);
    } catch (error) {
      if (existsSync(absolutePath)) unlinkSync(absolutePath);
      throw error;
    }
  }

  async publishSong(input: { userId: string; songId: string; isPublished: boolean }) {
    const profile = await this.getProfile(input.userId);
    const song = await repository.setOwnSongPublication(profile.id, BigInt(input.songId), input.isPublished);
    if (!song) {
      throw new AppError(404, "song_not_found", "Song was not found for this artist");
    }

    return this.toSongDto(song);
  }

  async deleteSong(input: { userId: string; songId: string }) {
    const profile = await this.getProfile(input.userId);
    const song = await repository.removeOwnSong(profile.id, BigInt(input.songId));
    if (!song) {
      throw new AppError(404, "song_not_found", "Song was not found for this artist");
    }

    return { ok: true };
  }

  async createAlbum(input: { userId: string; title: string; genreName?: string; songIds: string[] }) {
    const profile = await this.getProfile(input.userId);
    const title = input.title.trim();
    const songIds = [...new Set(input.songIds)].map((id) => BigInt(id));

    if (title.length < 2) {
      throw new AppError(422, "invalid_album_title", "Album title must have at least 2 characters");
    }

    const songs = songIds.length > 0 ? await repository.findOwnSongs(profile.id, songIds) : [];
    if (songs.length !== songIds.length) {
      throw new AppError(422, "invalid_album_songs", "All album songs must belong to your artist profile");
    }

    const genreName = input.genreName?.trim();
    const genre = genreName
      ? await repository.findOrCreateGenre(genreName)
      : songs.length > 0
        ? songs[0].genre
        : await repository.findOrCreateGenre("Uncategorized");

    const album = await repository.createAlbum({
      artistId: profile.id,
      genreId: genre.id,
      title,
      songIds
    });

    return {
      id: album.id.toString(),
      title: album.title,
      artist: album.artist.name,
      genre: album.genre?.name ?? null,
      songCount: album.songs.length
    };
  }

  async assignSongToAlbum(input: { userId: string; songId: string; albumId?: string | null }) {
    const profile = await this.getProfile(input.userId);
    const song = await repository.findOwnSongWithRelations(profile.id, BigInt(input.songId));
    if (!song) {
      throw new AppError(404, "song_not_found", "Song was not found for this artist");
    }

    let targetAlbumId: bigint | null = null;
    let targetGenreId: bigint | undefined;

    if (input.albumId) {
      const album = await repository.findOwnedAlbum(profile.id, BigInt(input.albumId));
      if (!album) {
        throw new AppError(404, "album_not_found", "Album was not found for this artist");
      }
      targetAlbumId = album.id;
      targetGenreId = album.genreId ?? song.genre.id;
    }

    const updatedRows = await repository.updateOwnSongAlbum({
      artistId: profile.id,
      songId: song.id,
      albumId: targetAlbumId,
      genreId: targetGenreId
    });

    if (updatedRows.count === 0) {
      throw new AppError(404, "song_not_found", "Song was not found for this artist");
    }

    const updated = await repository.findOwnSongWithRelations(profile.id, song.id);
    return this.toSongDto(updated);
  }

  private async getProfile(userId: string) {
    const profile = await repository.findProfileByUser(BigInt(userId));
    if (!profile) {
      throw new AppError(404, "artist_profile_not_found", "Artist profile was not found");
    }
    return profile;
  }

  private required(value: string | undefined, field: string) {
    const trimmed = value?.trim();
    if (!trimmed) throw new AppError(422, "missing_field", `${field} is required`);
    return trimmed;
  }

  private toSongDto(song: any) {
    return {
      id: song.id.toString(),
      title: song.title,
      artist: song.artist.name,
      album: song.album?.title ?? null,
      genre: song.genre.name,
      durationSeconds: song.durationSeconds,
      isPublished: Boolean(song.isActive && song.audioFile?.isAvailable),
      collaborators: song.collaborators?.map((item: any) => ({
        id: item.artist.id.toString(),
        name: item.artist.name,
        role: item.role
      })) ?? []
    };
  }
}

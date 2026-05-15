import { createReadStream, statSync } from "node:fs";
import path from "node:path";
import { env } from "../../../config/env.js";
import { AppError } from "../../../utils/AppError.js";
import { parseRange } from "../../../utils/range.js";
import { StreamingRepository } from "../repositories/StreamingRepository.js";

const repository = new StreamingRepository();

export class StreamingService {
  async prepareStream(input: { userId: string; songId: string; range?: string }) {
    const song = await repository.findStreamableSong(BigInt(input.songId));
    if (!song || !song.audioFile) {
      throw new AppError(404, "audio_not_found", "Audio file was not found");
    }

    const root = path.resolve(env.AUDIO_STORAGE_PATH);
    const filePath = path.resolve(root, song.audioFile.storagePath);
    if (!filePath.startsWith(root)) {
      throw new AppError(403, "access_denied", "Invalid audio path");
    }

    let stat;
    try {
      stat = statSync(filePath);
    } catch {
      throw new AppError(503, "audio_unavailable", "Audio file is unavailable");
    }

    const range = parseRange(input.range, stat.size);
    await repository.registerPlayInteraction(BigInt(input.userId), song.id, input.range);

    return {
      filePath,
      mimeType: song.audioFile.mimeType,
      fileSize: stat.size,
      range,
      stream: createReadStream(filePath, { start: range.start, end: range.end, highWaterMark: 64 * 1024 })
    };
  }
}

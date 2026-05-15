import { AppError } from "./AppError.js";

export type ByteRange = {
  start: number;
  end: number;
  length: number;
  isPartial: boolean;
};

export function parseRange(rangeHeader: string | undefined, fileSize: number): ByteRange {
  if (!rangeHeader) {
    return { start: 0, end: fileSize - 1, length: fileSize, isPartial: false };
  }

  const match = /^bytes=(\d*)-(\d*)$/.exec(rangeHeader);
  if (!match) {
    throw new AppError(416, "invalid_range", "Invalid Range header");
  }

  const [, rawStart, rawEnd] = match;
  const start = rawStart === "" ? 0 : Number(rawStart);
  const end = rawEnd === "" ? fileSize - 1 : Number(rawEnd);

  if (!Number.isInteger(start) || !Number.isInteger(end) || start < 0 || end >= fileSize || start > end) {
    throw new AppError(416, "invalid_range", "Requested range is not satisfiable");
  }

  return { start, end, length: end - start + 1, isPartial: true };
}

import { prisma } from "../../../config/prisma.js";

export class StreamingRepository {
  findStreamableSong(songId: bigint) {
    return prisma.song.findFirst({
      where: {
        id: songId,
        isActive: true,
        audioFile: { isAvailable: true }
      },
      include: { audioFile: true }
    });
  }

  registerPlayInteraction(userId: bigint, songId: bigint, range?: string) {
    return prisma.userInteraction.create({
      data: {
        userId,
        songId,
        interactionType: "play",
        metadataJson: { range } as any
      }
    });
  }
}

import { prisma } from "../../../config/prisma.js";

export class HistoryRepository {
  registerPlay(input: {
    userId: bigint;
    songId: bigint;
    playedSeconds: number;
    completionRate: number;
    deviceType: "web" | "android";
  }) {
    return prisma.playHistory.create({
      data: {
        userId: input.userId,
        songId: input.songId,
        startedAt: new Date(),
        endedAt: new Date(),
        playedSeconds: input.playedSeconds,
        completionRate: input.completionRate,
        deviceType: input.deviceType
      }
    });
  }

  registerInteraction(input: {
    userId: bigint;
    songId?: bigint;
    interactionType: string;
    interactionValue?: string;
    metadata?: unknown;
  }) {
    return prisma.userInteraction.create({
      data: {
        userId: input.userId,
        songId: input.songId,
        interactionType: input.interactionType as any,
        interactionValue: input.interactionValue,
        metadataJson: input.metadata as any
      }
    });
  }

  list(userId: bigint) {
    return prisma.playHistory.findMany({
      where: { userId },
      include: { song: { include: { artist: true, genre: true } } },
      orderBy: { startedAt: "desc" },
      take: 50
    });
  }
}

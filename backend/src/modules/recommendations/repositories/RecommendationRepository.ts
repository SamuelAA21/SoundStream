import { prisma } from "../../../config/prisma.js";

export class RecommendationRepository {
  getActive(userId: bigint) {
    return prisma.recommendation.findMany({
      where: {
        userId,
        OR: [{ expiresAt: null }, { expiresAt: { gt: new Date() } }]
      },
      include: { song: { include: { artist: true, genre: true, album: true } } },
      orderBy: { score: "desc" },
      take: 20
    });
  }

  async buildSignals(userId: bigint) {
    const [history, favorites, interactions] = await Promise.all([
      prisma.playHistory.findMany({ where: { userId }, include: { song: true }, take: 100 }),
      prisma.favorite.findMany({ where: { userId }, include: { song: true } }),
      prisma.userInteraction.findMany({ where: { userId }, include: { song: true }, take: 100 })
    ]);

    const byGenreArtist = new Map<string, { genreId: bigint; artistId: bigint; playCount: number; favoriteCount: number; interactionCount: number }>();
    const ensure = (genreId: bigint, artistId: bigint) => {
      const key = `${genreId}:${artistId}`;
      if (!byGenreArtist.has(key)) {
        byGenreArtist.set(key, { genreId, artistId, playCount: 0, favoriteCount: 0, interactionCount: 0 });
      }
      return byGenreArtist.get(key)!;
    };

    history.forEach((row) => ensure(row.song.genreId, row.song.artistId).playCount += 1);
    favorites.forEach((row) => ensure(row.song.genreId, row.song.artistId).favoriteCount += 1);
    interactions.forEach((row) => {
      if (row.song) ensure(row.song.genreId, row.song.artistId).interactionCount += 1;
    });

    return [...byGenreArtist.values()];
  }

  async selectCandidates(userId: bigint) {
    const consumed = await prisma.playHistory.findMany({
      where: { userId },
      select: { songId: true }
    });
    const consumedIds = consumed.map((item) => item.songId);

    return prisma.song.findMany({
      where: {
        isActive: true,
        id: { notIn: consumedIds },
        audioFile: { isAvailable: true }
      },
      select: {
        id: true,
        title: true,
        genreId: true,
        artistId: true
      },
      take: 200
    });
  }

  async replaceForUser(userId: bigint, items: { songId: bigint; score: number; reasonText: string }[]) {
    const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);
    await prisma.$transaction([
      prisma.recommendation.deleteMany({ where: { userId } }),
      prisma.recommendation.createMany({
        data: items.slice(0, 20).map((item) => ({
          userId,
          songId: item.songId,
          score: item.score,
          source: "hybrid",
          reasonText: item.reasonText,
          expiresAt
        }))
      })
    ]);
  }
}

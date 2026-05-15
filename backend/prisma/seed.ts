import bcrypt from "bcryptjs";
import { createHash } from "node:crypto";
import "../src/config/loadEnv.js";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

function checksum(value: string) {
  return createHash("sha256").update(value).digest("hex");
}

async function main() {
  const adminRole = await prisma.role.upsert({
    where: { name: "admin" },
    update: {},
    create: { name: "admin", description: "Administrador del catalogo" }
  });

  const userRole = await prisma.role.upsert({
    where: { name: "user" },
    update: {},
    create: { name: "user", description: "Usuario registrado" }
  });

  const artistRole = await prisma.role.upsert({
    where: { name: "artist" },
    update: {},
    create: { name: "artist", description: "Artista creador de contenido musical" }
  });

  await prisma.user.upsert({
    where: { email: "admin@soundstream.local" },
    update: {
      roleId: adminRole.id,
      name: "Admin SoundStream",
      passwordHash: await bcrypt.hash("Admin12345", 12),
      status: "active"
    },
    create: {
      roleId: adminRole.id,
      name: "Admin SoundStream",
      email: "admin@soundstream.local",
      passwordHash: await bcrypt.hash("Admin12345", 12)
    }
  });

  const artistUser = await prisma.user.upsert({
    where: { email: "artist@soundstream.local" },
    update: {
      roleId: artistRole.id,
      name: "Artista Demo",
      passwordHash: await bcrypt.hash("Artist12345", 12),
      status: "active"
    },
    create: {
      roleId: artistRole.id,
      name: "Artista Demo",
      email: "artist@soundstream.local",
      passwordHash: await bcrypt.hash("Artist12345", 12)
    }
  });

  await prisma.artist.upsert({
    where: { ownerUserId: artistUser.id },
    update: {
      name: "Artista Demo"
    },
    create: {
      ownerUserId: artistUser.id,
      name: "Artista Demo"
    }
  });

  await prisma.user.upsert({
    where: { email: "demo@soundstream.local" },
    update: {
      roleId: userRole.id,
      name: "Usuario Demo",
      passwordHash: await bcrypt.hash("Demo12345", 12),
      status: "active"
    },
    create: {
      roleId: userRole.id,
      name: "Usuario Demo",
      email: "demo@soundstream.local",
      passwordHash: await bcrypt.hash("Demo12345", 12)
    }
  });

  const genre = await prisma.genre.upsert({
    where: { name: "Electronic" },
    update: {},
    create: { name: "Electronic", description: "Musica electronica y sintetica" }
  });

  const artist =
    (await prisma.artist.findFirst({
      where: { name: "SoundStream Lab", country: "CO" }
    })) ??
    (await prisma.artist.create({
      data: {
        name: "SoundStream Lab",
        country: "CO"
      }
    }));

  const album =
    (await prisma.album.findFirst({
      where: { artistId: artist.id, title: "V1 Sessions" }
    })) ??
    (await prisma.album.create({
      data: {
        artistId: artist.id,
        genreId: genre.id,
        title: "V1 Sessions"
      }
    }));

  const existingSong = await prisma.song.findFirst({
    where: { artistId: artist.id, title: "Demo Track" }
  });

  const song = existingSong
    ? await prisma.song.update({
        where: { id: existingSong.id },
        data: {
          albumId: album.id,
          genreId: genre.id,
          durationSeconds: 120,
          trackNumber: 1
        }
      })
    : await prisma.song.create({
        data: {
          artistId: artist.id,
          albumId: album.id,
          genreId: genre.id,
          title: "Demo Track",
          durationSeconds: 120,
          trackNumber: 1
        }
      });

  await prisma.audioFile.upsert({
    where: { songId: song.id },
    update: {},
    create: {
      songId: song.id,
      storagePath: "demo-track.mp3",
      mimeType: "audio/mpeg",
      fileSizeBytes: 1n,
      durationSeconds: 120,
      checksumSha256: checksum("demo-track-placeholder"),
      bitrateKbps: 128,
      sampleRateHz: 44100,
      isAvailable: false
    }
  });
}

main()
  .finally(async () => {
    await prisma.$disconnect();
  });

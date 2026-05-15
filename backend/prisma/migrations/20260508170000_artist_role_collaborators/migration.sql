-- AlterTable
ALTER TABLE "artists" ADD COLUMN "owner_user_id" BIGINT;

-- CreateTable
CREATE TABLE "song_collaborators" (
    "song_id" BIGINT NOT NULL,
    "artist_id" BIGINT NOT NULL,
    "role" VARCHAR(50) NOT NULL DEFAULT 'featured',

    CONSTRAINT "song_collaborators_pkey" PRIMARY KEY ("song_id","artist_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "artists_owner_user_id_key" ON "artists"("owner_user_id");

-- CreateIndex
CREATE INDEX "song_collaborators_artist_id_idx" ON "song_collaborators"("artist_id");

-- AddForeignKey
ALTER TABLE "artists" ADD CONSTRAINT "artists_owner_user_id_fkey" FOREIGN KEY ("owner_user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "song_collaborators" ADD CONSTRAINT "song_collaborators_song_id_fkey" FOREIGN KEY ("song_id") REFERENCES "songs"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "song_collaborators" ADD CONSTRAINT "song_collaborators_artist_id_fkey" FOREIGN KEY ("artist_id") REFERENCES "artists"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

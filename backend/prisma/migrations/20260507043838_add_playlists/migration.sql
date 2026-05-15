-- CreateTable
CREATE TABLE "playlists" (
    "id" BIGSERIAL NOT NULL,
    "user_id" BIGINT NOT NULL,
    "name" VARCHAR(150) NOT NULL,
    "description" VARCHAR(255),
    "is_public" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "playlists_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "playlist_songs" (
    "playlist_id" BIGINT NOT NULL,
    "song_id" BIGINT NOT NULL,
    "position" INTEGER NOT NULL,
    "added_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "playlist_songs_pkey" PRIMARY KEY ("playlist_id","song_id")
);

-- CreateIndex
CREATE INDEX "playlists_user_id_idx" ON "playlists"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "playlists_user_id_name_key" ON "playlists"("user_id", "name");

-- CreateIndex
CREATE INDEX "playlist_songs_song_id_idx" ON "playlist_songs"("song_id");

-- CreateIndex
CREATE INDEX "playlist_songs_playlist_id_position_idx" ON "playlist_songs"("playlist_id", "position");

-- AddForeignKey
ALTER TABLE "playlists" ADD CONSTRAINT "playlists_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "playlist_songs" ADD CONSTRAINT "playlist_songs_playlist_id_fkey" FOREIGN KEY ("playlist_id") REFERENCES "playlists"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "playlist_songs" ADD CONSTRAINT "playlist_songs_song_id_fkey" FOREIGN KEY ("song_id") REFERENCES "songs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

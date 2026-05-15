-- CreateTable
CREATE TABLE "roles" (
    "id" BIGSERIAL NOT NULL,
    "name" VARCHAR(50) NOT NULL,
    "description" VARCHAR(255),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" BIGSERIAL NOT NULL,
    "role_id" BIGINT NOT NULL,
    "name" VARCHAR(120) NOT NULL,
    "email" VARCHAR(150) NOT NULL,
    "password_hash" VARCHAR(255) NOT NULL,
    "status" VARCHAR(20) NOT NULL DEFAULT 'active',
    "last_login_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "artists" (
    "id" BIGSERIAL NOT NULL,
    "name" VARCHAR(150) NOT NULL,
    "bio" TEXT,
    "country" VARCHAR(100),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "artists_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "genres" (
    "id" BIGSERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" VARCHAR(255),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "genres_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "albums" (
    "id" BIGSERIAL NOT NULL,
    "artist_id" BIGINT NOT NULL,
    "genre_id" BIGINT,
    "title" VARCHAR(180) NOT NULL,
    "release_date" DATE,
    "cover_image_path" VARCHAR(255),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "albums_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "songs" (
    "id" BIGSERIAL NOT NULL,
    "artist_id" BIGINT NOT NULL,
    "album_id" BIGINT,
    "genre_id" BIGINT NOT NULL,
    "title" VARCHAR(180) NOT NULL,
    "duration_seconds" INTEGER NOT NULL,
    "track_number" INTEGER,
    "release_date" DATE,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "songs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audio_files" (
    "id" BIGSERIAL NOT NULL,
    "song_id" BIGINT NOT NULL,
    "storage_path" VARCHAR(255) NOT NULL,
    "mime_type" VARCHAR(100) NOT NULL,
    "file_size_bytes" BIGINT NOT NULL,
    "duration_seconds" INTEGER NOT NULL,
    "checksum_sha256" CHAR(64) NOT NULL,
    "bitrate_kbps" INTEGER,
    "sample_rate_hz" INTEGER,
    "is_available" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "audio_files_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "favorites" (
    "id" BIGSERIAL NOT NULL,
    "user_id" BIGINT NOT NULL,
    "song_id" BIGINT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "favorites_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "play_history" (
    "id" BIGSERIAL NOT NULL,
    "user_id" BIGINT NOT NULL,
    "song_id" BIGINT NOT NULL,
    "started_at" TIMESTAMP(3) NOT NULL,
    "ended_at" TIMESTAMP(3),
    "played_seconds" INTEGER NOT NULL DEFAULT 0,
    "completion_rate" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "device_type" VARCHAR(20) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "play_history_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_interactions" (
    "id" BIGSERIAL NOT NULL,
    "user_id" BIGINT NOT NULL,
    "song_id" BIGINT,
    "interaction_type" VARCHAR(50) NOT NULL,
    "interaction_value" VARCHAR(255),
    "metadata_json" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_interactions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "recommendations" (
    "id" BIGSERIAL NOT NULL,
    "user_id" BIGINT NOT NULL,
    "song_id" BIGINT NOT NULL,
    "score" DOUBLE PRECISION NOT NULL,
    "source" VARCHAR(30) NOT NULL DEFAULT 'hybrid',
    "reason_text" VARCHAR(255),
    "generated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMP(3),

    CONSTRAINT "recommendations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "refresh_tokens" (
    "id" BIGSERIAL NOT NULL,
    "user_id" BIGINT NOT NULL,
    "token_hash" CHAR(64) NOT NULL,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "revoked_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "refresh_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "roles_name_key" ON "roles"("name");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "artists_name_idx" ON "artists"("name");

-- CreateIndex
CREATE UNIQUE INDEX "genres_name_key" ON "genres"("name");

-- CreateIndex
CREATE INDEX "albums_artist_id_idx" ON "albums"("artist_id");

-- CreateIndex
CREATE INDEX "albums_title_idx" ON "albums"("title");

-- CreateIndex
CREATE INDEX "songs_title_idx" ON "songs"("title");

-- CreateIndex
CREATE INDEX "songs_artist_id_genre_id_is_active_idx" ON "songs"("artist_id", "genre_id", "is_active");

-- CreateIndex
CREATE INDEX "songs_album_id_idx" ON "songs"("album_id");

-- CreateIndex
CREATE UNIQUE INDEX "audio_files_song_id_key" ON "audio_files"("song_id");

-- CreateIndex
CREATE UNIQUE INDEX "audio_files_storage_path_key" ON "audio_files"("storage_path");

-- CreateIndex
CREATE UNIQUE INDEX "audio_files_checksum_sha256_key" ON "audio_files"("checksum_sha256");

-- CreateIndex
CREATE INDEX "favorites_song_id_idx" ON "favorites"("song_id");

-- CreateIndex
CREATE UNIQUE INDEX "favorites_user_id_song_id_key" ON "favorites"("user_id", "song_id");

-- CreateIndex
CREATE INDEX "play_history_user_id_started_at_idx" ON "play_history"("user_id", "started_at");

-- CreateIndex
CREATE INDEX "play_history_song_id_started_at_idx" ON "play_history"("song_id", "started_at");

-- CreateIndex
CREATE INDEX "user_interactions_user_id_interaction_type_created_at_idx" ON "user_interactions"("user_id", "interaction_type", "created_at");

-- CreateIndex
CREATE INDEX "user_interactions_song_id_idx" ON "user_interactions"("song_id");

-- CreateIndex
CREATE INDEX "recommendations_user_id_score_idx" ON "recommendations"("user_id", "score");

-- CreateIndex
CREATE INDEX "recommendations_generated_at_idx" ON "recommendations"("generated_at");

-- CreateIndex
CREATE UNIQUE INDEX "refresh_tokens_token_hash_key" ON "refresh_tokens"("token_hash");

-- CreateIndex
CREATE INDEX "refresh_tokens_user_id_expires_at_idx" ON "refresh_tokens"("user_id", "expires_at");

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "roles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "albums" ADD CONSTRAINT "albums_artist_id_fkey" FOREIGN KEY ("artist_id") REFERENCES "artists"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "albums" ADD CONSTRAINT "albums_genre_id_fkey" FOREIGN KEY ("genre_id") REFERENCES "genres"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "songs" ADD CONSTRAINT "songs_artist_id_fkey" FOREIGN KEY ("artist_id") REFERENCES "artists"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "songs" ADD CONSTRAINT "songs_album_id_fkey" FOREIGN KEY ("album_id") REFERENCES "albums"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "songs" ADD CONSTRAINT "songs_genre_id_fkey" FOREIGN KEY ("genre_id") REFERENCES "genres"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audio_files" ADD CONSTRAINT "audio_files_song_id_fkey" FOREIGN KEY ("song_id") REFERENCES "songs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "favorites" ADD CONSTRAINT "favorites_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "favorites" ADD CONSTRAINT "favorites_song_id_fkey" FOREIGN KEY ("song_id") REFERENCES "songs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "play_history" ADD CONSTRAINT "play_history_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "play_history" ADD CONSTRAINT "play_history_song_id_fkey" FOREIGN KEY ("song_id") REFERENCES "songs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_interactions" ADD CONSTRAINT "user_interactions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_interactions" ADD CONSTRAINT "user_interactions_song_id_fkey" FOREIGN KEY ("song_id") REFERENCES "songs"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "recommendations" ADD CONSTRAINT "recommendations_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "recommendations" ADD CONSTRAINT "recommendations_song_id_fkey" FOREIGN KEY ("song_id") REFERENCES "songs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "refresh_tokens" ADD CONSTRAINT "refresh_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

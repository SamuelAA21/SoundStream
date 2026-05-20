#!/usr/bin/env bash

set -Eeuo pipefail

APP_DIR="${APP_DIR:-/srv/soundstream/app}"
BRANCH="${1:-Implementacion-de-servidor}"
BACKEND_DIR="$APP_DIR/backend"
FRONTEND_DIR="$APP_DIR/flutter_client"

log() {
  printf '\n[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1"
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_command git
require_command npm
require_command flutter
require_command sudo

if [ ! -d "$APP_DIR/.git" ]; then
  echo "Repository not found at $APP_DIR" >&2
  exit 1
fi

log "Updating repository in $APP_DIR"
cd "$APP_DIR"
git fetch origin "$BRANCH"
git checkout "$BRANCH"
git pull --ff-only origin "$BRANCH"

log "Deploying backend"
cd "$BACKEND_DIR"
npm ci
npm run prisma:deploy
npm run build
sudo systemctl restart soundstream-backend
sudo systemctl --no-pager --full status soundstream-backend

log "Building Flutter web frontend"
cd "$FRONTEND_DIR"
flutter pub get
flutter build web

log "Reloading nginx"
sudo nginx -t
sudo systemctl reload nginx

log "Deployment finished"
echo "Try: http://soundstream.test"
echo "Health: curl http://soundstream.test/health"

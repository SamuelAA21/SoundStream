#!/data/data/com.termux/files/usr/bin/bash

APP_DIR="${APP_DIR:-/data/data/com.termux/files/home/cloud/apps/SoundStream}"
BRANCH="${1:-rama_server}"
BACKEND_DIR="$APP_DIR/backend"
RUNIT_SERVICE="/data/data/com.termux/files/usr/var/service/soundstream"

log() {
  printf '\n[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1"
}

log "Jalando rama: $BRANCH"
cd "$APP_DIR"
git fetch origin "$BRANCH"
git checkout "$BRANCH"
git pull --ff-only origin "$BRANCH"

log "Instalando dependencias del backend"
cd "$BACKEND_DIR"
npm ci --omit=dev

log "Aplicando migraciones"
npm run prisma:generate
npm run prisma:deploy

log "Compilando TypeScript"
npm run build

log "Reiniciando servicio soundstream"
if sv status "$RUNIT_SERVICE" 2>/dev/null | grep -q "^run:"; then
  sv restart "$RUNIT_SERVICE"
else
  sv up "$RUNIT_SERVICE"
fi

sleep 2
sv status "$RUNIT_SERVICE" 2>/dev/null || echo "Estado del servicio no disponible via sv"

log "Deploy terminado — rama: $BRANCH"
echo "  Health: curl https://soundstream.demonup.site/health"

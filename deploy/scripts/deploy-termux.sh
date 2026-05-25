#!/data/data/com.termux/files/usr/bin/sh

set -Eeuo pipefail

APP_DIR="${APP_DIR:-/data/data/com.termux/files/home/cloud/apps/SoundStream}"
BACKEND_DIR="$APP_DIR/backend"
FRONTEND_DIR="$APP_DIR/flutter_client"
STATIC_OUT="$FRONTEND_DIR/build/web"
RUNIT_SERVICE="/data/data/com.termux/files/usr/var/service/soundstream"

log() {
  printf '\n[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1"
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Falta el comando requerido: $1" >&2
    exit 1
  fi
}

require_command node
require_command npm
require_command pg_isready

# ── PostgreSQL ────────────────────────────────────────────────────────────────
log "Verificando PostgreSQL"
PGDATA="/data/data/com.termux/files/usr/var/lib/postgresql"

if [ ! -f "$PGDATA/PG_VERSION" ]; then
  log "Inicializando base de datos PostgreSQL por primera vez"
  initdb -D "$PGDATA"
fi

if ! pg_isready -q; then
  log "Iniciando PostgreSQL"
  rm -f "$RUNIT_SERVICE/../postgres/down" 2>/dev/null || true
  sv up /data/data/com.termux/files/usr/var/service/postgres
  # Esperar a que postgres esté listo
  for i in $(seq 1 15); do
    pg_isready -q && break
    sleep 1
  done
fi

if ! pg_isready -q; then
  echo "PostgreSQL no respondio a tiempo" >&2
  exit 1
fi

# Crear usuario y base de datos si no existen
psql -d postgres -tc "SELECT 1 FROM pg_roles WHERE rolname='soundstream_user'" | grep -q 1 \
  || psql -d postgres -c "CREATE USER soundstream_user WITH PASSWORD '$(grep DB_PASSWORD "$BACKEND_DIR/.env" 2>/dev/null | cut -d= -f2 || echo soundstream_dev)';"
psql -d postgres -tc "SELECT 1 FROM pg_database WHERE datname='soundstream'" | grep -q 1 \
  || psql -d postgres -c "CREATE DATABASE soundstream OWNER soundstream_user;"

# ── Backend ───────────────────────────────────────────────────────────────────
log "Instalando dependencias del backend"
cd "$BACKEND_DIR"
npm ci --omit=dev

log "Generando cliente Prisma"
npm run prisma:generate

log "Aplicando migraciones"
npm run prisma:deploy

log "Compilando TypeScript"
npm run build

# ── Frontend Flutter Web ──────────────────────────────────────────────────────
if command -v flutter >/dev/null 2>&1; then
  log "Compilando Flutter Web"
  cd "$FRONTEND_DIR"
  flutter pub get
  flutter build web
else
  log "Flutter no encontrado — omitiendo build web"
  log "Copia manualmente el build/web en: $STATIC_OUT"
fi

# ── Servicio runit ────────────────────────────────────────────────────────────
log "Iniciando/reiniciando servicio soundstream"
rm -f "$RUNIT_SERVICE/down" 2>/dev/null || true

if sv status "$RUNIT_SERVICE" 2>/dev/null | grep -q "^run:"; then
  sv restart "$RUNIT_SERVICE"
else
  sv up "$RUNIT_SERVICE"
fi

sleep 2
sv status "$RUNIT_SERVICE"

log "Deploy terminado"
echo ""
echo "  App:    https://soundstream.demonup.site"
echo "  Health: curl https://soundstream.demonup.site/health"

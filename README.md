# SoundStream

Sistema de streaming musical en tiempo real con backend REST en Fastify + Prisma + PostgreSQL y cliente Flutter para Web y Android.

## Estado actual

- Backend funcional
- Cliente Flutter funcional
- Despliegue privado funcional en VM Ubuntu Server
- Acceso web privado por ZeroTier
- Base de datos fija en servidor

Acceso privado actual para testers:

- `http://10.91.104.92`

## Stack

- Backend: Node.js, Fastify, Prisma, PostgreSQL, Zod, JWT
- Frontend: Flutter, Provider, HTTP, Shared Preferences, Audioplayers
- Infra privada: Ubuntu Server, systemd, nginx, ZeroTier

## Modulos implementados

- Auth
- Catalog
- Favorites
- Playlists
- History
- Recommendations
- Streaming
- Artist
- Admin

## Estructura del repositorio

```text
SoundStream/
|- backend/
|- deploy/
|- flutter_client/
|- documentation.md
|- README.md
\- requerimientos.md
```

## Inicio rapido local

### Backend

```powershell
cd backend
npm install
npm run prisma:generate
npm run prisma:migrate
npm run prisma:seed
npm run dev
```

### Flutter Web local

```powershell
cd flutter_client
flutter pub get
flutter run -d chrome --web-port 5173 --dart-define=API_BASE_URL=http://localhost:3000/api
```

### Android Emulator

```powershell
cd flutter_client
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

## Trabajo sin servidor compartido

Si la PC donde corre la VM del servidor esta apagada:

- deja de estar disponible `http://10.91.104.92`
- no se puede usar la base de datos central compartida
- los testers no pueden entrar al entorno privado

Pero el desarrollo no se detiene. Cada compañero puede seguir trabajando de forma local levantando su propia copia del proyecto con los comandos de `Inicio rapido local`.

En ese escenario, cada desarrollador usa:

- su propio backend local
- su propia base de datos PostgreSQL local
- su propio frontend Flutter local

El servidor privado actual debe entenderse como entorno de integracion, demo y pruebas compartidas, no como unico punto para desarrollar.

## Despliegue privado actual

Topologia actual:

```text
Cliente en ZeroTier
  -> http://10.91.104.92
  -> nginx
  -> /api -> backend Fastify
  -> PostgreSQL local
  -> audio en /srv/soundstream/audio
```

Notas:

- el backend corre como servicio `systemd`
- el frontend web se sirve desde el build generado en la VM
- el acceso para testers se hace por la IP ZeroTier del servidor

## Script de actualizacion del servidor

El repo incluye:

- `deploy/scripts/update_server.sh`

Uso en la VM:

```bash
cd /srv/soundstream/app
bash deploy/scripts/update_server.sh
```

Ese script:

- hace `git pull`
- instala dependencias del backend
- aplica migraciones con `prisma:deploy`
- compila backend
- reinicia el servicio del backend
- ejecuta `flutter pub get`
- compila `flutter build web`
- recarga `nginx`

## Variables de entorno

Ver:

- `backend/.env.example`
- `backend/.env.production.example`

## Credenciales demo

- Admin: `admin@soundstream.local` / `Admin12345`
- Artista: `artist@soundstream.local` / `Artist12345`
- Usuario: `demo@soundstream.local` / `Demo12345`

## Limitaciones actuales

- el acceso actual no es publico por Internet
- los testers necesitan acceso a la red ZeroTier
- el seed deja el catalogo potencialmente vacio hasta subir audio real
- no hay pipeline CI/CD formal todavia

## Documentacion detallada

Consulta:

- [Manual.md](Manual.md)
- [documentation.md](documentation.md)
- [requerimientos.md](requerimientos.md)

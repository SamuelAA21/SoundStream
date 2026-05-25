# SoundStream

## Objetivo

SoundStream es un sistema de streaming musical en tiempo real con:

* backend REST en Fastify + Prisma + PostgreSQL
* cliente Flutter para Web y Android
* autenticacion con JWT y refresh token
* catalogo, favoritos, playlists, historial y recomendaciones
* modulo artista y modulo administrador

El proyecto sigue una arquitectura monolitica con backend y frontend separados, segun los lineamientos de [requerimientos.md](requerimientos.md).

## Estado actual del proyecto

Hoy el repositorio ya tiene:

* backend funcional en `backend`
* cliente Flutter funcional en `flutter_client`
* despliegue privado funcional sobre una VM Ubuntu Server
* PostgreSQL fijo en servidor
* frontend web servido por `nginx`
* backend levantado como servicio `systemd`
* acceso privado multiusuario por red ZeroTier

Estado del acceso:

* Android APK: funcional contra el servidor
* Flutter Web: funcional servido desde la VM
* acceso para testers: por IP privada ZeroTier del servidor
* acceso publico por Internet: no implementado todavia

Para operacion, mantenimiento y procedimientos de emergencia, consulta tambien [Manual.md](manual.md).

## Estructura del repositorio

```
SoundStream/
|- backend/
|- deploy/
|  |- dnsmasq/
|  |- nginx/
|  \- scripts/
|- flutter_client/
|- documentation.md
|- README.md
\- requerimientos.md
```

## Arquitectura

### Backend

El backend esta organizado por modulos y capas:

* `controllers`: reciben requests y devuelven respuestas
* `services`: contienen logica de negocio
* `repositories`: acceden a base de datos con Prisma
* `middlewares`: auth, roles, errores y validacion

Modulos actuales:

* `auth`
* `catalog`
* `favorites`
* `playlists`
* `history`
* `recommendations`
* `streaming`
* `artist`
* `admin`

### Frontend

El cliente Flutter usa una estructura modular ligera:

* `core`: cliente HTTP, configuracion y persistencia local
* `theme`: tema, colores y decoraciones globales
* `shared/widgets`: widgets compartidos
* `features/auth`
* `features/layout`
* `features/home`
* `models`
* `services`
* `controllers`

Detalles importantes:

* usa `Provider + ChangeNotifier`
* la sesion se persiste localmente
* el cliente intenta refresh silencioso del token
* en Web, fuera de `localhost`, el cliente usa `/api` como base por defecto para evitar CORS cuando esta detras de `nginx`
* los requests `POST`, `PATCH` y `DELETE` sin body no deben forzar `Content-Type: application/json`

## Stack tecnologico

### Backend

* Node.js
* Fastify
* Prisma
* PostgreSQL
* Zod
* JWT

### Frontend

* Flutter
* Provider
* HTTP
* Shared Preferences
* Audioplayers
* File Picker

### Infraestructura privada actual

* Ubuntu Server
* `systemd`
* `nginx`
* `ZeroTier`
* `dnsmasq` opcional

## Variables de entorno del backend

El backend valida estas variables desde `backend/src/config/env.ts`:

```env
NODE_ENV=development
PORT=3000
HOST=0.0.0.0
DATABASE_URL=postgresql://USER:PASSWORD@localhost:5432/soundstream
JWT_SECRET=una_clave_larga_de_al_menos_16_caracteres
JWT_EXPIRES_IN=15m
REFRESH_TOKEN_DAYS=30
AUDIO_STORAGE_PATH=./storage/audio
WEB_ORIGIN=http://localhost:5173
WEB_ORIGINS=http://localhost:5173,http://localhost:3001
```

Archivos utiles:

* desarrollo local: `backend/.env`
* ejemplo productivo: `backend/.env.production.example`

## Scripts relevantes

### Backend

Desde `backend/`:

```powershell
npm install
npm run prisma:generate
npm run prisma:migrate
npm run prisma:seed
npm run dev
```

Scripts disponibles:

* `npm run dev`
* `npm run build`
* `npm run start`
* `npm run lint`
* `npm run prisma:generate`
* `npm run prisma:migrate`
* `npm run prisma:deploy`
* `npm run prisma:seed`

### Frontend

Desde `flutter_client/`:

```powershell
flutter pub get
flutter run -d chrome --web-port 5173 --dart-define=API_BASE_URL=http://localhost:3000/api
```

Builds utiles:

```powershell
flutter build web
flutter build apk --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

## Rutas expuestas por el backend

Todas las rutas del negocio cuelgan de `/api`.

### Auth

* `GET /api/auth/me`
* `POST /api/auth/register`
* `POST /api/auth/login`
* `POST /api/auth/refresh`
* `POST /api/auth/logout`

### Catalogo

* `GET /api/catalog/albums`
* `GET /api/catalog/albums/:albumId`
* `GET /api/catalog/songs`
* `GET /api/catalog/songs/:songId`

### Favoritos

* `GET /api/favorites`
* `POST /api/favorites/:songId`
* `DELETE /api/favorites/:songId`

### Playlists

* `GET /api/playlists`
* `POST /api/playlists`
* `GET /api/playlists/:playlistId`
* `POST /api/playlists/:playlistId/songs/:songId`
* `DELETE /api/playlists/:playlistId/songs/:songId`

### Historial

* `GET /api/history`
* `POST /api/history/plays`
* `POST /api/history/interactions`

### Recomendaciones

* `GET /api/recommendations`
* `POST /api/recommendations/refresh`

### Streaming

* `GET /api/stream/songs/:songId`

### Artista

* `GET /api/artist/songs`
* `GET /api/artist/albums`
* `POST /api/artist/songs`
* `PATCH /api/artist/songs/:songId/publication`
* `DELETE /api/artist/songs/:songId`
* `PATCH /api/artist/songs/:songId/album`
* `POST /api/artist/albums`

### Admin

* `GET /api/admin/users`
* `PATCH /api/admin/users/:userId/status`
* `POST /api/admin/songs`
* `DELETE /api/admin/songs/:songId`
* `PATCH /api/admin/songs/:songId/album`
* `POST /api/admin/albums`

## Modelo de datos

Entidades principales en `backend/prisma/schema.prisma`:

* `Role`
* `User`
* `Artist`
* `Genre`
* `Album`
* `Song`
* `SongCollaborator`
* `AudioFile`
* `Favorite`
* `Playlist`
* `PlaylistSong`
* `PlayHistory`
* `UserInteraction`
* `Recommendation`
* `RefreshToken`

Notas del modelo actual:

* una cancion puede existir sin album
* un album puede existir vacio
* las colaboraciones se modelan con `SongCollaborator`
* los archivos reales se guardan fuera de la base de datos

## Seed y credenciales demo

Credenciales:

* Admin: `admin@soundstream.local` / `Admin12345`
* Artista: `artist@soundstream.local` / `Artist12345`
* Usuario: `demo@soundstream.local` / `Demo12345`

Importante:

* el seed actual crea la metadata demo
* la cancion demo queda con `audioFile.isAvailable = false`
* por eso el catalogo puede verse vacio hasta subir un archivo real de audio

## Streaming y carga de audio

### Streaming

El backend expone:

* `GET /api/stream/songs/:songId`

Detalles:

* requiere autenticacion
* soporta `Range`
* puede responder `206 Partial Content`
* el cliente Flutter reproduce audio autenticado descargado como bytes

### Uploads

El backend acepta hasta `50 MB` por archivo.

En el despliegue privado con `nginx`, tambien se ajusto:

* `client_max_body_size 60m`

para que `nginx` no bloquee antes de que el backend valide el archivo.

## Despliegue privado actual

### Topologia actual

La topologia funcional hoy es:

```
Cliente dentro de ZeroTier
  -> http://10.91.104.92
  -> nginx en la VM
  -> /api -> backend Fastify
  -> PostgreSQL local
  -> /srv/soundstream/audio
```

### Servidor

El servidor privado actual usa:

* VM Ubuntu Server
* repo clonado en `/srv/soundstream/app`
* backend como servicio `systemd`
* frontend web servido por `nginx`
* PostgreSQL local en `127.0.0.1:5432`
* audio persistente en `/srv/soundstream/audio`

### Acceso recomendado actual

Para pruebas privadas y testers, el acceso recomendado es:

* `http://10.91.104.92`

Notas:

* no requiere DNS gestionado pago
* no requiere editar el frontend por tester
* cada tester debe estar dentro de la red ZeroTier

### `soundstream.test`

El repo incluye soporte para `soundstream.test`, pero hoy esa ruta es opcional.

Archivos relacionados:

* `deploy/nginx/soundstream.test.conf`
* `deploy/dnsmasq/soundstream.test.conf`

Como ZeroTier Custom DNS no esta disponible en el plan actual, la forma mas simple de acceso entre testers es usar directamente la IP de ZeroTier.

## Flujo de actualizacion del servidor

El servidor no se usa como entorno de desarrollo.

Flujo correcto:

1. hacer cambios en Windows
2. probar localmente
3. `git push`
4. en la VM hacer `git pull`
5. recompilar backend y frontend
6. reiniciar o recargar servicios

### Script de despliegue

Se agrego:

* `deploy/scripts/update_server.sh`

Uso:

```bash
cd /srv/soundstream/app
bash deploy/scripts/update_server.sh
```

El script:

* actualiza el repo
* instala dependencias del backend
* aplica migraciones productivas
* compila backend
* reinicia `soundstream-backend`
* ejecuta `flutter pub get`
* compila `flutter build web`
* valida y recarga `nginx`

### Requisitos del script

En la VM deben existir:

* `git`
* `npm`
* `flutter`
* `nginx`
* `sudo`

## Servicios del servidor

### Backend

Servicio:

* `soundstream-backend`

Comandos utiles:

```bash
sudo systemctl status soundstream-backend
sudo systemctl restart soundstream-backend
journalctl -u soundstream-backend -f
```

### Nginx

Comandos utiles:

```bash
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl reload nginx
sudo systemctl status nginx
```

### PostgreSQL

Comandos utiles:

```bash
sudo systemctl status postgresql
sudo -u postgres psql
```

## Pruebas recomendadas

### Salud del backend

```bash
curl http://127.0.0.1:3000/health
curl http://10.91.104.92:3000/health
```

### Salud del frontend publicado

```bash
curl http://10.91.104.92/health
curl http://10.91.104.92/api/catalog/songs
```

### Navegador

Abrir:

* `http://10.91.104.92`

### Login demo

Usar:

* `demo@soundstream.local` / `Demo12345`

## Limitaciones actuales

* el acceso actual es privado, no publico
* los usuarios necesitan acceso a la red ZeroTier
* el seed no deja una pista publica reproducible por defecto
* la UI es funcional, no final de producto
* el cliente no usa seek remoto avanzado por `Range`
* no hay pipeline CI/CD formal todavia

## Archivos clave

Backend:

* `backend/src/server.ts`
* `backend/src/routes/index.ts`
* `backend/src/config/env.ts`
* `backend/prisma/schema.prisma`
* `backend/prisma/seed.ts`

Despliegue:

* `deploy/nginx/soundstream.test.conf`
* `deploy/dnsmasq/soundstream.test.conf`
* `deploy/scripts/update_server.sh`

Frontend:

* `flutter_client/lib/main.dart`
* `flutter_client/lib/src/app.dart`
* `flutter_client/lib/src/core/config/app_config.dart`
* `flutter_client/lib/src/core/config/service_locator.dart`
* `flutter_client/lib/src/core/api/api_client.dart`
* `flutter_client/lib/src/features/layout/views/app_shell.dart`
* `flutter_client/lib/src/features/home/sections/catalog_section.dart`
* `flutter_client/lib/src/controllers/controllers.dart`
* `flutter_client/lib/src/services/services.dart`

## Inspeccion y depuracion del frontend

Para analizar componentes Flutter:

1. corre la app con `flutter run -d chrome`
2. abre otra terminal y ejecuta `dart devtools`
3. abre la URL de DevTools
4. conecta la app con la URL del Dart VM Service impresa por Flutter
5. usa `Inspector` y `Select Widget Mode`

Importante:

* el navegador no expone widgets Flutter como un DOM HTML normal
* para cambios visuales temporales, el flujo correcto es editar Dart y usar hot reload
* si cambias infraestructura del cliente, por ejemplo `ApiClient`, a veces necesitas reiniciar completamente `flutter run`

Archivo local:

* `devtools_options.yaml` puede aparecer al usar DevTools
* es un archivo local de configuracion y no debe subirse al repo

## Resumen corto para otra IA

Si otra IA retoma este repositorio, el contexto minimo util es:

* backend real en `backend`
* cliente real en `flutter_client`
* despliegue privado funcional en VM Ubuntu
* acceso web privado actual por `http://10.91.104.92`
* backend servido por `systemd`
* frontend web servido por `nginx`
* PostgreSQL local al servidor
* actualizaciones por `git pull` y `deploy/scripts/update_server.sh`

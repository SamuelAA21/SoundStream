# SoundStream

## Resumen

Este repositorio contiene dos aplicaciones principales:

- `backend`: API REST en Fastify + Prisma sobre PostgreSQL.
- `flutter_client`: cliente Flutter conectado al backend real.

El proyecto implementa autenticacion con JWT, catalogo musical, favoritos, playlists, historial, recomendaciones, streaming protegido, herramientas para artistas y operaciones administrativas.

## Estructura del repositorio

```text
SoundStream/
|- backend/
|  |- prisma/
|  |- src/
|  |  |- config/
|  |  |- middlewares/
|  |  |- modules/
|  |  |- routes/
|  |  \- utils/
|  \- __tests__/
|- flutter_client/
|  |- lib/src/
|  |  |- controllers/
|  |  |- core/
|  |  |- models/
|  |  |- services/
|  |  \- views/
|  \- test/
|- documentation.md
\- requerimientos.md
```

## Backend

### Stack

- Node.js
- Fastify
- Prisma
- PostgreSQL
- Zod
- JWT
- Multipart para carga de audio

### Variables de entorno

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

Notas:

- `DATABASE_URL` y `JWT_SECRET` son obligatorias.
- Si defines `WEB_ORIGINS`, el backend aceptara multiples origenes separados por comas.
- El endpoint de salud publica es `GET /health`.

### Instalacion y arranque

Desde `backend/`:

```powershell
npm install
npm run prisma:generate
npm run prisma:migrate
npm run prisma:seed
npm run dev
```

Scripts disponibles:

- `npm run dev`: desarrollo con `tsx watch`.
- `npm run build`: compila TypeScript.
- `npm run start`: ejecuta la version compilada.
- `npm run lint`: valida tipos con `tsc --noEmit`.
- `npm run prisma:generate`: genera el cliente Prisma.
- `npm run prisma:migrate`: ejecuta migraciones en desarrollo.
- `npm run prisma:deploy`: aplica migraciones en servidor o produccion.
- `npm run prisma:seed`: carga datos demo.

### Arquitectura del backend

El backend esta organizado por modulos:

- `auth`
- `catalog`
- `favorites`
- `playlists`
- `history`
- `recommendations`
- `streaming`
- `artist`
- `admin`

Cada modulo sigue una separacion por `controllers`, `services` y `repositories`.

### Rutas expuestas

Todas las rutas del negocio cuelgan de `/api`.

#### Auth

- `GET /api/auth/me`
- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/auth/logout`

#### Catalogo

- `GET /api/catalog/albums`
- `GET /api/catalog/albums/:albumId`
- `GET /api/catalog/songs`
- `GET /api/catalog/songs/:songId`

#### Favoritos

- `GET /api/favorites`
- `POST /api/favorites/:songId`
- `DELETE /api/favorites/:songId`

#### Playlists

- `GET /api/playlists`
- `POST /api/playlists`
- `GET /api/playlists/:playlistId`
- `POST /api/playlists/:playlistId/songs/:songId`
- `DELETE /api/playlists/:playlistId/songs/:songId`

#### Historial

- `GET /api/history`
- `POST /api/history/plays`
- `POST /api/history/interactions`

#### Recomendaciones

- `GET /api/recommendations`
- `POST /api/recommendations/refresh`

#### Streaming

- `GET /api/stream/songs/:songId`

#### Artista

- `GET /api/artist/songs`
- `POST /api/artist/songs`
- `PATCH /api/artist/songs/:songId/publication`
- `DELETE /api/artist/songs/:songId`
- `PATCH /api/artist/songs/:songId/album`
- `POST /api/artist/albums`

#### Admin

- `GET /api/admin/users`
- `PATCH /api/admin/users/:userId/status`
- `POST /api/admin/songs`
- `DELETE /api/admin/songs/:songId`
- `PATCH /api/admin/songs/:songId/album`
- `POST /api/admin/albums`

### Modelo de datos

Las entidades principales definidas en `backend/prisma/schema.prisma` son:

- `Role`
- `User`
- `Artist`
- `Genre`
- `Album`
- `Song`
- `SongCollaborator`
- `AudioFile`
- `Favorite`
- `Playlist`
- `PlaylistSong`
- `PlayHistory`
- `UserInteraction`
- `Recommendation`
- `RefreshToken`

Detalles relevantes del modelo actual:

- Una cancion puede existir sin album.
- Un album puede existir vacio.
- Las colaboraciones entre artistas se guardan en `SongCollaborator`.
- El streaming se apoya en `AudioFile` y almacenamiento local en `backend/storage/audio`.

### Seed y credenciales demo

El seed crea:

- roles `admin`, `user` y `artist`
- usuario admin
- usuario artista con perfil de artista
- usuario demo comun
- genero `Electronic`
- artista `SoundStream Lab`
- album `V1 Sessions`
- cancion `Demo Track`

Credenciales:

- Admin: `admin@soundstream.local` / `Admin12345`
- Artista: `artist@soundstream.local` / `Artist12345`
- Usuario: `demo@soundstream.local` / `Demo12345`

## Flutter client

### Stack

- Flutter
- Provider
- HTTP
- Shared Preferences
- Audioplayers
- File Picker

### Arquitectura del cliente

El cliente usa una estructura tipo MVC ligera:

- `models`: modelos de dominio y serializacion.
- `services`: llamadas HTTP al backend.
- `controllers`: estado de UI con `ChangeNotifier`.
- `views`: pantallas y widgets.
- `core`: configuracion, cliente API, sesion persistida y service locator.

El arranque se hace desde `flutter_client/lib/main.dart` y centraliza dependencias en `lib/src/core/service_locator.dart`.

### Funcionalidad implementada

- Login, registro y cierre de sesion.
- Persistencia de sesion con `shared_preferences`.
- Refresh de sesion ante expiracion del access token.
- Consulta de canciones y albumes.
- Busqueda de canciones.
- Favoritos.
- Playlists.
- Historial.
- Recomendaciones.
- Reproduccion de audio desde endpoint protegido.
- Modulo de artista para subir, publicar, eliminar y agrupar canciones.
- Modulo admin para usuarios, canciones y albumes.

### Configuracion de `API_BASE_URL`

La app acepta `--dart-define=API_BASE_URL=...`.

Si no se define, `flutter_client/lib/src/core/app_config.dart` usa estos valores por defecto:

- Web: `http://localhost:3000/api`
- Android: `http://10.0.2.2:3000/api`
- Otros targets: `http://localhost:3000/api`

### Ejecucion

Desde `flutter_client/`:

```powershell
flutter pub get
flutter run -d chrome --web-port 5173 --dart-define=API_BASE_URL=http://localhost:3000/api
```

Para Android Emulator:

```powershell
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

Build web:

```powershell
flutter build web --dart-define=API_BASE_URL=http://localhost:3000/api
```

Build APK:

```powershell
flutter build apk --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

Aunque el proyecto Flutter incluye carpetas generadas para Windows, Linux, macOS e iOS, la configuracion documentada y validada en el codigo esta enfocada en Web y Android.

## Streaming

El flujo actual funciona asi:

- el backend expone `GET /api/stream/songs/:songId`
- la ruta exige autenticacion
- el backend soporta `Range` y puede responder `206 Partial Content`
- el cliente Flutter descarga el audio autenticado y lo reproduce como bytes con `audioplayers`

Implicacion practica:

- el servidor si soporta streaming parcial
- el cliente actual no explota ese `Range` de forma avanzada para seek remoto; el control de avance/retroceso opera sobre el audio ya cargado en el reproductor

## CORS

El backend restringe origenes para clientes web.

Configuracion actual:

- `WEB_ORIGIN` define un origen principal
- `WEB_ORIGINS` permite varios origenes separados por comas

Si ejecutas Flutter Web en `http://localhost:5173`, ese valor debe estar permitido en el backend.

## Despliegue en servidor con ZeroTier

Para el despliegue privado actual se esta usando una VM Ubuntu Server unida a una red de ZeroTier.

Arquitectura operativa recomendada:

- dispositivos cliente conectados a la red ZeroTier
- backend Fastify escuchando en `0.0.0.0:3000`
- PostgreSQL local en la VM escuchando solo en `127.0.0.1:5432`
- almacenamiento persistente de audio fuera del repo, por ejemplo `/srv/soundstream/audio`

Principios de este despliegue:

- los clientes nunca acceden directo a PostgreSQL
- el backend es el unico proceso que usa `DATABASE_URL`
- la VM debe poder actualizar el repo con `git pull`
- el codigo fuente no se edita manualmente en el servidor

Archivo recomendado para variables de entorno productivas:

- `backend/.env.production.example`

Ejemplo de `API_BASE_URL` para clientes conectados a ZeroTier:

- `http://IP_ZEROTIER_SERVIDOR:3000/api`

### Frontend web privado con `soundstream.test`

Para evitar CORS en Flutter Web dentro de la red privada, la estrategia recomendada es:

- servir el frontend web desde la misma VM
- publicar el frontend bajo `http://soundstream.test`
- publicar la API bajo `http://soundstream.test/api`
- dejar que `nginx` haga proxy a `127.0.0.1:3000`

Archivos de apoyo agregados al repo:

- `deploy/nginx/soundstream.test.conf`
- `deploy/dnsmasq/soundstream.test.conf`
- `deploy/scripts/update_server.sh`

Flujo recomendado:

1. Construir Flutter Web.
2. Servir el build directamente desde el repo clonado en la VM.
3. Instalar y configurar `nginx` con `deploy/nginx/soundstream.test.conf`.
4. Resolver `soundstream.test` hacia la IP ZeroTier del servidor usando `dnsmasq` o DNS privado equivalente.
5. Ajustar `WEB_ORIGIN` y `WEB_ORIGINS` del backend para `http://soundstream.test`.

Build recomendado para web privada:

```bash
flutter build web
```

El `root` recomendado para `nginx` es:

- `/srv/soundstream/app/flutter_client/build/web`

El cliente Flutter ya esta preparado para que, en Web, si no corre sobre `localhost`, use `/api` como base por defecto. Eso permite que el frontend servido desde `soundstream.test` consuma la API del mismo host sin depender de CORS ni de un `dart-define` adicional.

### Despliegue automatico desde la VM

Si el servidor ya tiene el repo clonado en `/srv/soundstream/app`, el despliegue recomendado es construir backend y frontend directamente en la VM.

Script de apoyo:

- `deploy/scripts/update_server.sh`

Ejemplo de uso:

```bash
cd /srv/soundstream/app
bash deploy/scripts/update_server.sh
```

El script:

- actualiza el repo con `git pull`
- instala dependencias del backend
- aplica migraciones con `npm run prisma:deploy`
- compila el backend y reinicia `soundstream-backend`
- ejecuta `flutter pub get`
- compila `flutter build web`
- valida y recarga `nginx`

Con este flujo ya no hace falta copiar manualmente `flutter_client/build/web` a otra carpeta del servidor en cada cambio.

## Flujo de actualizacion del servidor

El flujo recomendado de mantenimiento es:

1. Hacer cambios en Windows o en el entorno de desarrollo local.
2. Probar y subir cambios al repositorio remoto.
3. Entrar a la VM y actualizar el codigo con Git.
4. Instalar dependencias si cambiaron.
5. Aplicar migraciones productivas.
6. Compilar y reiniciar el servicio del backend.

Comandos tipicos dentro de la VM:

```bash
cd /srv/soundstream/app
git pull --ff-only origin Implementacion-de-servidor
cd backend
npm ci
npm run prisma:deploy
npm run build
sudo systemctl restart soundstream-backend
sudo systemctl status soundstream-backend
```

Verificaciones utiles:

```bash
curl http://127.0.0.1:3000/health
curl http://IP_ZEROTIER_SERVIDOR:3000/health
```

## Flujo recomendado de arranque

1. Configurar variables de entorno del backend.
2. Levantar PostgreSQL.
3. Ejecutar migraciones y seed en `backend/`.
4. Iniciar el backend en puerto `3000`.
5. Ejecutar Flutter con `API_BASE_URL` apuntando a `http://localhost:3000/api` o `http://10.0.2.2:3000/api` en Android.
6. Iniciar sesion con una cuenta demo o registrar una nueva.

## Pruebas

El repositorio incluye archivos de prueba en:

- `backend/__tests__`
- `flutter_client/test`

Estado actual observado:

- en `backend/package.json` no hay script `test`
- los tests del backend no parecen estar integrados al codigo real actual
- los tests del cliente Flutter son pruebas simples de clases de ejemplo, no cubren el flujo completo de la app

Por eso, hoy la validacion mas confiable sigue siendo:

- `backend`: `npm run lint`
- `flutter_client`: `flutter analyze`
- pruebas manuales de login, catalogo, playlists, favoritos, historial, recomendaciones y streaming

## Limitaciones y observaciones actuales

- La documentacion previa mezclaba ejemplos con `3000` y `4000`; el codigo actual usa `3000` como puerto por defecto del backend.
- La UI Flutter es funcional, pero no representa una capa final de producto.
- El cliente no implementa un streaming remoto avanzado con seek por rangos.
- El backend almacena audio localmente en `backend/storage/audio`.
- Hay archivos generados de Flutter modificados en plataformas de escritorio, asi que conviene revisar el estado de Git antes de hacer cambios adicionales.

## Archivos clave

Backend:

- `backend/src/server.ts`
- `backend/src/routes/index.ts`
- `backend/src/config/env.ts`
- `backend/prisma/schema.prisma`
- `backend/prisma/seed.ts`

Flutter:

- `flutter_client/lib/main.dart`
- `flutter_client/lib/src/app.dart`
- `flutter_client/lib/src/core/app_config.dart`
- `flutter_client/lib/src/core/service_locator.dart`
- `flutter_client/lib/src/core/api_client.dart`
- `flutter_client/lib/src/controllers/controllers.dart`
- `flutter_client/lib/src/services/services.dart`
- `flutter_client/lib/src/views/auth_page.dart`
- `flutter_client/lib/src/views/app_shell.dart`
- `flutter_client/lib/src/views/home_sections.dart`

## Resumen corto para otra IA

Si otra IA retoma este repositorio, el contexto minimo util es:

- el backend real vive en `backend` y expone `/api/...`
- el cliente real vive en `flutter_client`
- la URL por defecto del backend en el codigo actual es `http://localhost:3000`
- Flutter usa `Provider + ChangeNotifier` y un `ServiceLocator`
- la sesion se persiste localmente y se refresca con `refreshToken`
- el streaming esta protegido con JWT
- artistas y admins tienen modulos separados en el backend y en el cliente

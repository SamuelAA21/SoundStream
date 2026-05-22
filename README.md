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
|- Manual.md
|- documentation.md
|- README.md
\- requerimientos.md
```

## Frontend Flutter

La arquitectura actual del cliente esta organizada en:

- `src/core`: infraestructura tecnica
- `src/theme`: colores, tema y decoraciones globales
- `src/shared/widgets`: widgets reutilizables
- `src/features/auth`
- `src/features/layout`
- `src/features/home`
- `src/controllers`, `src/services`, `src/models`

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

## Inspeccion visual del frontend

Para inspeccionar widgets Flutter en Web, no sirve editar el DOM como si fuera una app HTML tradicional. El flujo correcto es:

```powershell
cd flutter_client
flutter run -d chrome
```

En otra terminal:

```powershell
dart devtools
```

Luego:

- abrir la URL que imprime `dart devtools`
- conectar la app usando la URL del Dart VM Service que imprime `flutter run`
- usar `Inspector` y `Select Widget Mode`

Nota:

- `devtools_options.yaml` es configuracion local de DevTools y no debe versionarse en el repo

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

## Notas de depuracion recientes

- si un cambio del cliente HTTP no se refleja en Flutter Web, haz reinicio completo de `flutter run`; no confies solo en hot reload para cambios de infraestructura del cliente
- playlists y favoritos dependen del backend actual corriendo con la ultima version del repo
- el historial se actualiza al registrar la reproduccion real, no solo al abrir el player

## Documentacion detallada

Consulta:

- [Manual.md](Manual.md)
- [documentation.md](documentation.md)
- [requerimientos.md](requerimientos.md)

# Manual Operativo de SoundStream

## Proposito

Este manual esta pensado para entender el proyecto sin depender de memoria ni de conversaciones previas. Su foco es practico:

- que tecnologias debes dominar para ubicarte rapido
- como esta organizado el repositorio
- que corre en el servidor y donde esta cada cosa
- que revisar primero si algo falla

## 1. Conocimientos previos recomendados

No necesitas ser experto en todo, pero si conviene manejar estos bloques.

### Git y flujo de repositorio

Debes sentirte comodo con:

- `git status`
- `git add`
- `git commit`
- `git push`
- `git pull --ff-only`
- ramas, en especial `Implementacion-de-servidor`

Idea clave:

- el codigo se modifica en Windows
- el servidor solo consume el repo clonado y se actualiza con `git pull`
- no conviene editar el codigo fuente directamente en la VM salvo emergencia puntual

### Linux basico

Conviene saber usar:

- `cd`, `ls`, `pwd`, `cat`, `nano`
- `sudo`
- `systemctl`
- `journalctl`
- `ss`
- `ufw`

Esto te permite revisar servicios, logs, puertos y firewall.

### Node.js y npm

El backend esta hecho con Node.js. Debes entender:

- que hace `npm ci`
- que hace `npm run build`
- que hace `npm run start`
- diferencia entre desarrollo y produccion

### PostgreSQL y Prisma

Debes ubicar estos conceptos:

- PostgreSQL es la base de datos real
- Prisma es la capa ORM y de migraciones
- `schema.prisma` define el modelo de datos
- `prisma migrate deploy` aplica migraciones en servidor
- `prisma seed` carga datos de ejemplo

### HTTP, puertos y proxy

Necesitas entender:

- `localhost` o `127.0.0.1` significa "solo esta maquina"
- `0.0.0.0` significa "escuchar en todas las interfaces"
- el backend responde en puerto `3000`
- `nginx` recibe peticiones en puerto `80`
- `nginx` reenvia `/api` al backend

### ZeroTier

En el estado actual del proyecto, ZeroTier da la conectividad privada entre clientes y servidor.

Debes tener claro:

- la IP privada actual del servidor es `10.91.104.92`
- los testers se conectan a esa IP dentro de la red ZeroTier
- sin acceso a ZeroTier, el sistema no esta expuesto publicamente

### Flutter

No hace falta dominar Flutter para operar el servidor, pero si para mantener el cliente.

Lo minimo util es entender:

- `flutter pub get`
- `flutter build web`
- `flutter build apk`
- que el frontend web desplegado es el resultado compilado en `build/web`

## 2. Mapa del repositorio

```text
SoundStream/
|- backend/
|- deploy/
|  |- dnsmasq/
|  |- nginx/
|  \- scripts/
|- flutter_client/
|- documentation.md
|- Manual.md
|- README.md
\- requerimientos.md
```

### `backend/`

Contiene la API REST, autenticacion, logica de negocio, Prisma y tests.

Piezas importantes:

- `backend/src/server.ts`: arranque del servidor Fastify
- `backend/src/routes/index.ts`: registro de modulos y rutas
- `backend/src/config/env.ts`: validacion de variables de entorno
- `backend/prisma/schema.prisma`: modelo de base de datos
- `backend/prisma/migrations/`: historial de migraciones
- `backend/prisma/seed.ts`: datos de prueba

### `flutter_client/`

Cliente Flutter para Web y Android.

Piezas importantes:

- `flutter_client/lib/main.dart`
- `flutter_client/lib/src/app.dart`
- `flutter_client/lib/src/core/app_config.dart`
- `flutter_client/build/web/` cuando se genera el build web en el servidor

### `deploy/`

Infraestructura versionada en el repo.

- `deploy/nginx/soundstream.test.conf`: configuracion de `nginx`
- `deploy/scripts/update_server.sh`: actualizacion del servidor
- `deploy/dnsmasq/soundstream.test.conf`: soporte DNS privado opcional

## 3. Arquitectura actual del sistema

```text
Cliente Web o Android
  -> ZeroTier
  -> http://10.91.104.92
  -> nginx :80
  -> /api -> backend Fastify :3000
  -> PostgreSQL local :5432
  -> audio en /srv/soundstream/audio
```

Idea clave:

- el frontend no se recompila por usuario
- el servidor ya deja publicado el frontend web
- todos los usuarios consumen la misma instancia del backend y la misma base de datos
- cada usuario conserva sus credenciales, historial, favoritos y playlists por separado

## 4. Que tecnologias se usaron y para que

### Backend

- `Fastify`: framework HTTP del backend
- `@fastify/cors`: control de origenes permitidos
- `@fastify/jwt`: emision y validacion de tokens
- `@fastify/multipart`: subida de audio por formularios
- `@fastify/rate-limit`: limite basico de requests
- `Zod`: validacion de entorno y payloads
- `Prisma`: acceso a datos y migraciones
- `PostgreSQL`: persistencia relacional real

### Frontend

- `Flutter`: interfaz para Web y Android
- `Provider`: manejo de estado
- `http`: consumo de API REST
- `shared_preferences`: persistencia local de sesion
- `audioplayers`: reproduccion de audio
- `file_picker`: seleccion de archivos

### Infraestructura

- `Ubuntu Server`: sistema operativo de la VM
- `systemd`: arranque y supervision del backend
- `nginx`: proxy inverso y servidor del frontend web
- `ZeroTier`: red privada de acceso para testers
- `dnsmasq`: DNS privado opcional dentro de la red

## 5. Donde esta cada cosa en el servidor

Estas rutas son las importantes para operar el entorno actual.

### Codigo del proyecto

- Repo clonado: `/srv/soundstream/app`
- Backend dentro del repo: `/srv/soundstream/app/backend`
- Frontend Flutter dentro del repo: `/srv/soundstream/app/flutter_client`

### Frontend desplegado

- Build web servido por `nginx`: `/srv/soundstream/app/flutter_client/build/web`

### Archivos de audio

- Carpeta persistente de audio: `/srv/soundstream/audio`

Esta ruta sale de `AUDIO_STORAGE_PATH` en el `.env` productivo.

### Configuracion del backend

- `.env` real del backend en servidor: `/srv/soundstream/app/backend/.env`

Variables especialmente sensibles:

- `DATABASE_URL`
- `JWT_SECRET`
- `AUDIO_STORAGE_PATH`
- `WEB_ORIGIN`
- `WEB_ORIGINS`

### Servicio del backend

- Archivo de servicio: `/etc/systemd/system/soundstream-backend.service`

### Configuracion de nginx

- Site file: `/etc/nginx/sites-available/soundstream.test`
- Site habilitado: `/etc/nginx/sites-enabled/soundstream.test`

### Base de datos

A nivel de aplicacion:

- host: `127.0.0.1`
- puerto: `5432`
- base logica: `soundstream`
- usuario configurado: `soundstream_user`

A nivel fisico en Ubuntu:

- no debes asumir la carpeta exacta a ciegas
- verifica la ruta real del cluster con:

```bash
sudo -u postgres psql -c "SHOW data_directory;"
```

Si el servidor se instalo con la configuracion por defecto de Ubuntu y PostgreSQL 18, es normal que el directorio sea algo como:

```text
/var/lib/postgresql/18/main
```

La comprobacion manda mas que la suposicion.

## 6. Como arranca realmente el sistema

### Backend

El backend arranca con `systemd`, no a mano desde una consola.

Comandos utiles:

```bash
sudo systemctl status soundstream-backend
sudo systemctl restart soundstream-backend
journalctl -u soundstream-backend -f
```

### Frontend web

El frontend web no se sirve con `flutter run` en el servidor.

Flujo real:

1. el repo se actualiza en la VM
2. se ejecuta `flutter build web`
3. el build queda en `flutter_client/build/web`
4. `nginx` sirve ese build

### nginx

`nginx` publica el frontend y reenvia:

- `/api/...` -> backend `127.0.0.1:3000`
- `/health` -> backend `127.0.0.1:3000/health`

Comandos utiles:

```bash
sudo systemctl status nginx
sudo nginx -t
sudo systemctl reload nginx
sudo tail -f /var/log/nginx/access.log /var/log/nginx/error.log
```

## 7. Flujo correcto de cambios

### Cambios de codigo

Hazlos en Windows:

1. editar codigo local
2. probar
3. `git add`, `git commit`, `git push`
4. entrar a la VM
5. `git pull` o correr el script de actualizacion

### Script de despliegue

En la VM:

```bash
cd /srv/soundstream/app
bash deploy/scripts/update_server.sh
```

Ese script:

- actualiza el repo
- ejecuta `npm ci`
- aplica `prisma:deploy`
- compila backend
- reinicia `soundstream-backend`
- ejecuta `flutter pub get`
- compila `flutter build web`
- valida y recarga `nginx`

## 8. Que pasa si la PC-servidor esta apagada

Si la PC donde vive la VM esta apagada:

- el entorno compartido deja de estar disponible
- `http://10.91.104.92` deja de responder
- la base de datos central ya no esta accesible
- los testers no pueden usar el servidor privado

Pero eso no impide seguir desarrollando.

Cada compañero puede trabajar localmente levantando:

- su propio backend local
- su propia base de datos PostgreSQL local
- su propio frontend Flutter local

El flujo local recomendado es el del `README.md`:

```powershell
cd backend
npm install
npm run prisma:generate
npm run prisma:migrate
npm run prisma:seed
npm run dev
```

Y en otra terminal:

```powershell
cd flutter_client
flutter pub get
flutter run -d chrome --web-port 5173 --dart-define=API_BASE_URL=http://localhost:3000/api
```

La regla practica es esta:

- servidor privado encendido -> pruebas compartidas e integracion
- servidor privado apagado -> desarrollo local por cada compañero

## 9. Que revisar si algo falla

### Caso 1: la pagina no abre

Orden recomendado:

1. comprobar ZeroTier y conectividad a `10.91.104.92`
2. revisar `nginx`
3. revisar firewall `ufw`
4. probar desde el mismo servidor con `curl`

Comandos:

```bash
sudo systemctl status nginx
sudo ufw status
sudo ss -tulpn | grep :80
curl http://127.0.0.1
curl http://10.91.104.92/health
```

### Caso 2: la web abre pero la API falla

Revisar:

- estado del backend
- logs del backend
- `WEB_ORIGIN` y `WEB_ORIGINS`

Comandos:

```bash
sudo systemctl status soundstream-backend
journalctl -u soundstream-backend -f
curl http://127.0.0.1:3000/health
cat /srv/soundstream/app/backend/.env
```

### Caso 3: error CORS en navegador

Normalmente significa que el frontend se esta sirviendo desde un origen no permitido.

En este proyecto:

- en produccion privada la web debe abrirse desde `http://10.91.104.92`
- el backend debe tener ese origen dentro de `WEB_ORIGINS`
- si usas `flutter run -d chrome`, estas en modo desarrollo local y cambia el origen

### Caso 4: no deja subir audio

Pistas comunes:

- `413 Request Entity Too Large`: lo devuelve `nginx`
- archivo mayor de `50 MB`: lo bloquea el backend por `multipart`

Puntos a revisar:

- `deploy/nginx/soundstream.test.conf` tiene `client_max_body_size 60m;`
- `backend/src/server.ts` limita `fileSize` a `50 * 1024 * 1024`

### Caso 5: login funciona pero no hay canciones

Esto no siempre es un bug.

El seed actual puede dejar el catalogo vacio porque el listado solo devuelve canciones:

- activas
- con `audioFile.isAvailable = true`

Si no se ha subido audio real, el catalogo puede aparecer vacio.

### Caso 6: la base de datos parece caida

Revisar:

```bash
sudo systemctl status postgresql
sudo ss -tulpn | grep 5432
sudo -u postgres psql
sudo -u postgres psql -c "SHOW data_directory;"
```

Si el backend no conecta, valida `DATABASE_URL` en:

```text
/srv/soundstream/app/backend/.env
```

## 10. Comandos de emergencia mas utiles

### Estado general

```bash
hostname -I
sudo ufw status
sudo ss -tulpn | grep -E ':80|:3000|:5432'
```

### Backend

```bash
sudo systemctl status soundstream-backend
sudo systemctl restart soundstream-backend
journalctl -u soundstream-backend -n 100 --no-pager
```

### nginx

```bash
sudo systemctl status nginx
sudo nginx -t
sudo systemctl reload nginx
sudo tail -f /var/log/nginx/access.log /var/log/nginx/error.log
```

### PostgreSQL

```bash
sudo systemctl status postgresql
sudo -u postgres psql -c "\\l"
sudo -u postgres psql -c "SHOW data_directory;"
```

### Verificar el sitio desde el mismo servidor

```bash
curl http://127.0.0.1/health
curl http://127.0.0.1/api/catalog/songs
curl http://10.91.104.92/health
```

## 11. Backups minimos recomendados

Si esto empieza a usarse de forma seria, al menos debes respaldar:

- la base de datos PostgreSQL
- la carpeta `/srv/soundstream/audio`
- el `.env` del backend de forma segura

Idea minima:

```bash
pg_dump -U soundstream_user -h 127.0.0.1 -d soundstream > soundstream.sql
```

Y aparte:

- copiar `/srv/soundstream/audio`

## 12. Regla mental para no perderse

Si algo falla, piensa en capas:

1. red ZeroTier
2. `nginx`
3. backend Fastify
4. PostgreSQL
5. archivos de audio
6. frontend Flutter

No intentes arreglar todo al mismo tiempo. Primero identifica en cual capa se rompio.

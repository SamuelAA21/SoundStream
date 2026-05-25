# Controladores Backend

### Controlador de Autenticación

El controlador `AuthController` se encarga de gestionar las operaciones relacionadas con el registro, inicio de sesión, renovación de tokens y cierre de sesión de los usuarios en la aplicación.

#### Obtener perfil del usuario autenticado

Endpoint: `GET /api/auth/me`

Este endpoint devuelve la información del usuario cuyo token JWT fue enviado en el header de autorización.

El controlador `AuthController` se encarga de procesar esta solicitud y realizar las siguientes operaciones:

1. Extraer el `sub` (ID del usuario) del token JWT validado por el middleware `requireAuth`.
2. Invocar `AuthService.me()` para consultar el usuario con su rol y perfil artístico en la base de datos.

**Ejemplo de respuesta:**

```json
{
  "id": "3",
  "name": "Demo User",
  "email": "demo@soundstream.local",
  "role": { "name": "user" },
  "artistProfile": null
}
```

#### Registrar usuario

Endpoint: `POST /api/auth/register`

Este endpoint permite crear una nueva cuenta de usuario o artista. Se espera recibir los siguientes datos en formato JSON:

* `name`: Nombre del usuario (mínimo 2, máximo 120 caracteres).
* `email`: Correo electrónico único (máximo 150 caracteres).
* `password`: Contraseña (mínimo 8, máximo 100 caracteres).
* `accountType`: Tipo de cuenta, `"user"` o `"artist"` (por defecto `"user"`).
* `artistName`: Nombre artístico, requerido si `accountType` es `"artist"`.

El controlador valida el cuerpo con Zod antes de delegar al servicio. Si el `accountType` es `"artist"`, el servicio crea también un registro en la tabla `artists` vinculado al usuario.

**Ejemplo de solicitud:**

```json
{
  "name": "Samuel Herrera",
  "email": "samuel@ejemplo.com",
  "password": "MiClave123",
  "accountType": "artist",
  "artistName": "SamuelArt"
}
```

**Ejemplo de respuesta:**

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "a1b2c3d4e5f6...",
  "user": {
    "id": "5",
    "name": "Samuel Herrera",
    "role": { "name": "artist" }
  }
}
```

#### Iniciar sesión

Endpoint: `POST /api/auth/login`

Este endpoint autentica al usuario y retorna los tokens de sesión. Se espera recibir:

* `email`: Correo electrónico del usuario.
* `password`: Contraseña del usuario.

El controlador valida el cuerpo con Zod, invoca `AuthService.login()` que verifica la contraseña con bcrypt, genera el token de acceso (expiración 15 minutos) y el refresh token (expiración 30 días), y persiste el hash del refresh token en la base de datos.

**Ejemplo de solicitud:**

```json
{
  "email": "demo@soundstream.local",
  "password": "Demo12345"
}
```

**Ejemplo de respuesta:**

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "a1b2c3d4e5f6...",
  "user": {
    "id": "3",
    "name": "Demo User",
    "role": { "name": "user" }
  }
}
```

#### Renovar token

Endpoint: `POST /api/auth/refresh`

Este endpoint renueva el token de acceso usando un refresh token válido. El refresh token anterior queda revocado y se emite uno nuevo (rotación de tokens).

* `refreshToken`: Token de refresco activo (mínimo 32 caracteres).

**Ejemplo de respuesta:**

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "nuevo_token_xyz..."
}
```

#### Cerrar sesión

Endpoint: `POST /api/auth/logout`

Este endpoint revoca el refresh token activo, impidiendo su uso futuro para renovar la sesión.

* `refreshToken`: Token de refresco a revocar.

**Ejemplo de respuesta:**

```json
{ "ok": true }
```

---

### Controlador de Catálogo

El controlador `CatalogController` se encarga de exponer el catálogo musical público de la aplicación, permitiendo listar y consultar canciones y álbumes sin requerir autenticación.

#### Listar canciones

Endpoint: `GET /api/catalog/songs`

Este endpoint devuelve la lista paginada de canciones activas con audio disponible. Acepta los parámetros de consulta `q` para búsqueda por texto, `page` y `limit` para paginación.

El controlador invoca `CatalogService.listSongs()`, que filtra únicamente canciones con `isActive: true` y `audioFile.isAvailable: true`, realizando búsqueda insensible a mayúsculas en título, nombre del artista y nombre del género.

**Ejemplo de respuesta:**

```json
{
  "data": [
    {
      "id": "1",
      "title": "Canción Ejemplo",
      "durationSeconds": 210,
      "artist": { "id": "1", "name": "Artista Demo" },
      "album": { "id": "1", "title": "Álbum Demo" },
      "genre": { "id": "1", "name": "Rock" },
      "collaborators": []
    }
  ],
  "pagination": { "page": 1, "limit": 20, "total": 1 }
}
```

#### Obtener detalle de canción

Endpoint: `GET /api/catalog/songs/{songId}`

Este endpoint devuelve el detalle completo de una canción específica incluyendo su archivo de audio y colaboradores.

**Ejemplo de respuesta:**

```json
{
  "id": "1",
  "title": "Canción Ejemplo",
  "durationSeconds": 210,
  "artist": { "id": "1", "name": "Artista Demo" },
  "album": { "id": "1", "title": "Álbum Demo" },
  "genre": { "id": "1", "name": "Rock" },
  "audioFile": { "mimeType": "audio/mpeg", "fileSizeBytes": 8400000 },
  "collaborators": []
}
```

#### Listar álbumes

Endpoint: `GET /api/catalog/albums`

Este endpoint devuelve todos los álbumes con su artista, género y conteo de canciones.

**Ejemplo de respuesta:**

```json
[
  {
    "id": "1",
    "title": "Álbum Demo",
    "releaseDate": "2024-01-15",
    "artist": { "id": "1", "name": "Artista Demo" },
    "genre": { "id": "1", "name": "Rock" },
    "_count": { "songs": 5 }
  }
]
```

#### Obtener detalle de álbum

Endpoint: `GET /api/catalog/albums/{albumId}`

Este endpoint devuelve un álbum con su lista completa de canciones activas ordenadas por título.

**Ejemplo de respuesta:**

```json
{
  "id": "1",
  "title": "Álbum Demo",
  "songs": [
    { "id": "1", "title": "Canción 1", "durationSeconds": 200 }
  ]
}
```

---

### Controlador de Favoritos

El controlador `FavoriteController` se encarga de gestionar la lista de canciones favoritas del usuario autenticado. Todas sus rutas requieren autenticación mediante JWT.

#### Listar favoritos

Endpoint: `GET /api/favorites`

Este endpoint devuelve todas las canciones favoritas del usuario autenticado, ordenadas por fecha de agregado más reciente.

**Ejemplo de respuesta:**

```json
[
  {
    "songId": "1",
    "createdAt": "2024-05-10T14:30:00.000Z",
    "song": {
      "id": "1",
      "title": "Canción Favorita",
      "artist": { "id": "1", "name": "Artista Demo" }
    }
  }
]
```

#### Agregar favorito

Endpoint: `POST /api/favorites/{songId}`

Este endpoint agrega una canción a la lista de favoritos del usuario. El controlador valida que el `songId` sea numérico con Zod antes de delegar al servicio.

**Ejemplo de respuesta:**

```json
{ "ok": true }
```

#### Eliminar favorito

Endpoint: `DELETE /api/favorites/{songId}`

Este endpoint elimina una canción de la lista de favoritos del usuario autenticado.

**Ejemplo de respuesta:**

```json
{ "ok": true }
```

---

### Controlador de Playlists

El controlador `PlaylistController` gestiona la creación y administración de playlists del usuario autenticado. Todas sus rutas requieren autenticación.

#### Listar playlists

Endpoint: `GET /api/playlists`

Devuelve todas las playlists del usuario ordenadas por fecha de creación descendente.

**Ejemplo de respuesta:**

```json
[
  {
    "id": "1",
    "name": "Mi Playlist",
    "isPublic": false,
    "createdAt": "2024-05-01T10:00:00.000Z",
    "songs": []
  }
]
```

#### Crear playlist

Endpoint: `POST /api/playlists`

Este endpoint crea una nueva playlist. Se espera recibir:

* `name`: Nombre de la playlist (mínimo 2, máximo 150 caracteres).
* `description`: Descripción opcional (máximo 255 caracteres).
* `isPublic`: Visibilidad de la playlist (por defecto `false`).

**Ejemplo de solicitud:**

```json
{
  "name": "Mis Favoritos de Rock",
  "description": "Lo mejor del rock clásico",
  "isPublic": true
}
```

**Ejemplo de respuesta:**

```json
{
  "id": "2",
  "name": "Mis Favoritos de Rock",
  "isPublic": true,
  "songs": []
}
```

#### Obtener detalle de playlist

Endpoint: `GET /api/playlists/{playlistId}`

Devuelve el detalle de una playlist con sus canciones ordenadas por posición.

**Ejemplo de respuesta:**

```json
{
  "id": "1",
  "name": "Mis Favoritos de Rock",
  "songs": [
    {
      "position": 1,
      "song": { "id": "3", "title": "Canción Ejemplo", "durationSeconds": 200 }
    }
  ]
}
```

#### Agregar canción a playlist

Endpoint: `POST /api/playlists/{playlistId}/songs/{songId}`

Agrega una canción al final de la playlist. El controlador valida que ambos IDs sean numéricos.

**Ejemplo de respuesta:**

```json
{ "ok": true }
```

#### Eliminar canción de playlist

Endpoint: `DELETE /api/playlists/{playlistId}/songs/{songId}`

Elimina una canción de una playlist del usuario autenticado.

**Ejemplo de respuesta:**

```json
{ "ok": true }
```

---

### Controlador de Historial

El controlador `HistoryController` gestiona el registro de reproducciones e interacciones del usuario, datos que alimentan el motor de recomendaciones. Todas sus rutas requieren autenticación.

#### Listar historial

Endpoint: `GET /api/history`

Devuelve las últimas 50 reproducciones del usuario ordenadas por fecha descendente.

**Ejemplo de respuesta:**

```json
[
  {
    "id": "10",
    "startedAt": "2024-05-20T22:00:00.000Z",
    "playedSeconds": 195,
    "completionRate": 93,
    "deviceType": "web",
    "song": {
      "id": "1",
      "title": "Canción Ejemplo",
      "artist": { "id": "1", "name": "Artista Demo" }
    }
  }
]
```

#### Registrar reproducción

Endpoint: `POST /api/history/plays`

Este endpoint registra una reproducción. Se espera recibir:

* `songId`: ID numérico de la canción.
* `playedSeconds`: Segundos reproducidos (entero mayor o igual a 0).
* `completionRate`: Porcentaje completado (número entre 0 y 100).
* `deviceType`: Dispositivo desde donde se reprodujo, `"web"` o `"android"`.

El controlador valida el cuerpo con Zod y delega al servicio. Si `completionRate` es igual o mayor a 80, el servicio emite el evento `song.played` al `DomainEventBus`, que dispara automáticamente un recálculo de recomendaciones.

**Ejemplo de solicitud:**

```json
{
  "songId": "1",
  "playedSeconds": 195,
  "completionRate": 93,
  "deviceType": "web"
}
```

**Ejemplo de respuesta:**

```json
{ "ok": true }
```

#### Registrar interacción

Endpoint: `POST /api/history/interactions`

Este endpoint registra un evento de interacción para alimentar el motor de recomendaciones. Se espera recibir:

* `interactionType`: Tipo de evento. Valores válidos: `search`, `play`, `pause`, `resume`, `skip_forward`, `skip_backward`, `favorite`, `unfavorite`, `playlist_add`, `playlist_remove`, `recommendation_click`.
* `songId`: ID de la canción relacionada (opcional según el tipo).
* `interactionValue`: Valor adicional como el texto buscado (opcional, máximo 255 caracteres).
* `metadata`: Datos libres en formato JSON (opcional).

**Ejemplo de solicitud:**

```json
{
  "songId": "1",
  "interactionType": "favorite",
  "interactionValue": null
}
```

**Ejemplo de respuesta:**

```json
{ "ok": true }
```

---

### Controlador de Recomendaciones

El controlador `RecommendationController` expone el sistema de recomendaciones personalizadas. Todas sus rutas requieren autenticación.

#### Obtener recomendaciones

Endpoint: `GET /api/recommendations`

Devuelve las recomendaciones activas del usuario, ordenadas por puntuación descendente, con un máximo de 20 resultados. Las recomendaciones tienen una vigencia de 24 horas.

El controlador invoca `RecommendationService.list()`, que consulta las recomendaciones almacenadas que aún no han expirado.

**Ejemplo de respuesta:**

```json
[
  {
    "id": "5",
    "score": 87.5,
    "source": "hybrid",
    "reasonText": "Basado en tu historial de Rock",
    "expiresAt": "2024-05-21T22:00:00.000Z",
    "song": {
      "id": "7",
      "title": "Canción Recomendada",
      "artist": { "id": "2", "name": "Otro Artista" },
      "genre": { "id": "1", "name": "Rock" }
    }
  }
]
```

#### Refrescar recomendaciones

Endpoint: `POST /api/recommendations/refresh`

Fuerza un recálculo inmediato de las recomendaciones del usuario. El controlador invoca `RecommendationService.refresh()`, que ejecuta el motor completo: construye señales desde historial y favoritos, puntúa candidatos no escuchados y reemplaza las recomendaciones anteriores en una única transacción.

**Ejemplo de respuesta:**

```json
{ "ok": true }
```

---

### Controlador de Streaming

El controlador `StreamingController` gestiona la entrega autenticada de archivos de audio con soporte de HTTP Range Requests.

#### Reproducir canción

Endpoint: `GET /api/stream/songs/{songId}`

Este endpoint entrega los bytes del archivo de audio de una canción activa. El controlador aplica el middleware `requireAuth` directamente en la definición de la ruta.

El controlador realiza las siguientes operaciones:

1. Validar el `songId` como numérico con Zod.
2. Leer el header `Range` de la petición si está presente.
3. Invocar `StreamingService.prepareStream()` que verifica la existencia de la canción, localiza el archivo en disco y calcula el fragmento solicitado.
4. Configurar los headers de respuesta: `Content-Type`, `Accept-Ranges`, `Content-Length`, `Cache-Control`, `X-Content-Type-Options` y `Content-Disposition`.
5. Si la petición incluía `Range`, agregar el header `Content-Range` y responder con status `206 Partial Content`; de lo contrario responder `200 OK`.
6. Enviar el stream del archivo al cliente.

**Ejemplo de respuesta (sin Range):**

```
HTTP/1.1 200 OK
Content-Type: audio/mpeg
Content-Length: 8400000
Accept-Ranges: bytes
Cache-Control: no-store, no-cache, must-revalidate
```

**Ejemplo de respuesta (con Range):**

```
HTTP/1.1 206 Partial Content
Content-Type: audio/mpeg
Content-Length: 1048576
Content-Range: bytes 0-1048575/8400000
Accept-Ranges: bytes
```

---

### Controlador de Artista

El controlador `ArtistController` gestiona las operaciones propias del artista autenticado: subida de canciones, publicación, eliminación y gestión de álbumes. Todas sus rutas aplican el middleware `requireArtist` que verifica que el usuario tenga rol `artist`.

#### Listar canciones propias

Endpoint: `GET /api/artist/songs`

Devuelve todas las canciones del artista autenticado con su álbum y género.

**Ejemplo de respuesta:**

```json
[
  {
    "id": "1",
    "title": "Mi Canción",
    "durationSeconds": 210,
    "isActive": true,
    "album": { "id": "1", "title": "Mi Álbum" },
    "genre": { "id": "1", "name": "Rock" }
  }
]
```

#### Listar álbumes propios

Endpoint: `GET /api/artist/albums`

Devuelve todos los álbumes del artista autenticado.

**Ejemplo de respuesta:**

```json
[
  {
    "id": "1",
    "title": "Mi Álbum",
    "releaseDate": "2024-01-01"
  }
]
```

#### Subir canción

Endpoint: `POST /api/artist/songs`

Este endpoint permite al artista subir una nueva canción con su archivo de audio. La petición debe ser `multipart/form-data`. El controlador itera los partes del formulario acumulando los campos de texto y procesando el archivo cuando encuentra la parte `audioFile`.

Se esperan los siguientes campos:

* `title`: Título de la canción.
* `durationSeconds`: Duración en segundos.
* `genreName`: Nombre del género (si no existe se crea automáticamente).
* `albumId`: ID del álbum (opcional).
* `audioFile`: Archivo de audio (requerido, máximo 50 MB).

La canción se crea con `isActive: false`. El artista debe publicarla explícitamente con el endpoint de publicación.

**Ejemplo de respuesta:**

```json
{
  "id": "5",
  "title": "Nueva Canción",
  "durationSeconds": 210,
  "isActive": false
}
```

#### Publicar o despublicar canción

Endpoint: `PATCH /api/artist/songs/{songId}/publication`

Permite al artista cambiar el estado de publicación de una canción propia. El controlador valida que el `songId` pertenezca al artista autenticado.

* `isPublished`: `true` para publicar, `false` para despublicar.

**Ejemplo de solicitud:**

```json
{ "isPublished": true }
```

**Ejemplo de respuesta:**

```json
{ "id": "5", "isActive": true }
```

#### Eliminar canción

Endpoint: `DELETE /api/artist/songs/{songId}`

Elimina una canción propia del artista. El servicio verifica que la canción pertenezca al artista antes de eliminarla.

**Ejemplo de respuesta:**

```json
{ "ok": true }
```

#### Asignar canción a álbum

Endpoint: `PATCH /api/artist/songs/{songId}/album`

Asigna o desvincula una canción de un álbum. Enviar `albumId: null` desvincula la canción de cualquier álbum.

**Ejemplo de solicitud:**

```json
{ "albumId": "2" }
```

**Ejemplo de respuesta:**

```json
{ "ok": true }
```

#### Crear álbum

Endpoint: `POST /api/artist/albums`

Permite al artista crear un nuevo álbum y opcionalmente asignar canciones propias al momento de la creación.

* `title`: Título del álbum (mínimo 2, máximo 180 caracteres).
* `genreName`: Nombre del género (opcional).
* `songIds`: Lista de IDs de canciones a incluir (opcional).

**Ejemplo de solicitud:**

```json
{
  "title": "Mi Nuevo Álbum",
  "genreName": "Rock",
  "songIds": ["1", "2", "3"]
}
```

**Ejemplo de respuesta:**

```json
{ "id": "3", "title": "Mi Nuevo Álbum" }
```

---

### Controlador de Administración

Los controladores de administración (`AdminSongController`, `AdminAlbumController`, `AdminUserController`) gestionan las operaciones privilegiadas del sistema. Todas las rutas aplican el middleware `requireAdmin` que verifica el rol `admin`.

#### Listar usuarios

Endpoint: `GET /api/admin/users`

Devuelve la lista completa de usuarios del sistema con su rol, estado y fecha de creación.

**Ejemplo de respuesta:**

```json
[
  {
    "id": "1",
    "name": "Admin",
    "email": "admin@soundstream.local",
    "status": "active",
    "role": { "name": "admin" },
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
]
```

#### Actualizar estado de usuario

Endpoint: `PATCH /api/admin/users/{userId}/status`

Permite activar o suspender una cuenta de usuario.

* `status`: `"active"` o `"suspended"`.

**Ejemplo de solicitud:**

```json
{ "status": "suspended" }
```

**Ejemplo de respuesta:**

```json
{ "ok": true }
```

#### Subir canción como administrador

Endpoint: `POST /api/admin/songs`

Permite al administrador subir una canción para cualquier artista del sistema. La petición debe ser `multipart/form-data`. El controlador sigue el mismo flujo de iteración de partes que el controlador de artista.

Se esperan los siguientes campos:

* `title`: Título de la canción.
* `artistId`: ID numérico del artista destino.
* `durationSeconds`: Duración en segundos.
* `genreName`: Nombre del género (opcional).
* `albumId`: ID del álbum (opcional).
* `audioFile`: Archivo de audio (requerido, máximo 50 MB).

**Ejemplo de respuesta:**

```json
{ "id": "10", "title": "Canción Admin", "isActive": false }
```

#### Eliminar canción

Endpoint: `DELETE /api/admin/songs/{songId}`

Elimina cualquier canción del sistema independientemente del artista al que pertenezca.

**Ejemplo de respuesta:**

```json
{ "ok": true }
```

#### Asignar canción a álbum

Endpoint: `PATCH /api/admin/songs/{songId}/album`

Asigna o desvincula cualquier canción de un álbum. Enviar `albumId: null` desvincula la canción.

**Ejemplo de respuesta:**

```json
{ "ok": true }
```

#### Crear álbum

Endpoint: `POST /api/admin/albums`

Permite al administrador crear un álbum para cualquier artista del sistema.

* `title`: Título del álbum.
* `artistId`: ID numérico del artista.
* `genreName`: Nombre del género (opcional).
* `releaseDate`: Fecha de lanzamiento (opcional).

**Ejemplo de solicitud:**

```json
{
  "title": "Álbum Nuevo",
  "artistId": "2",
  "genreName": "Jazz",
  "releaseDate": "2024-06-01"
}
```

**Ejemplo de respuesta:**

```json
{ "id": "5", "title": "Álbum Nuevo" }
```

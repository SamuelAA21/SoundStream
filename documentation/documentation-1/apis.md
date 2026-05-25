# Api's

GET /api/auth/me

```
Descripción:
Este endpoint devuelve la información del usuario autenticado.

Parámetros:
- Ninguno

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token>

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Perfil del usuario autenticado con su rol y perfil artístico
```

POST /api/auth/register

```
Descripción:
Este endpoint permite registrar una nueva cuenta de usuario o artista.

Parámetros:
- name: Nombre del usuario (mínimo 2, máximo 120 caracteres)
- email: Correo electrónico único (máximo 150 caracteres)
- password: Contraseña (mínimo 8, máximo 100 caracteres)
- accountType: Tipo de cuenta, "user" o "artist" (por defecto "user")
- artistName: Nombre artístico, requerido si accountType es "artist"

Respuesta exitosa:
Código de estado: 201 (Created)
Cuerpo de la respuesta: Token de acceso, refresh token y datos del usuario creado
```

POST /api/auth/login

```
Descripción:
Este endpoint autentica al usuario y retorna los tokens de sesión.

Parámetros:
- email: Correo electrónico del usuario
- password: Contraseña del usuario

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Token de acceso (expira en 15 minutos), refresh token (expira en 30 días) y datos del usuario
```

POST /api/auth/refresh

```
Descripción:
Este endpoint renueva el token de acceso usando un refresh token válido.
El refresh token anterior queda revocado y se emite uno nuevo.

Parámetros:
- refreshToken: Token de refresco activo (mínimo 32 caracteres)

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Nuevo token de acceso y nuevo refresh token
```

POST /api/auth/logout

```
Descripción:
Este endpoint revoca el refresh token activo cerrando la sesión del usuario.

Parámetros:
- refreshToken: Token de refresco a revocar

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Confirmación de cierre de sesión
```

---

GET /api/catalog/songs

```
Descripción:
Este endpoint devuelve la lista de canciones activas con audio disponible.
No requiere autenticación.

Parámetros:
- q: Texto de búsqueda en título, artista y género (opcional)
- page: Número de página (opcional, por defecto 1)
- limit: Resultados por página (opcional, por defecto 20)

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Lista paginada de canciones con artista, álbum, género y colaboradores
```

GET /api/catalog/songs/{songId}

```
Descripción:
Este endpoint devuelve el detalle completo de una canción específica.
No requiere autenticación.

Parámetros:
- songId: ID numérico de la canción

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Detalle de la canción con artista, álbum, género, archivo de audio y colaboradores
```

GET /api/catalog/albums

```
Descripción:
Este endpoint devuelve la lista de todos los álbumes con conteo de canciones.
No requiere autenticación.

Parámetros:
- Ninguno

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Lista de álbumes con artista, género y conteo de canciones
```

GET /api/catalog/albums/{albumId}

```
Descripción:
Este endpoint devuelve el detalle de un álbum con su lista de canciones activas.
No requiere autenticación.

Parámetros:
- albumId: ID numérico del álbum

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Detalle del álbum con lista de canciones ordenadas por título
```

---

GET /api/favorites

```
Descripción:
Este endpoint devuelve la lista de canciones favoritas del usuario autenticado,
ordenadas por fecha de agregado más reciente.

Parámetros:
- Ninguno

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token>

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Lista de favoritos con detalle de cada canción
```

POST /api/favorites/{songId}

```
Descripción:
Este endpoint agrega una canción a la lista de favoritos del usuario autenticado.

Parámetros:
- songId: ID numérico de la canción

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token>

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Confirmación de canción agregada a favoritos
```

DELETE /api/favorites/{songId}

```
Descripción:
Este endpoint elimina una canción de la lista de favoritos del usuario autenticado.

Parámetros:
- songId: ID numérico de la canción

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token>

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Confirmación de canción eliminada de favoritos
```

---

GET /api/playlists

```
Descripción:
Este endpoint devuelve la lista de playlists del usuario autenticado,
ordenadas por fecha de creación más reciente.

Parámetros:
- Ninguno

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token>

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Lista de playlists del usuario
```

POST /api/playlists

```
Descripción:
Este endpoint permite crear una nueva playlist para el usuario autenticado.

Parámetros:
- name: Nombre de la playlist (mínimo 2, máximo 150 caracteres)
- description: Descripción opcional (máximo 255 caracteres)
- isPublic: Indica si la playlist es pública (por defecto false)

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token>

Respuesta exitosa:
Código de estado: 201 (Created)
Cuerpo de la respuesta: Playlist creada
```

GET /api/playlists/{playlistId}

```
Descripción:
Este endpoint devuelve el detalle de una playlist con sus canciones ordenadas por posición.

Parámetros:
- playlistId: ID numérico de la playlist

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token>

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Detalle de la playlist con canciones ordenadas por posición
```

POST /api/playlists/{playlistId}/songs/{songId}

```
Descripción:
Este endpoint agrega una canción al final de una playlist del usuario autenticado.

Parámetros:
- playlistId: ID numérico de la playlist
- songId: ID numérico de la canción

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token>

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Confirmación de canción agregada a la playlist
```

DELETE /api/playlists/{playlistId}/songs/{songId}

```
Descripción:
Este endpoint elimina una canción de una playlist del usuario autenticado.

Parámetros:
- playlistId: ID numérico de la playlist
- songId: ID numérico de la canción

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token>

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Confirmación de canción eliminada de la playlist
```

---

GET /api/history

```
Descripción:
Este endpoint devuelve las últimas 50 reproducciones del usuario autenticado,
ordenadas por fecha descendente.

Parámetros:
- Ninguno

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token>

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Lista de reproducciones con canción, artista, género, segundos reproducidos y porcentaje de completitud
```

POST /api/history/plays

```
Descripción:
Este endpoint registra una reproducción completada o parcial.
Si el porcentaje de completitud es igual o mayor a 80, el sistema
dispara automáticamente un recálculo de recomendaciones.

Parámetros:
- songId: ID numérico de la canción reproducida
- playedSeconds: Segundos efectivamente reproducidos (entero mayor o igual a 0)
- completionRate: Porcentaje de la canción completado (número entre 0 y 100)
- deviceType: Dispositivo desde donde se reprodujo, "web" o "android" (por defecto "web")

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token>

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Confirmación de reproducción registrada
```

POST /api/history/interactions

```
Descripción:
Este endpoint registra un evento de interacción del usuario para alimentar
el motor de recomendaciones. Los tipos de interacción incluyen: search, play,
pause, resume, skip_forward, skip_backward, favorite, unfavorite,
playlist_add, playlist_remove y recommendation_click.

Parámetros:
- interactionType: Tipo de interacción (requerido)
- songId: ID numérico de la canción relacionada (opcional según el tipo)
- interactionValue: Valor asociado a la interacción, por ejemplo el texto buscado (opcional)
- metadata: Datos adicionales en formato JSON libre (opcional)

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token>

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Confirmación de interacción registrada
```

---

GET /api/recommendations

```
Descripción:
Este endpoint devuelve las recomendaciones activas del usuario autenticado,
ordenadas por puntuación descendente. Retorna un máximo de 20 recomendaciones
con una vigencia de 24 horas desde su generación.

Parámetros:
- Ninguno

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token>

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Lista de recomendaciones con puntuación, motivo y detalle de cada canción
```

POST /api/recommendations/refresh

```
Descripción:
Este endpoint fuerza un recálculo inmediato de las recomendaciones del usuario.
Normalmente el recálculo ocurre automáticamente al completar una canción.

Parámetros:
- Ninguno

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token>

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Confirmación de recomendaciones actualizadas
```

---

GET /api/stream/songs/{songId}

```
Descripción:
Este endpoint entrega el archivo de audio de una canción activa.
Soporta HTTP Range Requests para reproducción por fragmentos.
Los archivos no se exponen como rutas públicas; cada petición valida el token JWT.

Parámetros:
- songId: ID numérico de la canción

Headers opcionales:
- Range: Fragmento solicitado en formato bytes=inicio-fin

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token>

Respuesta exitosa:
Código de estado: 200 (OK) para archivo completo
Código de estado: 206 (Partial Content) si se envió header Range
Cuerpo de la respuesta: Bytes del archivo de audio con Content-Type, Content-Length y Accept-Ranges
```

---

GET /api/artist/songs

```
Descripción:
Este endpoint devuelve la lista de canciones propias del artista autenticado.

Parámetros:
- Ninguno

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token> con rol artista

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Lista de canciones del artista con álbum y género
```

GET /api/artist/albums

```
Descripción:
Este endpoint devuelve la lista de álbumes propios del artista autenticado.

Parámetros:
- Ninguno

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token> con rol artista

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Lista de álbumes del artista
```

POST /api/artist/songs

```
Descripción:
Este endpoint permite al artista subir una nueva canción con su archivo de audio.
La canción se crea como inactiva y debe publicarse explícitamente.

Parámetros (multipart/form-data):
- title: Título de la canción
- durationSeconds: Duración en segundos
- genreName: Nombre del género (si no existe se crea automáticamente)
- albumId: ID numérico del álbum (opcional)
- audioFile: Archivo de audio (requerido, máximo 50 MB)

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token> con rol artista

Respuesta exitosa:
Código de estado: 201 (Created)
Cuerpo de la respuesta: Canción creada con estado inactivo
```

PATCH /api/artist/songs/{songId}/publication

```
Descripción:
Este endpoint permite al artista publicar o despublicar una canción propia.

Parámetros:
- songId: ID numérico de la canción
- isPublished: true para publicar, false para despublicar

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token> con rol artista

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Canción con estado de publicación actualizado
```

DELETE /api/artist/songs/{songId}

```
Descripción:
Este endpoint permite al artista eliminar una canción propia.

Parámetros:
- songId: ID numérico de la canción

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token> con rol artista

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Confirmación de canción eliminada
```

PATCH /api/artist/songs/{songId}/album

```
Descripción:
Este endpoint permite al artista asignar o desvincular una canción de un álbum.
Enviar albumId con valor null desvincula la canción de cualquier álbum.

Parámetros:
- songId: ID numérico de la canción
- albumId: ID numérico del álbum o null para desvincular

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token> con rol artista

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Confirmación de asignación actualizada
```

POST /api/artist/albums

```
Descripción:
Este endpoint permite al artista crear un nuevo álbum y opcionalmente
asignar canciones propias al momento de la creación.

Parámetros:
- title: Título del álbum (mínimo 2, máximo 180 caracteres)
- genreName: Nombre del género (opcional, máximo 100 caracteres)
- songIds: Lista de IDs de canciones a incluir (opcional)

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token> con rol artista

Respuesta exitosa:
Código de estado: 201 (Created)
Cuerpo de la respuesta: Álbum creado
```

---

GET /api/admin/users

```
Descripción:
Este endpoint devuelve la lista de todos los usuarios del sistema.

Parámetros:
- Ninguno

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token> con rol administrador

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Lista de usuarios con rol, estado y fecha de creación
```

PATCH /api/admin/users/{userId}/status

```
Descripción:
Este endpoint permite al administrador activar o suspender una cuenta de usuario.

Parámetros:
- userId: ID numérico del usuario
- status: "active" para activar o "suspended" para suspender

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token> con rol administrador

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Confirmación de estado actualizado
```

POST /api/admin/songs

```
Descripción:
Este endpoint permite al administrador subir una canción para cualquier artista del sistema.

Parámetros (multipart/form-data):
- title: Título de la canción
- artistId: ID numérico del artista destino
- durationSeconds: Duración en segundos
- genreName: Nombre del género (opcional)
- albumId: ID numérico del álbum (opcional)
- audioFile: Archivo de audio (requerido, máximo 50 MB)

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token> con rol administrador

Respuesta exitosa:
Código de estado: 201 (Created)
Cuerpo de la respuesta: Canción creada
```

DELETE /api/admin/songs/{songId}

```
Descripción:
Este endpoint permite al administrador eliminar cualquier canción del sistema.

Parámetros:
- songId: ID numérico de la canción

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token> con rol administrador

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Confirmación de canción eliminada
```

PATCH /api/admin/songs/{songId}/album

```
Descripción:
Este endpoint permite al administrador asignar o desvincular cualquier canción de un álbum.
Enviar albumId con valor null desvincula la canción de su álbum actual.

Parámetros:
- songId: ID numérico de la canción
- albumId: ID numérico del álbum o null para desvincular

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token> con rol administrador

Respuesta exitosa:
Código de estado: 200 (OK)
Cuerpo de la respuesta: Confirmación de asignación actualizada
```

POST /api/admin/albums

```
Descripción:
Este endpoint permite al administrador crear un álbum para cualquier artista del sistema.

Parámetros:
- title: Título del álbum
- artistId: ID numérico del artista
- genreName: Nombre del género (opcional)
- releaseDate: Fecha de lanzamiento (opcional)

Autenticación:
- Requiere token JWT en header Authorization: Bearer <token> con rol administrador

Respuesta exitosa:
Código de estado: 201 (Created)
Cuerpo de la respuesta: Álbum creado
```

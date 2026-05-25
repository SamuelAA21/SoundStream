# Repositorios

Los repositorios son la capa más baja de la arquitectura backend de SoundStream. Cada repositorio encapsula todas las consultas a la base de datos de su módulo, utilizando Prisma como ORM sobre PostgreSQL. Ninguna otra capa del sistema toca Prisma directamente: los servicios reciben datos a través de los métodos del repositorio correspondiente.

---

## AuthRepository

Gestiona usuarios, roles y tokens de refresco.

#### findUserByEmail

Busca un usuario por su dirección de correo electrónico. Incluye el rol y el perfil de artista asociado.

#### findUserById

Busca un usuario por su identificador numérico. Incluye rol y perfil de artista.

#### createUser

Crea un nuevo usuario con nombre, correo, hash de contraseña y rol. Si se proporciona `artistName`, crea además un perfil de artista vinculado en la misma operación.

#### updateLastLogin

Actualiza el campo `lastLoginAt` del usuario al momento actual.

#### findRoleByName

Consulta un rol por su nombre (`user`, `artist`, `admin`).

#### saveRefreshToken

Persiste un token de refresco con su hash SHA-256, el identificador de usuario y la fecha de expiración.

#### findRefreshToken

Recupera un token de refresco por su hash. Incluye el usuario con su rol y perfil de artista para evitar una segunda consulta durante la rotación.

#### revokeRefreshToken

Marca un token de refresco como revocado estableciendo `revokedAt` al momento actual.

---

## CatalogRepository

Acceso de solo lectura al catálogo musical público.

#### listSongs

Devuelve canciones activas con archivo de audio disponible. Acepta una cadena de búsqueda opcional que filtra por título, nombre de artista o género, usando comparación insensible a mayúsculas. Soporta paginación con `skip` y `limit`.

#### findSong

Recupera una canción activa por su identificador, incluyendo artista, álbum, género, archivo de audio y colaboradores.

#### listAlbums

Lista todos los álbumes del sistema incluyendo artista, género y conteo de canciones.

#### findAlbum

Recupera un álbum completo por su identificador, con todas sus canciones activas ordenadas alfabéticamente.

---

## FavoriteRepository

Gestiona la lista de canciones favoritas de cada usuario.

#### add

Crea un registro de favorito para un par `(userId, songId)`.

#### findSong

Verifica que una canción existe, está activa y tiene audio disponible antes de agregarla a favoritos.

#### remove

Elimina el registro de favorito para un par `(userId, songId)`.

#### list

Devuelve todos los favoritos del usuario con información completa de cada canción, ordenados por fecha de creación descendente.

---

## PlaylistRepository

Gestiona playlists y su contenido.

#### create

Crea una playlist con nombre, descripción opcional y visibilidad (`isPublic`).

#### listByUser

Lista todas las playlists de un usuario ordenadas por fecha de creación descendente.

#### findOwned

Busca una playlist verificando que pertenece al usuario solicitante. Incluye las canciones ordenadas por posición con sus relaciones completas.

#### findSong

Verifica que una canción existe y está disponible antes de agregarla a una playlist.

#### nextPosition

Calcula la siguiente posición disponible en una playlist consultando la posición máxima actual.

#### addSong

Agrega una canción a una playlist en la posición indicada.

#### removeSong

Elimina una canción de una playlist.

---

## HistoryRepository

Registra reproducciones e interacciones del usuario.

#### registerPlay

Persiste un registro de reproducción con duración en segundos, tasa de completitud y tipo de dispositivo (`web` o `android`).

#### registerInteraction

Persiste una interacción de usuario (play, skip, like, etc.) con metadatos opcionales en formato JSON.

#### list

Devuelve las últimas 50 reproducciones del usuario ordenadas por fecha descendente, con información de canción y género.

---

## RecommendationRepository

Construye y persiste recomendaciones personalizadas.

#### getActive

Devuelve hasta 20 recomendaciones vigentes del usuario (sin fecha de expiración o con fecha futura), ordenadas por puntuación descendente.

#### buildSignals

Construye las señales de comportamiento del usuario agregando las últimas 100 reproducciones, todos los favoritos y las últimas 100 interacciones. Agrupa los datos por combinación `(genreId, artistId)` contabilizando `playCount`, `favoriteCount` e `interactionCount`.

#### selectCandidates

Recupera hasta 200 canciones activas y disponibles que el usuario no ha escuchado anteriormente, como candidatos para el motor de recomendaciones.

#### replaceForUser

Reemplaza atómicamente todas las recomendaciones existentes del usuario con un nuevo conjunto de hasta 20 ítems, usando una transacción Prisma. Las recomendaciones nuevas expiran a las 24 horas.

---

## StreamingRepository

Acceso a canciones para el módulo de streaming.

#### findStreamableSong

Busca una canción que esté activa y con archivo de audio disponible, incluyendo los datos del archivo de audio (ruta en disco, tipo MIME, tamaño).

#### registerPlayInteraction

Registra una interacción de tipo `play` al iniciar una solicitud de streaming, almacenando el rango HTTP solicitado en los metadatos.

---

## ArtistRepository

Gestión del catálogo propio del artista.

#### findProfileByUser

Busca el perfil de artista vinculado a un usuario propietario.

#### findOrCreateGenre

Busca un género por nombre o lo crea si no existe, usando `upsert`.

#### findOrCreateCollaborator

Busca un artista colaborador por nombre o lo crea si no existe.

#### findAudioByChecksum

Busca un archivo de audio por su checksum SHA-256 para detectar duplicados antes de subir.

#### createSong

Crea una canción con su archivo de audio y colaboradores en una sola operación. El archivo queda disponible inmediatamente.

#### listOwnSongs

Lista todas las canciones del artista con sus relaciones completas, ordenadas por fecha de creación descendente.

#### listOwnAlbums

Lista todos los álbumes del artista con conteo de canciones.

#### setOwnSongPublication

Activa o desactiva una canción del artista en una transacción, actualizando tanto `song.isActive` como `audioFile.isAvailable`.

#### removeOwnSong

Desactiva una canción del artista marcando tanto la canción como su archivo de audio como no disponibles, sin eliminarlos de la base de datos.

#### reactivateOwnSongFromAudio

Reactiva una canción existente desde un archivo de audio ya almacenado, actualizando título, género, colaboradores y duración en una transacción.

#### createAlbum

Crea un álbum y opcionalmente asigna canciones existentes del artista al mismo, en una transacción.

---

## AdminSongRepository

Gestión administrativa de canciones para usuarios con rol `admin`.

#### findOrCreateGenre / findOrCreateArtist

Buscan o crean género y artista por nombre, igual que en `ArtistRepository`.

#### findSong / findAnySong

`findSong` devuelve canciones activas; `findAnySong` devuelve cualquier canción independientemente de su estado, usado para reactivación administrativa.

#### findAudioFileByChecksum

Detecta duplicados de archivos de audio por checksum SHA-256.

#### updateSongAlbum

Actualiza el álbum, artista o género de una canción.

#### deactivateSong

Desactiva una canción y su archivo de audio en una sola operación.

#### reactivateSongFromAudio / createSongWithAudio

Reactivan o crean canciones con su archivo de audio asociado.

---

## AdminAlbumRepository

Gestión administrativa de álbumes.

#### findOrCreateArtist / findOrCreateGenre

Buscan o crean artista y género por nombre.

#### findSongs / findSong

Verifican disponibilidad de canciones antes de agregarlas a un álbum.

#### findAlbum

Recupera un álbum con artista, género y listado de canciones.

#### updateSongAlbum

Asigna o desasigna una canción de un álbum.

#### createAlbumFromSongs

Crea un álbum en una transacción y asigna todas las canciones indicadas al mismo tiempo.

---

## AdminUserRepository

Gestión administrativa de usuarios.

#### listUsers

Lista todos los usuarios del sistema ordenados por fecha de creación descendente, incluyendo su rol.

#### findUser

Recupera un usuario por identificador con su rol.

#### updateStatus

Actualiza el estado de un usuario (`active`, `suspended`).

#### revokeUserTokens

Revoca todos los tokens de refresco activos de un usuario, forzando cierre de sesión en todos los dispositivos.

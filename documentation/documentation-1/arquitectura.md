# Arquitectura

## Documentación de la Arquitectura de SoundStream

SoundStream utiliza una arquitectura monolítica de tres capas, compuesta por una base de datos PostgreSQL para el almacenamiento persistente de datos, un frontend desarrollado con Flutter para la interfaz de usuario en Web y Android, y un backend implementado con Node.js y Fastify para el procesamiento de la lógica del servidor y la exposición de la API REST.

## Base de Datos - PostgreSQL

La base de datos utilizada en la aplicación es PostgreSQL, un sistema de gestión de bases de datos relacional de código abierto. PostgreSQL se encarga de almacenar y administrar todos los datos de la aplicación de forma eficiente y segura, incluyendo usuarios, canciones, álbumes, playlists, favoritos, historial de reproducciones, interacciones y recomendaciones.

El acceso a la base de datos se realiza exclusivamente a través de Prisma ORM, que actúa como capa de abstracción entre el backend y PostgreSQL. Prisma gestiona las migraciones del esquema y proporciona un cliente tipado en TypeScript para todas las operaciones de datos. El esquema define quince entidades principales: `Role`, `User`, `Artist`, `Genre`, `Album`, `Song`, `AudioFile`, `SongCollaborator`, `Favorite`, `Playlist`, `PlaylistSong`, `PlayHistory`, `UserInteraction`, `Recommendation` y `RefreshToken`.

Los archivos de audio no se almacenan en la base de datos. Se guardan en el sistema de archivos del servidor bajo la ruta configurada en la variable de entorno `AUDIO_STORAGE_PATH`, y la base de datos únicamente conserva la metadata del archivo en la entidad `AudioFile`, incluyendo la ruta de almacenamiento, el tipo MIME, el tamaño en bytes, el checksum SHA-256 y el bitrate.

## Frontend - Flutter

El frontend de la aplicación está desarrollado con Flutter, el framework de Google para construir interfaces de usuario multiplataforma desde una única base de código. SoundStream utiliza Flutter para generar tanto la versión Web como la versión Android de la aplicación, garantizando una experiencia consistente en ambas plataformas.

La gestión de estado se realiza con el patrón Provider y ChangeNotifier. Cada módulo de la aplicación cuenta con su propio controller que extiende ChangeNotifier y es responsable de mantener el estado local, invocar los servicios de API y notificar a la interfaz de los cambios. Los controllers principales son: `AuthController`, `CatalogController`, `FavoritesController`, `PlaylistsController`, `HistoryController`, `RecommendationsController`, `PlayerController`, `ArtistController` y `AdminController`.

La comunicación con el backend se centraliza en un `ApiClient` personalizado que inyecta automáticamente el token JWT en cada petición, detecta respuestas 401 y ejecuta un refresh silencioso del token sin interrumpir al usuario. La sesión se persiste localmente mediante SharedPreferences, lo que permite que la aplicación recupere la sesión automáticamente al reiniciarse.

La reproducción de audio se gestiona a través del paquete audioplayers. Cuando el usuario reproduce una canción, el `PlayerController` descarga los bytes del audio desde el endpoint de streaming y los alimenta directamente al reproductor. Al finalizar la reproducción, el controller registra automáticamente la reproducción en el historial con el porcentaje de completitud.

La inyección de dependencias se centraliza en un `ServiceLocator` singleton que inicializa todos los servicios y controllers al arrancar la aplicación, siguiendo el patrón Factory para la construcción de dependencias.

## Backend - Fastify

El backend de la aplicación está construido con Fastify, un framework web de alto rendimiento para Node.js. Fastify gestiona todas las solicitudes HTTP de los clientes, procesa la lógica del servidor, interactúa con la base de datos a través de Prisma y entrega los archivos de audio con soporte de HTTP Range Requests.

El backend sigue el patrón MVC estricto con tres capas bien diferenciadas. Los controllers registran las rutas de Fastify, validan los cuerpos de las peticiones con Zod y delegan la ejecución al service correspondiente. Los services contienen toda la lógica de negocio y son los únicos que invocan a los repositories. Los repositories encapsulan el acceso a Prisma y no contienen lógica de negocio.

La autenticación se implementa con JWT mediante el plugin `@fastify/jwt`. El token de acceso tiene una expiración de quince minutos y el refresh token dura treinta días con rotación en cada uso. Los middlewares `requireAuth`, `requireArtist` y `requireAdmin` protegen las rutas según el rol del usuario.

El sistema de recomendaciones utiliza el patrón Strategy con dos implementaciones intercambiables: `HybridScoringStrategy` para usuarios con historial, que puntúa candidatos en función de reproducciones, favoritos e interacciones por género y artista, y `PopularityScoringStrategy` como fallback para usuarios nuevos sin historial. El `RecommendationEngine` es un singleton que opera con la estrategia activa y persiste los veinte mejores resultados con expiración de veinticuatro horas. El motor se dispara automáticamente a través del `DomainEventBus` cuando el usuario completa una canción con un porcentaje de completitud igual o superior al ochenta por ciento.

## Flujo de Datos

El flujo de datos en SoundStream sigue el patrón cliente-servidor. El cliente Flutter envía solicitudes HTTP al backend Fastify con el token JWT en el header de autorización. El backend valida el token, procesa la solicitud aplicando la lógica de negocio en el service, realiza las operaciones necesarias en PostgreSQL a través del repository y genera una respuesta en formato JSON que se envía de vuelta al cliente.

Para el streaming de audio, el flujo es diferente. El cliente solicita `GET /api/stream/songs/:songId` con su token JWT. El backend valida el token, verifica que la canción esté activa y que el archivo esté disponible, localiza el archivo en el disco mediante la ruta almacenada en `AudioFile.storagePath` y lo entrega como respuesta binaria. Si la petición incluye un header `Range`, el backend responde con status 206 Partial Content y entrega únicamente el fragmento solicitado. Los archivos de audio nunca se exponen como rutas estáticas públicas, garantizando que solo usuarios autenticados puedan acceder al contenido.

La comunicación entre el frontend y el backend se realiza a través de una API RESTful bajo el prefijo `/api`, utilizando los métodos HTTP GET, POST, PATCH y DELETE para las operaciones correspondientes. En el entorno de producción, nginx actúa como proxy inverso recibiendo las peticiones en el puerto 80 y reenviando las rutas `/api/*` al backend en el puerto 3000, mientras que el frontend compilado se sirve como archivos estáticos desde el build de Flutter Web.

Esta arquitectura modular y bien definida separa claramente las responsabilidades de cada capa, facilita el mantenimiento del sistema y permite incorporar nuevas funcionalidades sin afectar los módulos existentes.

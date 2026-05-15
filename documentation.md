# SoundStream Flutter Client

## Resumen

Se implemento un cliente Flutter en `flutter_client` conectado al backend Fastify/Prisma ya existente en `backend`.

Objetivo cubierto:

- Cliente Flutter para Web y Android.
- Integracion real con los endpoints actuales del backend.
- Estructura MVC en el frontend.
- Funcionalidad priorizada sobre acabado visual.
- Documentacion suficiente para una persona o una IA sin contexto previo.

## Arquitectura aplicada

La app Flutter quedo organizada en MVC ligero:

- `lib/src/models`
  Contiene los modelos de dominio que representan las respuestas del backend.
- `lib/src/views`
  Contiene pantallas, secciones y widgets visibles. No contiene logica de negocio.
- `lib/src/controllers`
  Contiene controladores `ChangeNotifier` que orquestan la UI, validan flujo y llaman servicios.
- `lib/src/services`
  Encapsula el acceso HTTP al backend REST.
- `lib/src/core`
  Configuracion, manejo de sesion persistente, cliente HTTP y errores.

## Modulos funcionales implementados

### Autenticacion

- Login.
- Registro de usuario.
- Registro de artista.
- Persistencia de sesion con `shared_preferences`.
- `refreshToken` automatico ante `401`.
- Cierre de sesion.
- Recuperacion de usuario con `/auth/me`.

### Catalogo y busqueda

- Consulta de canciones publicadas.
- Consulta de albumes.
- Busqueda de canciones por texto.
- Consulta detalle de album.

### Reproduccion

- Reproduccion desde endpoint protegido `/api/stream/songs/:songId`.
- Controles basicos:
  - play
  - pause
  - resume
  - adelantar 10s
  - retroceder 10s
- Registro de interacciones de reproduccion.
- Registro de historial de escucha.

Nota tecnica:
La reproduccion actual descarga el flujo autenticado y lo entrega al reproductor como bytes para asegurar compatibilidad Web/Android con JWT. Funciona con el backend actual, aunque no implementa seek remoto por rangos desde el cliente.

### Favoritos

- Listar favoritos.
- Agregar favorito.
- Quitar favorito.

### Playlists

- Crear playlist.
- Listar playlists.
- Ver detalle de playlist.
- Agregar cancion a playlist.
- Quitar cancion de playlist.

### Historial

- Ver historial de reproduccion.
- Registrar reproducciones.
- Registrar interacciones de usuario.

### Recomendaciones

- Listar recomendaciones.
- Forzar recalculo usando `/recommendations/refresh`.
- Reproducir desde recomendaciones.

### Modulo artista

- Ver canciones propias.
- Subir cancion con audio.
- Mantener canciones como singles sin album.
- Publicar y despublicar canciones.
- Eliminar canciones propias.
- Crear album vacio o con canciones propias.
- Asignar o quitar canciones propias de un album existente.

### Modulo admin

- Listar usuarios.
- Cambiar estado de usuario.
- Subir canciones al catalogo.
- Crear album vacio o desde canciones del catalogo.
- Asignar o quitar canciones del catalogo a albumes existentes.
- Eliminar canciones del catalogo.

## Archivos clave creados o modificados

### Flutter

- `flutter_client/lib/main.dart`
- `flutter_client/lib/src/app.dart`
- `flutter_client/lib/src/core/app_config.dart`
- `flutter_client/lib/src/core/api_client.dart`
- `flutter_client/lib/src/core/api_exception.dart`
- `flutter_client/lib/src/core/session_storage.dart`
- `flutter_client/lib/src/models/domain_models.dart`
- `flutter_client/lib/src/services/services.dart`
- `flutter_client/lib/src/controllers/controllers.dart`
- `flutter_client/lib/src/views/auth_page.dart`
- `flutter_client/lib/src/views/app_shell.dart`
- `flutter_client/lib/src/views/home_sections.dart`
- `flutter_client/pubspec.yaml`
- `flutter_client/android/app/src/main/AndroidManifest.xml`

### Documentacion

- `documentation.md`

## Dependencias agregadas en Flutter

- `provider`
- `http`
- `shared_preferences`
- `file_picker`
- `audioplayers`
- `intl`
- `http_parser`

## Contrato backend usado

La app consume estos modulos reales del backend:

- `/api/auth`
- `/api/catalog`
- `/api/favorites`
- `/api/playlists`
- `/api/history`
- `/api/recommendations`
- `/api/stream`
- `/api/artist`
- `/api/admin`

No se inventaron endpoints nuevos.

## Configuracion requerida

La app usa `--dart-define` para la URL base del backend:

- Variable: `API_BASE_URL`

Ejemplos:

### Web

```powershell
flutter run -d chrome --web-port 5173 --dart-define=API_BASE_URL=http://localhost:4000/api
```

### Android Emulator

```powershell
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:4000/api
```

### Build Web

```powershell
flutter build web --dart-define=API_BASE_URL=http://localhost:4000/api
```

### Build APK

```powershell
flutter build apk --dart-define=API_BASE_URL=http://10.0.2.2:4000/api
```

## Requisitos operativos del backend

Para Web, el backend actual usa CORS restringido por `WEB_ORIGIN`.

El backend debe aceptar el origen donde corre Flutter Web. Con la configuracion actual conviene iniciar Flutter Web en puerto `5173`:

```powershell
flutter run -d chrome --web-port 5173 --dart-define=API_BASE_URL=http://localhost:3000/api
```

Si usas otro puerto, actualiza `backend/.env`:

```env
WEB_ORIGIN=http://localhost:TU_PUERTO
```

## Credenciales demo detectadas en el seed

- Admin:
  - `admin@soundstream.local`
  - `Admin12345`
- Artista:
  - `artist@soundstream.local`
  - `Artist12345`
- Usuario:
  - `demo@soundstream.local`
  - `Demo12345`

## Flujo de arranque recomendado

1. Levantar backend.
2. Confirmar base de datos migrada y seed ejecutado.
3. Ejecutar Flutter Web o Android con `API_BASE_URL`.
4. Iniciar sesion con una cuenta demo o registrar una nueva.

## Detalles de implementacion importantes

### Sesion

- La sesion completa se guarda serializada en `shared_preferences`.
- Si el `accessToken` vence, el cliente intenta `refresh`.
- Si el `refreshToken` falla, la sesion se limpia.

### Player

- El `PlayerController` centraliza estado del reproductor.
- Cada cambio de pista intenta registrar reproduccion e interacciones.
- La barra inferior de reproduccion permanece visible mientras exista una pista activa.

### Playlists y favoritos

- Se recargan contra backend para mantener coherencia real.
- No se agrego cache offline.

### Artist/Admin uploads

- Se usa `file_picker`.
- Los formularios envian `multipart/form-data`.
- Los nombres de campos respetan exactamente lo esperado por Fastify.

### Flujo editorial nuevo

- Una cancion puede existir sin album.
- Un album puede crearse vacio.
- Una cancion puede asignarse despues a un album.
- Una cancion tambien puede salir de un album y volver a quedar como single.

## Limitaciones actuales

- La interfaz es funcional, no final de diseño.
- No se implemento reproduccion remota segmentada con seek por `Range` desde el cliente.
- No se implementaron pruebas automatizadas del cliente Flutter en esta fase.
- El modulo admin trabaja sobre las canciones visibles en catalogo para creacion de album/eliminacion, porque el backend actual no expone un endpoint administrativo separado para listar canciones.
- Los albumes administrativos vacios requieren `artistName` para definir a quien pertenecen.

## Siguientes pasos recomendados

1. Ejecutar `flutter pub get`.
2. Ejecutar `flutter analyze`.
3. Probar login, catalogo, favoritos, playlists, recomendaciones y reproduccion.
4. Probar artista con `artist@soundstream.local`.
5. Probar admin con `admin@soundstream.local`.
6. Si quieres streaming con seek real en Web/Android, evolucionar el reproductor para trabajar con fuentes autenticadas segmentadas.

## Lectura rapida para otra IA

Si otra IA retoma este proyecto, el contexto minimo util es:

- El backend ya existia y define el contrato real.
- El cliente Flutter nuevo vive en `flutter_client`.
- La arquitectura del frontend es MVC:
  - `models`: DTOs y entidades de UI.
  - `services`: llamadas REST.
  - `controllers`: estado y coordinacion.
  - `views`: pantallas y widgets.
- La sesion se maneja con `AuthController + SessionStorage + AuthService`.
- El acceso REST autenticado pasa por `ApiClient`, que reintenta una vez tras refresh.
- La reproduccion actual usa bytes autenticados descargados desde `/api/stream/songs/:id`.
- Para Web hay que respetar `WEB_ORIGIN` del backend.

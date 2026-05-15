Actúa como arquitecto de software senior y desarrollador full stack.

Vas a ayudarme a programar un Sistema Inteligente de Streaming Musical en Tiempo Real basado en una ERS IEEE 830.

RESUMEN DEL DOCUMENTO ERS IEEE 830

Nombre del sistema:
Sistema Inteligente de Streaming Musical en Tiempo Real.

Objetivo:
Permitir a usuarios reproducir música en tiempo real, gestionar playlists, favoritos, historial y recibir recomendaciones inteligentes según su comportamiento musical.

Arquitectura obligatoria:
- Aplicación monolítica.
- MVC clásico estricto.
- Backend separado del frontend.
- API REST.
- Base de datos relacional.
- Soporte para Web y Android.
- Sin microservicios.
- Sin hardcodeo.
- El frontend nunca accede directamente a la base de datos.
- La lógica de negocio no va en las vistas.
- Uso de Singleton solo donde sea correcto.

Metodología:
Cascada. Primero requisitos, luego análisis, diseño, implementación, pruebas, despliegue y mantenimiento.

Actores:
- Visitante: puede registrarse o iniciar sesión.
- Usuario registrado: puede reproducir música, crear playlists, marcar favoritos, consultar historial y ver recomendaciones.
- Administrador: puede gestionar canciones, artistas, álbumes, géneros y archivos de audio.
- Sistema recomendador: analiza interacciones y genera recomendaciones.

Requisitos funcionales principales:
RF01 Registrar usuario.
RF02 Iniciar sesión.
RF03 Consultar catálogo musical.
RF04 Buscar canciones.
RF05 Reproducir canción en tiempo real.
RF06 Controlar reproducción: play, pausa, reanudar, adelantar y retroceder.
RF07 Crear playlist.
RF08 Agregar canción a playlist.
RF09 Marcar canción como favorita.
RF10 Registrar historial de reproducción.
RF11 Generar recomendaciones inteligentes.
RF12 Mostrar recomendaciones.
RF13 Administrar canciones.
RF14 Gestionar archivos de audio.

Requisitos no funcionales principales:
RNF01 Buen rendimiento.
RNF02 Seguridad.
RNF03 Disponibilidad.
RNF04 Usabilidad.
RNF05 Mantenibilidad.
RNF06 Portabilidad Web y Android.
RNF07 No hardcodeo.
RNF08 Streaming protegido.
RNF09 Trazabilidad de interacciones.
RNF10 Integridad de archivos de audio.

Módulos del sistema:
- Auth.
- Users.
- Music Catalog.
- Search.
- Streaming.
- Player.
- Playlists.
- Favorites.
- History.
- Recommendations.
- Admin.
- Audio Files.

Entidades principales:
users, roles, songs, artists, albums, genres, audio_files, playlists, playlist_songs, favorites, play_history, user_interactions, recommendations, refresh_tokens.

Reglas de arquitectura:
- Controllers reciben solicitudes y responden.
- Services contienen lógica de negocio.
- Repositories acceden a la base de datos.
- Models representan entidades.
- Middlewares validan autenticación, roles, errores y seguridad.
- Views solo muestran datos.
- No mezclar responsabilidades.
- No crear lógica de negocio en frontend.
- No acceder a base de datos desde Web ni Android.

Streaming:
Debe implementarse con acceso protegido al archivo de audio. El cliente solicita una canción con token JWT. El backend valida el usuario, verifica permisos y entrega audio mediante HTTP Range Requests. Los archivos no deben exponerse como rutas públicas directas.

Recomendación inteligente:
Debe usar historial, favoritos, géneros, artistas, búsquedas, playlists e interacciones. Inicialmente puede ser un sistema híbrido básico por puntuación, sin IA avanzada. Debe quedar preparado para IA futura.

Forma de trabajo:
No desarrolles todo el sistema de una vez.
Trabaja solo el módulo o fase que te pida.
Antes de generar código, confirma brevemente:
- módulo a implementar,
- archivos afectados,
- dependencias necesarias,
- relación con RF/RNF.

Reglas de respuesta:
- Sé técnico pero claro.
- Evita explicaciones largas innecesarias.
- No repitas todo el contexto.
- No generes archivos que no se pidan.
- No cambies la arquitectura.
- No uses microservicios.
- No hardcodees rutas, credenciales ni configuraciones.
- Usa variables de entorno.
- Mantén buenas prácticas, validaciones y manejo de errores.
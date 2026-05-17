# SoundStream Components Specification

## SongTile

**Propósito**: Mostrar una canción en listas con acciones rápidas

**Estructura**:
```
┌─────────────────────────────────────────────────┐
│ [Icon] Título                           [♡] [⋯] │
│        Artista • Álbum • Género                 │
└─────────────────────────────────────────────────┘
```

**Props**:
- `Song song` (required)
- `bool isFavorite` (required)
- `VoidCallback onPlay` (required)
- `VoidCallback onToggleFavorite` (required)
- `VoidCallback onAddToPlaylist` (required)
- `Widget? extra` (optional - para recomendaciones)

**Estados**:
- Normal
- Hover: elevación sutil
- Loading: skeleton
- Error: ícono de error

**Acciones**:
- Click en fila: reproducir
- Click ♡: toggle favorito
- Click ⋯: agregar a playlist

---

## SongCard (Compact)

**Propósito**: Grid de canciones para exploración

**Tamaño**: 180x200px
**Estructura**:
```
┌──────────────┐
│   [Album]    │
│   Art Icon   │
├──────────────┤
│ Título       │
│ Artista      │
│ Género       │
└──────────────┘
```

---

## AlbumCard

**Propósito**: Mostrar álbum en grid

**Tamaño**: 220x240px
**Estructura**:
```
┌─────────────────┐
│ [Album Icon]    │
│                 │
│ Título Álbum    │
│ Artista         │
│ Género          │
│ 12 canciones    │
└─────────────────┘
```

**Propiedades**:
- Album artwork (placeholder icon)
- Title (fontWeight: bold)
- Artist (secondary color)
- Genre (secondary color)
- Song count (cyan, bold)

**Interactividad**:
- Hover: elevación + scale 1.02
- Click: abrir modal con canciones

---

## PlaylistCard

**Propósito**: Mostrar playlist

**Tamaño**: 220x200px
**Estructura**:
```
┌─────────────────────┐
│ [Playlist Icon]     │
│                     │
│ Nombre              │
│ Descripción o -     │
│ 8 canciones • Public│
└─────────────────────┘
```

---

## Player Bar (Inferior)

**Propósito**: Control de reproducción persistente

**Layout**: 
```
[♫] Canción • Artista  |  [◄◄][◀][▶][►►]  [⏱]  [◻] Volumen
```

**Componentes**:
- Song info (icon + text)
- Control buttons: prev, play/pause, next
- Time display
- Volume slider
- Fullscreen button

---

## PlayerModal (Expandido)

**Propósito**: Vista completa del reproductor

**Estructura**:
```
┌─────────────────────────────────┐
│  ⬅  ⋯                       [↗] │
├─────────────────────────────────┤
│                                 │
│        [Album Artwork]          │
│        Mucho más grande         │
│                                 │
│  Título canción                 │
│  Artista                        │
│                                 │
│  Barra de progreso: 0:30 / 3:45 │
│                                 │
│  [◄◄] [❚❚] [▶] [⟳]  [♡] [⋯]    │
│  Shuffle  Volume        Repeat  │
│                                 │
└─────────────────────────────────┘
```

---

## SearchBar

**Propósito**: Búsqueda de canciones

**Estados**:
- Idle: placeholder visible
- Focused: purple border
- Filled: mostrar valor + clear button
- Error: red border + error message

**Filtros adicionales** (opcional):
- Género
- Artista
- Orden (relevancia, fecha, popularidad)

---

## UploadForm (Artist/Admin)

**Propósito**: Formulario de carga de canción

**Campos**:
- Título (required)
- Género (required)
- Duración (required)
- Colaboradores (optional, comma-separated)
- File picker (audio file)

**Validaciones**:
- Título: min 3 chars, max 255
- Género: min 2 chars
- Duración: número > 0
- File: .mp3, .wav, .flac (max 500MB)

---

## AlbumAssignmentDialog

**Propósito**: Asignar canción a álbum

**Contenido**:
```
Asignar canción: "Nombre Canción"

[Album 1] [Album 2] [Album 3]
[Album 4] [Album 5] [Crear nuevo]

[Cancelar] [Asignar]
```

---

## UserStatusDropdown

**Propósito**: Cambiar estado de usuario (Admin)

**Opciones**:
- active
- inactive
- blocked

**Color según estado**:
- active: green
- inactive: yellow
- blocked: red

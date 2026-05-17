# Responsive Design Specification

## Breakpoints

| Device | Width | Layout | Nav |
|--------|-------|--------|-----|
| Mobile | <480px | Single column | Bottom tabs |
| Tablet | 480-1024px | 2-3 columns | Side/Top nav |
| Desktop | >1024px | 3+ columns | Side nav |

## Mobile (<480px)

### Layout General
- Single column
- Full-width cards
- Bottom navigation (5 tabs)
- Action buttons: full-width or 2-column

### Auth Page
[Hero section oculto] ┌──────────────────┐ │ [Logo] │ │ Bienvenido │ │ │ │ [Email field] │ │ [Password field] │ │ │ │ [Login button] │ │ │ │ [Register link] │ └──────────────────┘

Code

### Catalog Section
[Hero banner] [Search bar - full width]

Canciones (vertical list): ┌────────────────────┐ │ [🎵] Canción │ │ Artista │ │ [♡][⋯] │ └────────────────────┘

Code

### Album Grid
[Album 1] [Album 2] [Album 3] (1 columna, full-width)

Code

### Player Bar
Versión simplificada: ┌─────────────────────────────────────┐ │ [🎵] Canción • Artista │ │ [◀] [▶] Pause [♡] [⋯] │ └─────────────────────────────────────┘

Code

---

## Tablet (480-1024px)

### Layout
- 2-3 columnas
- Sidebar colapsable
- Cards medianos

### Album Grid
[Album 1] [Album 2] [Album 3] [Album 4] (2 columnas)

Code

### Song List
Títulos más cortos Información condensada

Code

---

## Desktop (>1024px)

### Layout
- 3+ columnas
- Sidebar expandido permanente
- Cards grandes

### Album Grid
[Album 1] [Album 2] [Album 3] [Album 4] [Album 5] [Album 6] [Album 7] [Album 8] (4 columnas, máximo 6)

Code

### Upload Form
┌─────────────────────────────────────┐ │ [Título (240px)] [Género (180px)] │ │ [Duración (180px)] [Colabs (260px)] │ │ [File Picker] [Upload button] │ └─────────────────────────────────────┘

Code

---

## Touch Targets (Mobile First)

- Mínimo: 48x48dp (siguiendo Material Design)
- Espaciado entre targets: 8px mínimo
- Áreas interactivas expandidas en móvil

## Text Scaling

| Device | Base Size | Multiplier |
|--------|-----------|-----------|
| Mobile | 14px | 1.0x |
| Tablet | 14px | 1.1x |
| Desktop | 14px | 1.2x |

# SoundStream Design System

##  Paleta de Colores

### Colores Primarios
- **Purple (Primario)**: #7C3AED
- **Pink (Secundario)**: #EC4899
- **Cyan (Acento)**: #06B6D4

### Colores Neutros
- **Dark (Fondo)**: #0F0A1E
- **Dark Card**: #1A1030
- **Surface**: #231845
- **Border**: #3D2D6B
- **Text Mid**: #B8A9D9
- **White**: #FFFFFF

### Colores Semánticos
- **Error**: #EF4444
- **Success**: #10B981
- **Warning**: #F59E0B
- **Info**: #3B82F6

##  Tipografía

### Fuentes
- **Primaria**: Inter, Roboto (fallback)
- **Monoespaciada**: JetBrains Mono (para código)

### Escala de Tamaños
- **Display Large**: 44px, weight 900
- **Display Medium**: 36px, weight 800
- **Heading 1**: 32px, weight 800
- **Heading 2**: 28px, weight 700
- **Heading 3**: 24px, weight 700
- **Title Large**: 20px, weight 700
- **Title Medium**: 18px, weight 600
- **Title Small**: 16px, weight 600
- **Body Large**: 16px, weight 400
- **Body Medium**: 14px, weight 400
- **Body Small**: 12px, weight 400
- **Label Large**: 15px, weight 700
- **Label Medium**: 13px, weight 600
- **Label Small**: 11px, weight 500

##  Componentes Base

### Button (Gradient)
- **Tamaño**: 52px height × full width
- **Border Radius**: 14px
- **Gradient**: Purple → Pink
- **Estados**: normal, disabled, loading, hover

### TextField
- **Height**: 52px
- **Border Radius**: 14px
- **Fill Color**: Surface
- **Border**: Border color
- **Focus Border**: Purple
- **Padding**: 16px horizontal, 16px vertical

### Card / Panel
- **Border Radius**: 20px
- **Background**: Dark Card
- **Border**: 1px Border color
- **Shadow**: Purple with 0.1 alpha
- **Padding**: 24px (hero), 18px (content)

### Icon Button
- **Size**: 40x40 (medium), 48x48 (large)
- **Background**: Color with 0.18 alpha
- **Border Radius**: 12px

##  Espaciado (8px base)

- xs: 4px
- sm: 8px
- md: 12px
- lg: 16px
- xl: 24px
- 2xl: 32px
- 3xl: 48px
- 4xl: 64px
  
##  Border Radius

- sm: 8px
- md: 12px
- lg: 14px
- xl: 20px
- 2xl: 24px
- full: 999px

##  Breakpoints

- Mobile: 0 - 480px
- Tablet: 480 - 1024px
- Desktop: 1024px+

##  Efectos

### Shadows
- **sm**: `0 1px 2px 0 rgba(0,0,0,0.05)`
- **md**: `0 4px 6px -1px rgba(0,0,0,0.1)`
- **lg**: `0 10px 15px -3px rgba(0,0,0,0.1)`
- **xl**: `0 20px 25px -5px rgba(0,0,0,0.1)`
- **glow**: Purple/Pink with 0.3 alpha, blur 30px

### Gradients
- **Primary**: LinearGradient(Purple → Pink, top-left to bottom-right)
- **Hero**: LinearGradient(#4C1D95 → #7C3AED → #6D28D9)
- **Text**: LinearGradient(White → Cyan)

##  Animaciones

- **Fast**: 200ms
- **Normal**: 300ms
- **Slow**: 500ms
- **Easing**: ease-in-out

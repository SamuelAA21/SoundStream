import { PlaylistService } from '../src/services/playlistService';

describe('PlaylistService - Pruebas de Playlists', () => {
  let playlistService: PlaylistService;
  let playlistsMock: any[];

  beforeEach(() => {
    playlistService = new PlaylistService();

    // Datos de prueba
    playlistsMock = [
      {
        id: 'pl_1',
        nombre: 'Mi Playlist Rock',
        usuarioId: 'user1',
        fechaCreacion: '2026-05-16T10:00:00Z',
        canciones: ['cancion1', 'cancion2', 'cancion3'],
      },
      {
        id: 'pl_2',
        nombre: 'Favoritas Pop',
        usuarioId: 'user1',
        fechaCreacion: '2026-05-15T12:00:00Z',
        canciones: ['cancion4', 'cancion5'],
      },
      {
        id: 'pl_3',
        nombre: 'Jazz Relajante',
        usuarioId: 'user2',
        fechaCreacion: '2026-05-14T14:00:00Z',
        canciones: ['cancion6'],
      },
    ];
  });

  // ============= PRUEBAS DE VALIDACIÓN DE NOMBRE =============
  describe('validarNombre()', () => {
    test('DEBE retornar TRUE para nombre válido', () => {
      expect(playlistService.validarNombre('Mi Playlist Rock')).toBe(true);
    });

    test('DEBE retornar FALSE para nombre vacío', () => {
      expect(playlistService.validarNombre('')).toBe(false);
    });

    test('DEBE retornar FALSE para nombre con 1 carácter', () => {
      expect(playlistService.validarNombre('M')).toBe(false);
    });

    test('DEBE retornar TRUE para nombre con 2 caracteres', () => {
      expect(playlistService.validarNombre('Mi')).toBe(true);
    });
  });

  // ============= PRUEBAS DE CREACIÓN DE PLAYLIST =============
  describe('crearPlaylist()', () => {
    test('DEBE crear playlist con datos válidos', () => {
      const playlist = playlistService.crearPlaylist('Nueva Playlist', 'user1');

      expect(playlist).not.toBeNull();
      expect(playlist.nombre).toBe('Nueva Playlist');
      expect(playlist.usuarioId).toBe('user1');
      expect(playlist.canciones).toEqual([]);
      expect(playlist.id).toBeDefined();
    });

    test('DEBE retornar NULL con nombre inválido', () => {
      const playlist = playlistService.crearPlaylist('M', 'user1');
      expect(playlist).toBeNull();
    });

    test('DEBE retornar NULL con usuarioId vacío', () => {
      const playlist = playlistService.crearPlaylist('Nueva Playlist', '');
      expect(playlist).toBeNull();
    });

    test('DEBE crear playlist con ID único', () => {
      const pl1 = playlistService.crearPlaylist('Playlist 1', 'user1');
      const pl2 = playlistService.crearPlaylist('Playlist 2', 'user1');

      expect(pl1.id).not.toBe(pl2.id);
    });

    test('DEBE generar fechaCreacion automáticamente', () => {
      const playlist = playlistService.crearPlaylist('Nueva Playlist', 'user1');
      expect(playlist.fechaCreacion).toBeDefined();
    });
  });

  // ============= PRUEBAS DE AGREGAR CANCIONES =============
  describe('agregarCancion()', () => {
    test('DEBE agregar canción a la playlist', () => {
      const playlist = playlistService.crearPlaylist('Test', 'user1');
      const resultado = playlistService.agregarCancion(playlist, 'cancion1');

      expect(resultado).toBe(true);
      expect(playlist.canciones.length).toBe(1);
    });

    test('DEBE retornar FALSE con ID de canción vacío', () => {
      const playlist = playlistService.crearPlaylist('Test', 'user1');
      const resultado = playlistService.agregarCancion(playlist, '');

      expect(resultado).toBe(false);
      expect(playlist.canciones.length).toBe(0);
    });

    test('DEBE retornar FALSE al agregar canción duplicada', () => {
      const playlist = playlistService.crearPlaylist('Test', 'user1');
      
      playlistService.agregarCancion(playlist, 'cancion1');
      const resultado = playlistService.agregarCancion(playlist, 'cancion1');

      expect(resultado).toBe(false);
      expect(playlist.canciones.length).toBe(1);
    });

    test('DEBE agregar múltiples canciones diferentes', () => {
      const playlist = playlistService.crearPlaylist('Test', 'user1');
      
      playlistService.agregarCancion(playlist, 'cancion1');
      playlistService.agregarCancion(playlist, 'cancion2');
      playlistService.agregarCancion(playlist, 'cancion3');

      expect(playlist.canciones.length).toBe(3);
    });
  });

  // ============= PRUEBAS DE ELIMINAR CANCIONES =============
  describe('eliminarCancion()', () => {
    test('DEBE eliminar canción existente', () => {
      const playlist = playlistsMock[0];
      const cantidadInicial = playlist.canciones.length;
      const resultado = playlistService.eliminarCancion(playlist, 'cancion1');

      expect(resultado).toBe(true);
      expect(playlist.canciones.length).toBe(cantidadInicial - 1);
    });

    test('DEBE retornar FALSE al eliminar canción inexistente', () => {
      const playlist = playlistsMock[0];
      const cantidadInicial = playlist.canciones.length;
      const resultado = playlistService.eliminarCancion(playlist, 'cancion_inexistente');

      expect(resultado).toBe(false);
      expect(playlist.canciones.length).toBe(cantidadInicial);
    });

    test('DEBE eliminar solo la canción especificada', () => {
      const playlist = playlistsMock[0];
      
      playlistService.eliminarCancion(playlist, 'cancion2');

      expect(playlist.canciones.includes('cancion1')).toBe(true);
      expect(playlist.canciones.includes('cancion2')).toBe(false);
      expect(playlist.canciones.includes('cancion3')).toBe(true);
    });
  });

  // ============= PRUEBAS DE OBTENER CANTIDAD =============
  describe('obtenerCantidadCanciones()', () => {
    test('DEBE retornar 0 para playlist vacía', () => {
      const playlist = playlistService.crearPlaylist('Vacía', 'user1');
      expect(playlistService.obtenerCantidadCanciones(playlist)).toBe(0);
    });

    test('DEBE retornar cantidad correcta de canciones', () => {
      const playlist = playlistsMock[0];
      expect(playlistService.obtenerCantidadCanciones(playlist)).toBe(3);
    });

    test('DEBE actualizar cantidad después de agregar', () => {
      const playlist = playlistService.crearPlaylist('Test', 'user1');
      
      playlistService.agregarCancion(playlist, 'cancion1');
      expect(playlistService.obtenerCantidadCanciones(playlist)).toBe(1);
      
      playlistService.agregarCancion(playlist, 'cancion2');
      expect(playlistService.obtenerCantidadCanciones(playlist)).toBe(2);
    });
  });

  // ============= PRUEBAS DE CONTIENE CANCIÓN =============
  describe('contienCancion()', () => {
    test('DEBE retornar TRUE si canción existe', () => {
      const playlist = playlistsMock[0];
      expect(playlistService.contienCancion(playlist, 'cancion1')).toBe(true);
    });

    test('DEBE retornar FALSE si canción no existe', () => {
      const playlist = playlistsMock[0];
      expect(playlistService.contienCancion(playlist, 'cancion_inexistente')).toBe(false);
    });

    test('DEBE funcionar después de agregar canción', () => {
      const playlist = playlistService.crearPlaylist('Test', 'user1');
      
      playlistService.agregarCancion(playlist, 'cancion1');
      expect(playlistService.contienCancion(playlist, 'cancion1')).toBe(true);
    });
  });

  // ============= PRUEBAS DE OBTENER PLAYLISTS POR USUARIO =============
  describe('obtenerPlaylistsUsuario()', () => {
    test('DEBE retornar todas las playlists del usuario1', () => {
      const playlists = playlistService.obtenerPlaylistsUsuario(playlistsMock, 'user1');
      
      expect(playlists.length).toBe(2);
      expect(playlists.every(p => p.usuarioId === 'user1')).toBe(true);
    });

    test('DEBE retornar todas las playlists del usuario2', () => {
      const playlists = playlistService.obtenerPlaylistsUsuario(playlistsMock, 'user2');
      
      expect(playlists.length).toBe(1);
      expect(playlists[0].nombre).toBe('Jazz Relajante');
    });

    test('DEBE retornar array vacío para usuario sin playlists', () => {
      const playlists = playlistService.obtenerPlaylistsUsuario(playlistsMock, 'user_inexistente');
      
      expect(playlists.length).toBe(0);
    });
  });

  // ============= PRUEBAS DE BÚSQUEDA =============
  describe('buscarPlaylist()', () => {
    test('DEBE encontrar playlist por nombre exacto', () => {
      const resultados = playlistService.buscarPlaylist(playlistsMock, 'Mi Playlist Rock');
      
      expect(resultados.length).toBe(1);
      expect(resultados[0].id).toBe('pl_1');
    });

    test('DEBE encontrar playlist por búsqueda parcial', () => {
      const resultados = playlistService.buscarPlaylist(playlistsMock, 'Playlist');
      
      expect(resultados.length).toBe(1);
    });

    test('DEBE encontrar playlist "Favoritas Pop"', () => {
      const resultados = playlistService.buscarPlaylist(playlistsMock, 'Pop');
      
      expect(resultados.length).toBe(1);
      expect(resultados[0].nombre).toBe('Favoritas Pop');
    });

    test('DEBE retornar array vacío si no hay coincidencias', () => {
      const resultados = playlistService.buscarPlaylist(playlistsMock, 'Inexistente');
      
      expect(resultados.length).toBe(0);
    });

    test('DEBE ser case-insensitive', () => {
      const resultados1 = playlistService.buscarPlaylist(playlistsMock, 'rock');
      const resultados2 = playlistService.buscarPlaylist(playlistsMock, 'ROCK');
      const resultados3 = playlistService.buscarPlaylist(playlistsMock, 'Rock');

      expect(resultados1.length).toBe(1);
      expect(resultados2.length).toBe(1);
      expect(resultados3.length).toBe(1);
    });
  });

  // ============= PRUEBAS DE ELIMINAR PLAYLIST =============
  describe('eliminarPlaylist()', () => {
    test('DEBE eliminar playlist por ID', () => {
      const cantidadInicial = playlistsMock.length;
      const resultados = playlistService.eliminarPlaylist(playlistsMock, 'pl_1');

      expect(resultados.length).toBe(cantidadInicial - 1);
      expect(resultados.find(p => p.id === 'pl_1')).toBeUndefined();
    });

    test('DEBE no modificar array si ID no existe', () => {
      const cantidadInicial = playlistsMock.length;
      const resultados = playlistService.eliminarPlaylist(playlistsMock, 'pl_inexistente');

      expect(resultados.length).toBe(cantidadInicial);
    });

    test('DEBE eliminar solo la playlist especificada', () => {
      const resultados = playlistService.eliminarPlaylist(playlistsMock, 'pl_2');

      expect(resultados.find(p => p.id === 'pl_1')).toBeDefined();
      expect(resultados.find(p => p.id === 'pl_2')).toBeUndefined();
      expect(resultados.find(p => p.id === 'pl_3')).toBeDefined();
    });
  });

  // ============= PRUEBAS DE FLUJOS COMPLETOS =============
  describe('Flujos Completos', () => {
    test('DEBE crear playlist, agregar canciones y verificar', () => {
      const playlist = playlistService.crearPlaylist('Mi Playlist', 'user1');

      playlistService.agregarCancion(playlist, 'cancion1');
      playlistService.agregarCancion(playlist, 'cancion2');
      playlistService.agregarCancion(playlist, 'cancion3');

      expect(playlistService.obtenerCantidadCanciones(playlist)).toBe(3);
      expect(playlistService.contienCancion(playlist, 'cancion1')).toBe(true);
    });

    test('DEBE crear, agregar, eliminar y contar', () => {
      const playlist = playlistService.crearPlaylist('Test', 'user1');

      playlistService.agregarCancion(playlist, 'cancion1');
      playlistService.agregarCancion(playlist, 'cancion2');
      expect(playlistService.obtenerCantidadCanciones(playlist)).toBe(2);

      playlistService.eliminarCancion(playlist, 'cancion1');
      expect(playlistService.obtenerCantidadCanciones(playlist)).toBe(1);
      expect(playlistService.contienCancion(playlist, 'cancion1')).toBe(false);
    });

    test('DEBE obtener playlists del usuario y buscar', () => {
      const playlistsUsuario = playlistService.obtenerPlaylistsUsuario(playlistsMock, 'user1');
      expect(playlistsUsuario.length).toBe(2);

      const busqueda = playlistService.buscarPlaylist(playlistsUsuario, 'Rock');
      expect(busqueda.length).toBe(1);
    });
  });
});

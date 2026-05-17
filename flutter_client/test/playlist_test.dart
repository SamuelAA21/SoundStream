import 'package:flutter_test/flutter_test.dart';

// Clase Playlist para pruebas
class Playlist {
  String id;
  String nombre;
  String usuarioId;
  List<String> cancionesIds;
  DateTime fechaCreacion;
  
  Playlist({
    required this.id,
    required this.nombre,
    required this.usuarioId,
    this.cancionesIds = const [],
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();
  
  /// Valida que el nombre no esté vacío
  bool esNombreValido() {
    return nombre.isNotEmpty && nombre.length >= 2;
  }
  
  /// Agrega una canción a la playlist
  bool agregarCancion(String cancionId) {
    if (cancionId.isNotEmpty && !cancionesIds.contains(cancionId)) {
      cancionesIds.add(cancionId);
      return true;
    }
    return false;
  }
  
  /// Elimina una canción de la playlist
  bool eliminarCancion(String cancionId) {
    return cancionesIds.remove(cancionId);
  }
  
  /// Obtiene la cantidad de canciones
  int obtenerCantidadCanciones() {
    return cancionesIds.length;
  }
  
  /// Valida si la playlist tiene al menos 1 canción
  bool tieneCanciones() {
    return cancionesIds.isNotEmpty;
  }
  
  /// Valida que la playlist sea válida
  bool esValida() {
    return esNombreValido() && usuarioId.isNotEmpty;
  }
}

void main() {
  group('Pruebas de Validación - Playlist', () {
    
    // ============= PRUEBAS DE NOMBRE =============
    group('esNombreValido()', () {
      test('DEBE retornar TRUE para nombre válido', () {
        var playlist = Playlist(
          id: '1',
          nombre: 'Mi Playlist',
          usuarioId: 'user123',
        );
        
        expect(playlist.esNombreValido(), true);
      });
      
      test('DEBE retornar FALSE para nombre vacío', () {
        var playlist = Playlist(
          id: '1',
          nombre: '',
          usuarioId: 'user123',
        );
        
        expect(playlist.esNombreValido(), false);
      });
      
      test('DEBE retornar FALSE para nombre con solo 1 carácter', () {
        var playlist = Playlist(
          id: '1',
          nombre: 'A',
          usuarioId: 'user123',
        );
        
        expect(playlist.esNombreValido(), false);
      });
    });
    
    // ============= PRUEBAS DE AGREGAR CANCIONES =============
    group('agregarCancion()', () {
      test('DEBE agregar canción correctamente a playlist vacía', () {
        var playlist = Playlist(
          id: '1',
          nombre: 'Mi Playlist',
          usuarioId: 'user123',
        );
        
        bool resultado = playlist.agregarCancion('cancion1');
        
        expect(resultado, true);
        expect(playlist.obtenerCantidadCanciones(), 1);
      });
      
      test('DEBE retornar FALSE si intenta agregar canción con ID vacío', () {
        var playlist = Playlist(
          id: '1',
          nombre: 'Mi Playlist',
          usuarioId: 'user123',
        );
        
        bool resultado = playlist.agregarCancion('');
        
        expect(resultado, false);
      });
      
      test('DEBE retornar FALSE si intenta agregar canción duplicada', () {
        var playlist = Playlist(
          id: '1',
          nombre: 'Mi Playlist',
          usuarioId: 'user123',
        );
        
        playlist.agregarCancion('cancion1');
        bool resultado = playlist.agregarCancion('cancion1');
        
        expect(resultado, false);
        expect(playlist.obtenerCantidadCanciones(), 1);
      });
      
      test('DEBE agregar múltiples canciones diferentes', () {
        var playlist = Playlist(
          id: '1',
          nombre: 'Mi Playlist',
          usuarioId: 'user123',
        );
        
        playlist.agregarCancion('cancion1');
        playlist.agregarCancion('cancion2');
        playlist.agregarCancion('cancion3');
        
        expect(playlist.obtenerCantidadCanciones(), 3);
      });
    });
    
    // ============= PRUEBAS DE ELIMINAR CANCIONES =============
    group('eliminarCancion()', () {
      test('DEBE eliminar canción correctamente', () {
        var playlist = Playlist(
          id: '1',
          nombre: 'Mi Playlist',
          usuarioId: 'user123',
        );
        
        playlist.agregarCancion('cancion1');
        bool resultado = playlist.eliminarCancion('cancion1');
        
        expect(resultado, true);
        expect(playlist.obtenerCantidadCanciones(), 0);
      });
      
      test('DEBE retornar FALSE si intenta eliminar canción inexistente', () {
        var playlist = Playlist(
          id: '1',
          nombre: 'Mi Playlist',
          usuarioId: 'user123',
        );
        
        bool resultado = playlist.eliminarCancion('cancion_inexistente');
        
        expect(resultado, false);
      });
      
      test('DEBE mantener otras canciones al eliminar una', () {
        var playlist = Playlist(
          id: '1',
          nombre: 'Mi Playlist',
          usuarioId: 'user123',
        );
        
        playlist.agregarCancion('cancion1');
        playlist.agregarCancion('cancion2');
        playlist.agregarCancion('cancion3');
        
        playlist.eliminarCancion('cancion2');
        
        expect(playlist.obtenerCantidadCanciones(), 2);
        expect(playlist.cancionesIds.contains('cancion1'), true);
        expect(playlist.cancionesIds.contains('cancion3'), true);
      });
    });
    
    // ============= PRUEBAS DE CANTIDAD DE CANCIONES =============
    group('obtenerCantidadCanciones()', () {
      test('DEBE retornar 0 para playlist vacía', () {
        var playlist = Playlist(
          id: '1',
          nombre: 'Mi Playlist',
          usuarioId: 'user123',
        );
        
        expect(playlist.obtenerCantidadCanciones(), 0);
      });
      
      test('DEBE retornar cantidad correcta de canciones', () {
        var playlist = Playlist(
          id: '1',
          nombre: 'Mi Playlist',
          usuarioId: 'user123',
        );
        
        playlist.agregarCancion('cancion1');
        playlist.agregarCancion('cancion2');
        
        expect(playlist.obtenerCantidadCanciones(), 2);
      });
    });
    
    // ============= PRUEBAS DE VALIDACIÓN COMPLETA =============
    group('esValida() - Validación Completa', () {
      test('DEBE retornar TRUE cuando todos los campos son válidos', () {
        var playlist = Playlist(
          id: '1',
          nombre: 'Mi Playlist',
          usuarioId: 'user123',
        );
        
        expect(playlist.esValida(), true);
      });
      
      test('DEBE retornar FALSE cuando nombre es inválido', () {
        var playlist = Playlist(
          id: '1',
          nombre: '',
          usuarioId: 'user123',
        );
        
        expect(playlist.esValida(), false);
      });
      
      test('DEBE retornar FALSE cuando usuarioId es vacío', () {
        var playlist = Playlist(
          id: '1',
          nombre: 'Mi Playlist',
          usuarioId: '',
        );
        
        expect(playlist.esValida(), false);
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

// Clase Cancion para pruebas
class Cancion {
  String id;
  String titulo;
  String artista;
  int duracionSegundos;
  String genero;
  
  Cancion({
    required this.id,
    required this.titulo,
    required this.artista,
    required this.duracionSegundos,
    required this.genero,
  });
  
  /// Valida que el título no esté vacío
  bool esTituloValido() {
    return titulo.isNotEmpty && titulo.length >= 2;
  }
  
  /// Valida que el artista no esté vacío
  bool esArtistaValido() {
    return artista.isNotEmpty && artista.length >= 2;
  }
  
  /// Valida que la duración sea positiva
  bool esDuracionValida() {
    return duracionSegundos > 0;
  }
  
  /// Valida que el género no esté vacío
  bool esGeneroValido() {
    return genero.isNotEmpty;
  }
  
  /// Convierte segundos a formato MM:SS
  String obtenerDuracionFormato() {
    int minutos = duracionSegundos ~/ 60;
    int segundos = duracionSegundos % 60;
    return '$minutos:${segundos.toString().padLeft(2, '0')}';
  }
  
  /// Valida que la canción sea válida completamente
  bool esValida() {
    return esTituloValido() &&
        esArtistaValido() &&
        esDuracionValida() &&
        esGeneroValido();
  }
}

void main() {
  group('Pruebas de Validación - Cancion', () {
    
    // ============= PRUEBAS DE TÍTULO =============
    group('esTituloValido()', () {
      test('DEBE retornar TRUE para título válido', () {
        var cancion = Cancion(
          id: '1',
          titulo: 'Bohemian Rhapsody',
          artista: 'Queen',
          duracionSegundos: 354,
          genero: 'Rock',
        );
        
        expect(cancion.esTituloValido(), true);
      });
      
      test('DEBE retornar FALSE para título vacío', () {
        var cancion = Cancion(
          id: '1',
          titulo: '',
          artista: 'Queen',
          duracionSegundos: 354,
          genero: 'Rock',
        );
        
        expect(cancion.esTituloValido(), false);
      });
      
      test('DEBE retornar FALSE para título con solo 1 carácter', () {
        var cancion = Cancion(
          id: '1',
          titulo: 'A',
          artista: 'Queen',
          duracionSegundos: 354,
          genero: 'Rock',
        );
        
        expect(cancion.esTituloValido(), false);
      });
      
      test('DEBE retornar TRUE para título con 2 caracteres', () {
        var cancion = Cancion(
          id: '1',
          titulo: 'Hi',
          artista: 'Queen',
          duracionSegundos: 354,
          genero: 'Rock',
        );
        
        expect(cancion.esTituloValido(), true);
      });
    });
    
    // ============= PRUEBAS DE ARTISTA =============
    group('esArtistaValido()', () {
      test('DEBE retornar TRUE para artista válido', () {
        var cancion = Cancion(
          id: '1',
          titulo: 'Bohemian Rhapsody',
          artista: 'Queen',
          duracionSegundos: 354,
          genero: 'Rock',
        );
        
        expect(cancion.esArtistaValido(), true);
      });
      
      test('DEBE retornar FALSE para artista vacío', () {
        var cancion = Cancion(
          id: '1',
          titulo: 'Bohemian Rhapsody',
          artista: '',
          duracionSegundos: 354,
          genero: 'Rock',
        );
        
        expect(cancion.esArtistaValido(), false);
      });
      
      test('DEBE retornar TRUE para artista con nombre compuesto', () {
        var cancion = Cancion(
          id: '1',
          titulo: 'Song',
          artista: 'Dua Lipa',
          duracionSegundos: 200,
          genero: 'Pop',
        );
        
        expect(cancion.esArtistaValido(), true);
      });
    });
    
    // ============= PRUEBAS DE DURACIÓN =============
    group('esDuracionValida()', () {
      test('DEBE retornar TRUE para duración positiva', () {
        var cancion = Cancion(
          id: '1',
          titulo: 'Song',
          artista: 'Artist',
          duracionSegundos: 180,
          genero: 'Pop',
        );
        
        expect(cancion.esDuracionValida(), true);
      });
      
      test('DEBE retornar FALSE para duración 0', () {
        var cancion = Cancion(
          id: '1',
          titulo: 'Song',
          artista: 'Artist',
          duracionSegundos: 0,
          genero: 'Pop',
        );
        
        expect(cancion.esDuracionValida(), false);
      });
      
      test('DEBE retornar FALSE para duración negativa', () {
        var cancion = Cancion(
          id: '1',
          titulo: 'Song',
          artista: 'Artist',
          duracionSegundos: -100,
          genero: 'Pop',
        );
        
        expect(cancion.esDuracionValida(), false);
      });
    });
    
    // ============= PRUEBAS DE FORMATO DE DURACIÓN =============
    group('obtenerDuracionFormato()', () {
      test('DEBE retornar formato MM:SS correcto para 1 minuto', () {
        var cancion = Cancion(
          id: '1',
          titulo: 'Song',
          artista: 'Artist',
          duracionSegundos: 60,
          genero: 'Pop',
        );
        
        expect(cancion.obtenerDuracionFormato(), '1:00');
      });
      
      test('DEBE retornar formato MM:SS correcto para 3:45', () {
        var cancion = Cancion(
          id: '1',
          titulo: 'Song',
          artista: 'Artist',
          duracionSegundos: 225,
          genero: 'Pop',
        );
        
        expect(cancion.obtenerDuracionFormato(), '3:45');
      });
      
      test('DEBE padding correcto para segundos menores a 10', () {
        var cancion = Cancion(
          id: '1',
          titulo: 'Song',
          artista: 'Artist',
          duracionSegundos: 125,
          genero: 'Pop',
        );
        
        expect(cancion.obtenerDuracionFormato(), '2:05');
      });
    });
    
    // ============= PRUEBAS DE GÉNERO =============
    group('esGeneroValido()', () {
      test('DEBE retornar TRUE para género válido', () {
        var cancion = Cancion(
          id: '1',
          titulo: 'Song',
          artista: 'Artist',
          duracionSegundos: 180,
          genero: 'Rock',
        );
        
        expect(cancion.esGeneroValido(), true);
      });
      
      test('DEBE retornar FALSE para género vacío', () {
        var cancion = Cancion(
          id: '1',
          titulo: 'Song',
          artista: 'Artist',
          duracionSegundos: 180,
          genero: '',
        );
        
        expect(cancion.esGeneroValido(), false);
      });
    });
    
    // ============= PRUEBAS DE VALIDACIÓN COMPLETA =============
    group('esValida() - Validación Completa', () {
      test('DEBE retornar TRUE cuando todos los campos son válidos', () {
        var cancion = Cancion(
          id: '1',
          titulo: 'Bohemian Rhapsody',
          artista: 'Queen',
          duracionSegundos: 354,
          genero: 'Rock',
        );
        
        expect(cancion.esValida(), true);
      });
      
      test('DEBE retornar FALSE cuando título es inválido', () {
        var cancion = Cancion(
          id: '1',
          titulo: '',
          artista: 'Queen',
          duracionSegundos: 354,
          genero: 'Rock',
        );
        
        expect(cancion.esValida(), false);
      });
      
      test('DEBE retornar FALSE cuando duración es negativa', () {
        var cancion = Cancion(
          id: '1',
          titulo: 'Song',
          artista: 'Artist',
          duracionSegundos: -50,
          genero: 'Pop',
        );
        
        expect(cancion.esValida(), false);
      });
    });
  });
}

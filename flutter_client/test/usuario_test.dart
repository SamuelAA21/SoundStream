import 'package:flutter_test/flutter_test.dart';

// Clase Usuario para pruebas
class Usuario {
  String email;
  String password;
  String nombre;
  
  Usuario({
    required this.email,
    required this.password,
    required this.nombre,
  });
  
  /// Valida que el email tenga formato correcto
  bool esEmailValido() {
    return email.contains('@') && email.contains('.') && email.isNotEmpty;
  }
  
  /// Valida que la contraseña tenga al menos 6 caracteres
  bool esPasswordValida() {
    return password.length >= 6;
  }
  
  /// Valida que el nombre no esté vacío
  bool esNombreValido() {
    return nombre.isNotEmpty && nombre.length >= 2;
  }
  
  /// Valida todos los campos
  bool esValido() {
    return esEmailValido() && esPasswordValida() && esNombreValido();
  }
}

void main() {
  group('Pruebas de Validación - Usuario', () {
    
    // ============= PRUEBAS DE EMAIL =============
    group('esEmailValido()', () {
      test('DEBE retornar TRUE para email válido con @ y dominio', () {
        // DADO
        var usuario = Usuario(
          email: 'juan@example.com',
          password: 'password123',
          nombre: 'Juan Pérez',
        );
        
        // CUANDO
        bool resultado = usuario.esEmailValido();
        
        // ENTONCES
        expect(resultado, true);
      });
      
      test('DEBE retornar FALSE para email sin @', () {
        var usuario = Usuario(
          email: 'juanexample.com',
          password: 'password123',
          nombre: 'Juan Pérez',
        );
        
        expect(usuario.esEmailValido(), false);
      });
      
      test('DEBE retornar FALSE para email sin punto (.)', () {
        var usuario = Usuario(
          email: 'juan@example',
          password: 'password123',
          nombre: 'Juan Pérez',
        );
        
        expect(usuario.esEmailValido(), false);
      });
      
      test('DEBE retornar FALSE para email vacío', () {
        var usuario = Usuario(
          email: '',
          password: 'password123',
          nombre: 'Juan Pérez',
        );
        
        expect(usuario.esEmailValido(), false);
      });
      
      test('DEBE retornar TRUE para email con múltiples puntos', () {
        var usuario = Usuario(
          email: 'juan.perez@empresa.co.uk',
          password: 'password123',
          nombre: 'Juan Pérez',
        );
        
        expect(usuario.esEmailValido(), true);
      });
    });
    
    // ============= PRUEBAS DE PASSWORD =============
    group('esPasswordValida()', () {
      test('DEBE retornar TRUE para password con 6 o más caracteres', () {
        var usuario = Usuario(
          email: 'juan@example.com',
          password: 'password123',
          nombre: 'Juan Pérez',
        );
        
        expect(usuario.esPasswordValida(), true);
      });
      
      test('DEBE retornar FALSE para password con menos de 6 caracteres', () {
        var usuario = Usuario(
          email: 'juan@example.com',
          password: '123',
          nombre: 'Juan Pérez',
        );
        
        expect(usuario.esPasswordValida(), false);
      });
      
      test('DEBE retornar TRUE para password con exactamente 6 caracteres', () {
        var usuario = Usuario(
          email: 'juan@example.com',
          password: '123456',
          nombre: 'Juan Pérez',
        );
        
        expect(usuario.esPasswordValida(), true);
      });
      
      test('DEBE retornar FALSE para password vacío', () {
        var usuario = Usuario(
          email: 'juan@example.com',
          password: '',
          nombre: 'Juan Pérez',
        );
        
        expect(usuario.esPasswordValida(), false);
      });
      
      test('DEBE retornar TRUE para password muy largo', () {
        var usuario = Usuario(
          email: 'juan@example.com',
          password: 'MiContraseñaMuySegura123!@#\$%',
          nombre: 'Juan Pérez',
        );
        
        expect(usuario.esPasswordValida(), true);
      });
    });
    
    // ============= PRUEBAS DE NOMBRE =============
    group('esNombreValido()', () {
      test('DEBE retornar TRUE para nombre válido', () {
        var usuario = Usuario(
          email: 'juan@example.com',
          password: 'password123',
          nombre: 'Juan Pérez',
        );
        
        expect(usuario.esNombreValido(), true);
      });
      
      test('DEBE retornar FALSE para nombre vacío', () {
        var usuario = Usuario(
          email: 'juan@example.com',
          password: 'password123',
          nombre: '',
        );
        
        expect(usuario.esNombreValido(), false);
      });
      
      test('DEBE retornar FALSE para nombre con solo 1 carácter', () {
        var usuario = Usuario(
          email: 'juan@example.com',
          password: 'password123',
          nombre: 'J',
        );
        
        expect(usuario.esNombreValido(), false);
      });
      
      test('DEBE retornar TRUE para nombre con 2 caracteres', () {
        var usuario = Usuario(
          email: 'juan@example.com',
          password: 'password123',
          nombre: 'Jo',
        );
        
        expect(usuario.esNombreValido(), true);
      });
    });
    
    // ============= PRUEBAS DE VALIDACIÓN COMPLETA =============
    group('esValido() - Validación Completa', () {
      test('DEBE retornar TRUE cuando todos los campos son válidos', () {
        var usuario = Usuario(
          email: 'juan@example.com',
          password: 'password123',
          nombre: 'Juan Pérez',
        );
        
        expect(usuario.esValido(), true);
      });
      
      test('DEBE retornar FALSE cuando email es inválido', () {
        var usuario = Usuario(
          email: 'juanexample',
          password: 'password123',
          nombre: 'Juan Pérez',
        );
        
        expect(usuario.esValido(), false);
      });
      
      test('DEBE retornar FALSE cuando password es muy corta', () {
        var usuario = Usuario(
          email: 'juan@example.com',
          password: '123',
          nombre: 'Juan Pérez',
        );
        
        expect(usuario.esValido(), false);
      });
      
      test('DEBE retornar FALSE cuando nombre es vacío', () {
        var usuario = Usuario(
          email: 'juan@example.com',
          password: 'password123',
          nombre: '',
        );
        
        expect(usuario.esValido(), false);
      });
      
      test('DEBE retornar FALSE cuando todos los campos son inválidos', () {
        var usuario = Usuario(
          email: 'invalido',
          password: '123',
          nombre: '',
        );
        
        expect(usuario.esValido(), false);
      });
    });
  });
}

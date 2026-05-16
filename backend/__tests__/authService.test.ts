/**
 * PRUEBAS UNITARIAS - AuthService
 * Módulo: Backend - Autenticación
 * Lenguaje: TypeScript
 * Framework: Jest
 */

// Clase AuthService para pruebas
class AuthService {
  /**
   * Valida que el email tenga formato correcto
   * @param email - Email a validar
   * @returns true si el email es válido
   */
  validarEmail(email: string): boolean {
    const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return regex.test(email) && email.length > 0;
  }

  /**
   * Valida que la contraseña cumpla requisitos mínimos
   * @param password - Contraseña a validar
   * @returns true si la contraseña es válida
   */
  validarPassword(password: string): boolean {
    return password.length >= 6;
  }

  /**
   * Valida que el nombre no esté vacío
   * @param nombre - Nombre a validar
   * @returns true si el nombre es válido
   */
  validarNombre(nombre: string): boolean {
    return nombre.trim().length >= 2;
  }

  /**
   * Encripta una contraseña (simulado)
   * En producción usarías bcrypt
   * @param password - Contraseña a encriptar
   * @returns Contraseña encriptada
   */
  hashPassword(password: string): string {
    return `hashed_${password}`;
  }

  /**
   * Autentica un usuario con email y contraseña
   * @param email - Email del usuario
   * @param password - Contraseña del usuario
   * @returns true si la autenticación es correcta
   */
  autenticar(email: string, password: string): boolean {
    if (!this.validarEmail(email)) return false;
    if (!this.validarPassword(password)) return false;
    return true;
  }

  /**
   * Registra un nuevo usuario
   * @param email - Email del usuario
   * @param password - Contraseña del usuario
   * @param nombre - Nombre del usuario
   * @returns true si el registro es exitoso
   */
  registrar(email: string, password: string, nombre: string): boolean {
    if (!this.validarEmail(email)) return false;
    if (!this.validarPassword(password)) return false;
    if (!this.validarNombre(nombre)) return false;
    return true;
  }
}

describe('AuthService - Pruebas Unitarias de Autenticación', () => {
  let authService: AuthService;

  // Configuración antes de cada prueba
  beforeEach(() => {
    authService = new AuthService();
  });

  // ============= PRUEBAS DE VALIDACIÓN DE EMAIL =============
  describe('validarEmail()', () => {
    test('DEBE retornar TRUE para email válido', () => {
      // DADO
      const email = 'juan@example.com';

      // CUANDO
      const resultado = authService.validarEmail(email);

      // ENTONCES
      expect(resultado).toBe(true);
    });

    test('DEBE retornar FALSE para email sin @', () => {
      const email = 'juanexample.com';
      expect(authService.validarEmail(email)).toBe(false);
    });

    test('DEBE retornar FALSE para email sin dominio', () => {
      const email = 'juan@';
      expect(authService.validarEmail(email)).toBe(false);
    });

    test('DEBE retornar FALSE para email sin extensión de dominio', () => {
      const email = 'juan@example';
      expect(authService.validarEmail(email)).toBe(false);
    });

    test('DEBE retornar FALSE para email vacío', () => {
      const email = '';
      expect(authService.validarEmail(email)).toBe(false);
    });

    test('DEBE retornar TRUE para email con múltiples puntos', () => {
      const email = 'juan.perez@empresa.co.uk';
      expect(authService.validarEmail(email)).toBe(true);
    });

    test('DEBE retornar FALSE para email con espacios', () => {
      const email = 'juan @example.com';
      expect(authService.validarEmail(email)).toBe(false);
    });
  });

  // ============= PRUEBAS DE VALIDACIÓN DE PASSWORD =============
  describe('validarPassword()', () => {
    test('DEBE retornar TRUE para password con 6 o más caracteres', () => {
      const password = 'password123';
      expect(authService.validarPassword(password)).toBe(true);
    });

    test('DEBE retornar FALSE para password con menos de 6 caracteres', () => {
      const password = '123';
      expect(authService.validarPassword(password)).toBe(false);
    });

    test('DEBE retornar TRUE para password con exactamente 6 caracteres', () => {
      const password = '123456';
      expect(authService.validarPassword(password)).toBe(true);
    });

    test('DEBE retornar FALSE para password vacío', () => {
      const password = '';
      expect(authService.validarPassword(password)).toBe(false);
    });

    test('DEBE retornar TRUE para password muy largo', () => {
      const password = 'MiContraseñaMuySegura123!@#$%^&*()';
      expect(authService.validarPassword(password)).toBe(true);
    });
  });

  // ============= PRUEBAS DE VALIDACIÓN DE NOMBRE =============
  describe('validarNombre()', () => {
    test('DEBE retornar TRUE para nombre válido', () => {
      const nombre = 'Juan Pérez';
      expect(authService.validarNombre(nombre)).toBe(true);
    });

    test('DEBE retornar FALSE para nombre vacío', () => {
      const nombre = '';
      expect(authService.validarNombre(nombre)).toBe(false);
    });

    test('DEBE retornar FALSE para nombre con solo 1 carácter', () => {
      const nombre = 'J';
      expect(authService.validarNombre(nombre)).toBe(false);
    });

    test('DEBE retornar TRUE para nombre con 2 caracteres', () => {
      const nombre = 'Jo';
      expect(authService.validarNombre(nombre)).toBe(true);
    });

    test('DEBE retornar TRUE para nombre con espacios extras', () => {
      const nombre = '  Juan  ';
      expect(authService.validarNombre(nombre)).toBe(true);
    });
  });

  // ============= PRUEBAS DE ENCRIPTACIÓN DE PASSWORD =============
  describe('hashPassword()', () => {
    test('DEBE encriptar la contraseña', () => {
      // DADO
      const password = 'myPassword123';

      // CUANDO
      const resultado = authService.hashPassword(password);

      // ENTONCES
      expect(resultado).toContain('hashed_');
    });

    test('DEBE encriptar diferentes passwords de manera diferente', () => {
      const pass1 = authService.hashPassword('password1');
      const pass2 = authService.hashPassword('password2');

      expect(pass1).not.toBe(pass2);
    });

    test('DEBE mantener consistencia en la encriptación', () => {
      const password = 'testPassword';
      const hash1 = authService.hashPassword(password);
      const hash2 = authService.hashPassword(password);

      expect(hash1).toBe(hash2);
    });

    test('DEBE incluir el prefijo hashed_', () => {
      const resultado = authService.hashPassword('test123');
      expect(resultado.startsWith('hashed_')).toBe(true);
    });
  });

  // ============= PRUEBAS DE AUTENTICACIÓN =============
  describe('autenticar()', () => {
    test('DEBE retornar TRUE con email y password válidos', () => {
      expect(
        authService.autenticar('juan@example.com', 'password123')
      ).toBe(true);
    });

    test('DEBE retornar FALSE con email inválido', () => {
      expect(
        authService.autenticar('juanexample', 'password123')
      ).toBe(false);
    });

    test('DEBE retornar FALSE con password muy corta', () => {
      expect(
        authService.autenticar('juan@example.com', '123')
      ).toBe(false);
    });

    test('DEBE retornar FALSE con ambos inválidos', () => {
      expect(
        authService.autenticar('invalid', 'short')
      ).toBe(false);
    });

    test('DEBE retornar FALSE con email vacío', () => {
      expect(
        authService.autenticar('', 'password123')
      ).toBe(false);
    });

    test('DEBE retornar FALSE con password vacío', () => {
      expect(
        authService.autenticar('juan@example.com', '')
      ).toBe(false);
    });
  });

  // ============= PRUEBAS DE REGISTRO =============
  describe('registrar()', () => {
    test('DEBE retornar TRUE cuando todos los datos son válidos', () => {
      expect(
        authService.registrar('juan@example.com', 'password123', 'Juan Pérez')
      ).toBe(true);
    });

    test('DEBE retornar FALSE cuando email es inválido', () => {
      expect(
        authService.registrar('invalid', 'password123', 'Juan Pérez')
      ).toBe(false);
    });

    test('DEBE retornar FALSE cuando password es muy corta', () => {
      expect(
        authService.registrar('juan@example.com', '123', 'Juan Pérez')
      ).toBe(false);
    });

    test('DEBE retornar FALSE cuando nombre es vacío', () => {
      expect(
        authService.registrar('juan@example.com', 'password123', '')
      ).toBe(false);
    });

    test('DEBE retornar FALSE cuando todos los datos son inválidos', () => {
      expect(
        authService.registrar('invalid', '123', '')
      ).toBe(false);
    });

    test('DEBE aceptar nombres con caracteres especiales', () => {
      expect(
        authService.registrar('juan@example.com', 'password123', 'José María')
      ).toBe(true);
    });
  });
});

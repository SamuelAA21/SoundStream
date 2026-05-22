import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'SoundStream';
  static const String _definedApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get apiBaseUrl {
    if (_definedApiBaseUrl.isNotEmpty) {
      return _definedApiBaseUrl;
    }

    if (kIsWeb) {
      final host = Uri.base.host.toLowerCase();
      if (host == 'localhost' || host == '127.0.0.1') {
        return 'http://localhost:3000/api';
      }

      // En despliegues web privados/publicos servidos tras un proxy,
      // usar mismo origen evita CORS y simplifica configuracion.
      return '/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }

    return 'http://localhost:3000/api';
  }
}

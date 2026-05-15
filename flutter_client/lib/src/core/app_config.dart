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
      return 'http://localhost:4000/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:4000/api';
    }

    return 'http://localhost:4000/api';
  }
}

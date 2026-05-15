import 'dart:convert';

import '../models/domain_models.dart';

class SessionStorage {
  SessionStorage(this._preferences);

  final dynamic _preferences;

  static const _sessionKey = 'soundstream.session';

  AuthSession? readSession() {
    final raw = _preferences.getString(_sessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final data = jsonDecode(raw) as Map<String, dynamic>;
    return AuthSession.fromJson(data);
  }

  Future<void> saveSession(AuthSession session) {
    return _preferences.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  Future<void> clear() {
    return _preferences.remove(_sessionKey);
  }
}

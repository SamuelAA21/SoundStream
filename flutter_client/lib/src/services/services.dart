import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../models/domain_models.dart';

class AuthService {
  AuthService({required this.baseUrl, required this.client});

  final String baseUrl;
  final http.Client client;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return _send(
      path: '/auth/login',
      body: {'email': email, 'password': password},
    );
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    required String accountType,
    String? artistName,
  }) async {
    return _send(
      path: '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'accountType': accountType,
        if (artistName != null && artistName.isNotEmpty)
          'artistName': artistName,
      },
    );
  }

  Future<AuthSession> refresh(String refreshToken) {
    return _send(path: '/auth/refresh', body: {'refreshToken': refreshToken});
  }

  Future<void> logout(String refreshToken) async {
    final response = await client.post(
      _uri('/auth/logout'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    _ensureSuccess(response);
  }

  Future<UserProfile> me(String accessToken) async {
    final response = await client.get(
      _uri('/auth/me'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    _ensureSuccess(response);
    return UserProfile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<AuthSession> _send({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    final response = await client.post(
      _uri(path),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    _ensureSuccess(response);
    return AuthSession.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Uri _uri(String path) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$normalizedBase$path');
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    String code = 'request_failed';
    String message = 'Request failed';
    if (response.body.isNotEmpty) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        code = error['code']?.toString() ?? code;
        message = error['message']?.toString() ?? message;
      }
    }
    throw ApiException(
      statusCode: response.statusCode,
      code: code,
      message: message,
    );
  }
}

class CatalogService {
  CatalogService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Song>> listSongs({String? query}) async {
    final suffix = query != null && query.trim().isNotEmpty
        ? '/catalog/songs?q=${Uri.encodeQueryComponent(query.trim())}'
        : '/catalog/songs';
    final payload =
        await _apiClient.get(suffix, authenticated: false)
            as Map<String, dynamic>;
    final data = payload['data'] as List<dynamic>? ?? const [];
    return data.whereType<Map<String, dynamic>>().map(Song.fromJson).toList();
  }

  Future<List<Album>> listAlbums() async {
    final payload =
        await _apiClient.get('/catalog/albums', authenticated: false)
            as List<dynamic>;
    return payload
        .whereType<Map<String, dynamic>>()
        .map(Album.fromJson)
        .toList();
  }

  Future<Album> getAlbum(String albumId) async {
    final payload =
        await _apiClient.get('/catalog/albums/$albumId', authenticated: false)
            as Map<String, dynamic>;
    return Album.fromJson(payload);
  }
}

class FavoritesService {
  FavoritesService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Song>> list() async {
    final payload = await _apiClient.get('/favorites') as List<dynamic>;
    return payload
        .whereType<Map<String, dynamic>>()
        .map(Song.fromJson)
        .toList();
  }

  Future<void> add(String songId) async {
    await _apiClient.post('/favorites/$songId');
  }

  Future<void> remove(String songId) async {
    await _apiClient.delete('/favorites/$songId');
  }
}

class PlaylistsService {
  PlaylistsService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PlaylistSummary>> list() async {
    final payload = await _apiClient.get('/playlists') as List<dynamic>;
    return payload
        .whereType<Map<String, dynamic>>()
        .map(PlaylistSummary.fromJson)
        .toList();
  }

  Future<PlaylistSummary> create({
    required String name,
    String? description,
    bool isPublic = false,
  }) async {
    final payload =
        await _apiClient.post(
              '/playlists',
              body: {
                'name': name,
                'description': description,
                'isPublic': isPublic,
              },
            )
            as Map<String, dynamic>;
    return PlaylistSummary.fromJson(payload);
  }

  Future<PlaylistDetail> detail(String playlistId) async {
    final payload =
        await _apiClient.get('/playlists/$playlistId') as Map<String, dynamic>;
    return PlaylistDetail.fromJson(payload);
  }

  Future<PlaylistDetail> addSong(String playlistId, String songId) async {
    final payload =
        await _apiClient.post('/playlists/$playlistId/songs/$songId')
            as Map<String, dynamic>;
    return PlaylistDetail.fromJson(payload);
  }

  Future<PlaylistDetail> removeSong(String playlistId, String songId) async {
    final payload =
        await _apiClient.delete('/playlists/$playlistId/songs/$songId')
            as Map<String, dynamic>;
    return PlaylistDetail.fromJson(payload);
  }
}

class HistoryService {
  HistoryService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<HistoryEntry>> list() async {
    final payload = await _apiClient.get('/history') as List<dynamic>;
    return payload
        .whereType<Map<String, dynamic>>()
        .map(HistoryEntry.fromJson)
        .toList();
  }

  Future<void> registerPlay({
    required String songId,
    required int playedSeconds,
    required double completionRate,
    required String deviceType,
  }) async {
    await _apiClient.post(
      '/history/plays',
      body: {
        'songId': songId,
        'playedSeconds': playedSeconds,
        'completionRate': completionRate,
        'deviceType': deviceType,
      },
    );
  }

  Future<void> registerInteraction({
    String? songId,
    required String interactionType,
    String? interactionValue,
    Map<String, dynamic>? metadata,
  }) async {
    await _apiClient.post(
      '/history/interactions',
      body: {
        if (songId != null) 'songId': songId,
        'interactionType': interactionType,
        if (interactionValue != null) 'interactionValue': interactionValue,
        if (metadata != null) 'metadata': metadata,
      },
    );
  }
}

class RecommendationsService {
  RecommendationsService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<RecommendationItem>> list() async {
    final payload = await _apiClient.get('/recommendations') as List<dynamic>;
    return payload
        .whereType<Map<String, dynamic>>()
        .map(RecommendationItem.fromJson)
        .toList();
  }

  Future<void> refresh() async {
    await _apiClient.post('/recommendations/refresh');
  }
}

class StreamingService {
  StreamingService(this._apiClient);

  final ApiClient _apiClient;

  Future<AudioStreamData> fetchSong(String songId) async {
    final response = await _apiClient.getRaw('/stream/songs/$songId');
    return AudioStreamData(
      bytes: Uint8List.fromList(response.bodyBytes),
      mimeType: response.headers['content-type'] ?? 'audio/mpeg',
    );
  }
}

class ArtistService {
  ArtistService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Album>> listMyAlbums() async {
    final payload = await _apiClient.get('/artist/albums') as List<dynamic>;
    return payload
        .whereType<Map<String, dynamic>>()
        .map(Album.fromJson)
        .toList();
  }

  Future<List<Song>> listMySongs() async {
    final payload = await _apiClient.get('/artist/songs') as List<dynamic>;
    return payload
        .whereType<Map<String, dynamic>>()
        .map(Song.fromJson)
        .toList();
  }

  Future<Song> uploadSong({
    required PlatformFile file,
    required String title,
    required String genreName,
    required String durationSeconds,
    String? collaboratorNames,
  }) async {
    final payload =
        await _apiClient.multipart(
              '/artist/songs',
              file: file,
              fields: {
                'title': title,
                'genreName': genreName,
                'durationSeconds': durationSeconds,
                if (collaboratorNames != null && collaboratorNames.isNotEmpty)
                  'collaboratorNames': collaboratorNames,
              },
            )
            as Map<String, dynamic>;
    return Song.fromJson(payload);
  }

  Future<Song> setPublication(String songId, bool isPublished) async {
    final payload =
        await _apiClient.patch(
              '/artist/songs/$songId/publication',
              body: {'isPublished': isPublished},
            )
            as Map<String, dynamic>;
    return Song.fromJson(payload);
  }

  Future<void> deleteSong(String songId) async {
    await _apiClient.delete('/artist/songs/$songId');
  }

  Future<Album> createAlbum({
    required String title,
    String? genreName,
    required List<String> songIds,
  }) async {
    final payload =
        await _apiClient.post(
              '/artist/albums',
              body: {
                'title': title,
                if (genreName != null && genreName.isNotEmpty)
                  'genreName': genreName,
                'songIds': songIds,
              },
            )
            as Map<String, dynamic>;
    return Album.fromJson(payload);
  }

  Future<Song> assignSongToAlbum({
    required String songId,
    String? albumId,
  }) async {
    final payload =
        await _apiClient.patch(
              '/artist/songs/$songId/album',
              body: {'albumId': albumId},
            )
            as Map<String, dynamic>;
    return Song.fromJson(payload);
  }
}

class AdminService {
  AdminService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<AdminUser>> listUsers() async {
    final payload = await _apiClient.get('/admin/users') as List<dynamic>;
    return payload
        .whereType<Map<String, dynamic>>()
        .map(AdminUser.fromJson)
        .toList();
  }

  Future<AdminUser> updateUserStatus(String userId, String status) async {
    final payload =
        await _apiClient.patch(
              '/admin/users/$userId/status',
              body: {'status': status},
            )
            as Map<String, dynamic>;
    return AdminUser.fromJson(payload);
  }

  Future<Song> uploadSong({
    required PlatformFile file,
    required String title,
    required String artistName,
    required String genreName,
    required String durationSeconds,
  }) async {
    final payload =
        await _apiClient.multipart(
              '/admin/songs',
              file: file,
              fields: {
                'title': title,
                'artistName': artistName,
                'genreName': genreName,
                'durationSeconds': durationSeconds,
              },
            )
            as Map<String, dynamic>;
    return Song.fromJson(payload);
  }

  Future<Album> createAlbum({
    required String title,
    String? artistName,
    String? genreName,
    required List<String> songIds,
  }) async {
    final payload =
        await _apiClient.post(
              '/admin/albums',
              body: {
                'title': title,
                if (artistName != null && artistName.isNotEmpty)
                  'artistName': artistName,
                if (genreName != null && genreName.isNotEmpty)
                  'genreName': genreName,
                'songIds': songIds,
              },
            )
            as Map<String, dynamic>;
    return Album.fromJson(payload);
  }

  Future<Song> assignSongToAlbum({
    required String songId,
    String? albumId,
  }) async {
    final payload =
        await _apiClient.patch(
              '/admin/songs/$songId/album',
              body: {'albumId': albumId},
            )
            as Map<String, dynamic>;
    return Song.fromJson(payload);
  }

  Future<Song> deleteSong(String songId) async {
    final payload =
        await _apiClient.delete('/admin/songs/$songId') as Map<String, dynamic>;
    return Song.fromJson(payload);
  }
}

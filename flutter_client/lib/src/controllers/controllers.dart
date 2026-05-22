import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../core/api/api_exception.dart';
import '../core/storage/session_storage.dart';
import '../models/domain_models.dart';
import '../services/services.dart';

String _friendlyError(Object error) {
  if (error is ApiException) {
    return error.message;
  }
  return 'Ocurrio un error inesperado';
}

class AuthController extends ChangeNotifier {
  AuthController({
    required AuthService authService,
    required SessionStorage storage,
  })  : _authService = authService,
        _storage = storage;

  final AuthService _authService;
  final SessionStorage _storage;

  AuthSession? _session;
  bool _bootstrapping = true;
  bool _busy = false;
  String? _error;
  Future<bool>? _refreshTask;

  AuthSession? get session => _session;
  UserProfile? get user => _session?.user;
  String? get accessToken => _session?.accessToken;
  String? get refreshToken => _session?.refreshToken;
  bool get isAuthenticated => _session != null;
  bool get isBootstrapping => _bootstrapping;
  bool get isBusy => _busy;
  String? get error => _error;

  Future<void> bootstrap() async {
    try {
      final stored = _storage.readSession();
      if (stored == null) {
        _session = null;
        return;
      }

      _session = stored;
      final user = await _authService.me(stored.accessToken);
      _session = AuthSession(
        accessToken: stored.accessToken,
        refreshToken: stored.refreshToken,
        user: user,
      );
      await _storage.saveSession(_session!);
    } catch (_) {
      final refreshed = await refreshSessionSilently();
      if (!refreshed) {
        await _clearSession();
      }
    } finally {
      _bootstrapping = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _runBusy(() async {
      _session = await _authService.login(email: email, password: password);
      await _storage.saveSession(_session!);
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String accountType,
    String? artistName,
  }) async {
    await _runBusy(() async {
      _session = await _authService.register(
        name: name,
        email: email,
        password: password,
        accountType: accountType,
        artistName: artistName,
      );
      await _storage.saveSession(_session!);
    });
  }

  Future<void> logout() async {
    final currentRefresh = refreshToken;
    await _clearSession();
    if (currentRefresh != null && currentRefresh.isNotEmpty) {
      try {
        await _authService.logout(currentRefresh);
      } catch (_) {}
    }
  }

  Future<void> forceLogout() async {
    await _clearSession();
  }

  Future<bool> refreshSessionSilently() {
    final running = _refreshTask;
    if (running != null) {
      return running;
    }

    final token = refreshToken;
    if (token == null || token.isEmpty) {
      return Future.value(false);
    }

    final task = _doRefresh(token);
    _refreshTask = task;
    task.whenComplete(() => _refreshTask = null);
    return task;
  }

  Future<bool> _doRefresh(String token) async {
    try {
      final refreshed = await _authService.refresh(token);
      _session = refreshed;
      await _storage.saveSession(refreshed);
      notifyListeners();
      return true;
    } catch (_) {
      await _clearSession();
      return false;
    }
  }

  Future<void> _runBusy(Future<void> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      _error = _friendlyError(error);
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> _clearSession() async {
    _session = null;
    await _storage.clear();
    notifyListeners();
  }
}

class CatalogController extends ChangeNotifier {
  CatalogController({
    required CatalogService catalogService,
    required HistoryService historyService,
  })  : _catalogService = catalogService,
        _historyService = historyService;

  final CatalogService _catalogService;
  final HistoryService _historyService;

  List<Song> songs = const [];
  List<Album> albums = const [];
  bool loading = false;
  String query = '';
  String? error;

  Future<void> load({String? searchQuery}) async {
    loading = true;
    error = null;
    if (searchQuery != null) {
      query = searchQuery;
    }
    notifyListeners();

    try {
      songs = await _catalogService.listSongs(query: query);
      albums = await _catalogService.listAlbums();
      if (query.trim().isNotEmpty) {
        await _historyService.registerInteraction(
          interactionType: 'search',
          interactionValue: query.trim(),
          metadata: {'results': songs.length},
        );
      }
    } catch (err) {
      error = _friendlyError(err);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<Album?> loadAlbum(String albumId) async {
    try {
      return await _catalogService.getAlbum(albumId);
    } catch (err) {
      error = _friendlyError(err);
      notifyListeners();
      return null;
    }
  }
}

class FavoritesController extends ChangeNotifier {
  FavoritesController({required FavoritesService favoritesService})
      : _favoritesService = favoritesService;

  final FavoritesService _favoritesService;

  List<Song> favorites = const [];
  bool loading = false;
  String? error;

  Set<String> get ids => favorites.map((song) => song.id).toSet();

  bool contains(String songId) => ids.contains(songId);

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      favorites = await _favoritesService.list();
    } catch (err) {
      error = _friendlyError(err);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> toggle(Song song) async {
    try {
      if (contains(song.id)) {
        await _favoritesService.remove(song.id);
      } else {
        await _favoritesService.add(song.id);
      }
      await load();
    } catch (err) {
      error = _friendlyError(err);
      notifyListeners();
    }
  }
}

class PlaylistsController extends ChangeNotifier {
  PlaylistsController({required PlaylistsService playlistsService})
      : _playlistsService = playlistsService;

  final PlaylistsService _playlistsService;

  List<PlaylistSummary> playlists = const [];
  final Map<String, PlaylistDetail> details = {};
  bool loading = false;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      playlists = await _playlistsService.list();
    } catch (err) {
      error = _friendlyError(err);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> create({
    required String name,
    String? description,
    bool isPublic = false,
  }) async {
    try {
      await _playlistsService.create(
        name: name,
        description: description,
        isPublic: isPublic,
      );
      await load();
    } catch (err) {
      error = _friendlyError(err);
      notifyListeners();
      rethrow;
    }
  }

  Future<PlaylistDetail?> open(String playlistId) async {
    try {
      final detail = await _playlistsService.detail(playlistId);
      details[playlistId] = detail;
      notifyListeners();
      return detail;
    } catch (err) {
      error = _friendlyError(err);
      notifyListeners();
      return null;
    }
  }

  Future<void> addSong({
    required String playlistId,
    required String songId,
  }) async {
    try {
      final detail = await _playlistsService.addSong(playlistId, songId);
      details[playlistId] = detail;
      await load();
    } catch (err) {
      error = _friendlyError(err);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeSong({
    required String playlistId,
    required String songId,
  }) async {
    try {
      final detail = await _playlistsService.removeSong(playlistId, songId);
      details[playlistId] = detail;
      await load();
    } catch (err) {
      error = _friendlyError(err);
      notifyListeners();
    }
  }
}

class HistoryController extends ChangeNotifier {
  HistoryController({required HistoryService historyService})
      : _historyService = historyService;

  final HistoryService _historyService;

  List<HistoryEntry> entries = const [];
  bool loading = false;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      entries = await _historyService.list();
    } catch (err) {
      error = _friendlyError(err);
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

class RecommendationsController extends ChangeNotifier {
  RecommendationsController({required RecommendationsService recommendationsService})
      : _recommendationsService = recommendationsService;

  final RecommendationsService _recommendationsService;

  List<RecommendationItem> items = const [];
  bool loading = false;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _recommendationsService.list();
    } catch (err) {
      error = _friendlyError(err);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await _recommendationsService.refresh();
      items = await _recommendationsService.list();
    } catch (err) {
      error = _friendlyError(err);
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

class PlayerController extends ChangeNotifier {
  PlayerController({
    required StreamingService streamingService,
    required HistoryService historyService,
  })  : _streamingService = streamingService,
        _historyService = historyService {
    _positionSub = _audioPlayer.onPositionChanged.listen((value) {
      position = value;
      notifyListeners();
    });
    _durationSub = _audioPlayer.onDurationChanged.listen((value) {
      duration = value;
      notifyListeners();
    });
    _stateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying = state == PlayerState.playing;
      notifyListeners();
      if (state == PlayerState.completed) {
        unawaited(_finalizeCurrentSong(markCompleted: true));
      }
    });
  }

  final StreamingService _streamingService;
  final HistoryService _historyService;
  final AudioPlayer _audioPlayer = AudioPlayer();

  late final StreamSubscription<Duration> _positionSub;
  late final StreamSubscription<Duration> _durationSub;
  late final StreamSubscription<PlayerState> _stateSub;

  Song? currentSong;
  bool loading = false;
  bool isPlaying = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  String? error;
  bool _reportedCurrentSong = false;

  Future<void> playSong(Song song, {String source = 'catalog'}) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      if (currentSong?.id != song.id) {
        await _finalizeCurrentSong();
      }

      final stream = await _streamingService.fetchSong(song.id);
      currentSong = song;
      _reportedCurrentSong = false;
      position = Duration.zero;
      duration = Duration(seconds: song.durationSeconds);

      await _audioPlayer.stop();
      await _audioPlayer.play(
        BytesSource(
          Uint8List.fromList(stream.bytes),
          mimeType: stream.mimeType,
        ),
      );

      await _historyService.registerInteraction(
        songId: song.id,
        interactionType: source == 'recommendation' ? 'recommendation_click' : 'play',
        metadata: {'source': source},
      );
    } catch (err) {
      error = _friendlyError(err);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    if (currentSong == null) {
      return;
    }
    await _audioPlayer.pause();
    await _historyService.registerInteraction(
      songId: currentSong!.id,
      interactionType: 'pause',
    );
  }

  Future<void> resume() async {
    if (currentSong == null) {
      return;
    }
    await _audioPlayer.resume();
    await _historyService.registerInteraction(
      songId: currentSong!.id,
      interactionType: 'resume',
    );
  }

  Future<void> seekRelative(int seconds) async {
    if (currentSong == null) {
      return;
    }

    final total = duration.inSeconds <= 0
        ? currentSong!.durationSeconds
        : duration.inSeconds;
    final next = (position.inSeconds + seconds).clamp(0, total);
    await _audioPlayer.seek(Duration(seconds: next));
    await _historyService.registerInteraction(
      songId: currentSong!.id,
      interactionType: seconds >= 0 ? 'skip_forward' : 'skip_backward',
      metadata: {'seconds': seconds.abs()},
    );
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    await _finalizeCurrentSong();
  }

  Future<void> _finalizeCurrentSong({bool markCompleted = false}) async {
    final song = currentSong;
    if (song == null || _reportedCurrentSong) {
      return;
    }

    final playedSeconds = markCompleted
        ? (duration.inSeconds > 0 ? duration.inSeconds : song.durationSeconds)
        : position.inSeconds;
    final totalSeconds = duration.inSeconds > 0 ? duration.inSeconds : song.durationSeconds;
    final completionRate = totalSeconds == 0
        ? 0.0
        : (playedSeconds / totalSeconds * 100).clamp(0, 100).toDouble();

    _reportedCurrentSong = true;
    currentSong = markCompleted ? currentSong : null;

    try {
      await _historyService.registerPlay(
        songId: song.id,
        playedSeconds: playedSeconds,
        completionRate: completionRate,
        deviceType: kIsWeb
            ? 'web'
            : (Platform.isAndroid ? 'android' : 'web'),
      );
    } catch (_) {}

    if (!markCompleted) {
      currentSong = null;
      position = Duration.zero;
      duration = Duration.zero;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    unawaited(_audioPlayer.dispose());
    unawaited(_finalizeCurrentSong());
    _positionSub.cancel();
    _durationSub.cancel();
    _stateSub.cancel();
    super.dispose();
  }
}

class ArtistController extends ChangeNotifier {
  ArtistController({
    required ArtistService artistService,
    required FilePicker picker,
  })  : _artistService = artistService,
        _picker = picker;

  final ArtistService _artistService;
  final FilePicker _picker;

  List<Song> songs = const [];
  bool loading = false;
  bool submitting = false;
  String? error;
  PlatformFile? selectedFile;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      songs = await _artistService.listMySongs();
    } catch (err) {
      error = _friendlyError(err);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> pickFile() async {
    final result = await _picker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['mp3', 'wav', 'ogg'],
      withData: kIsWeb,
    );
    selectedFile = result?.files.single;
    notifyListeners();
  }

  Future<void> uploadSong({
    required String title,
    required String genreName,
    required String durationSeconds,
    String? collaboratorNames,
  }) async {
    final file = selectedFile;
    if (file == null) {
      error = 'Selecciona un archivo de audio';
      notifyListeners();
      return;
    }

    submitting = true;
    error = null;
    notifyListeners();
    try {
      await _artistService.uploadSong(
        file: file,
        title: title,
        genreName: genreName,
        durationSeconds: durationSeconds,
        collaboratorNames: collaboratorNames,
      );
      selectedFile = null;
      await load();
    } catch (err) {
      error = _friendlyError(err);
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  Future<void> setPublication(String songId, bool isPublished) async {
    submitting = true;
    error = null;
    notifyListeners();
    try {
      await _artistService.setPublication(songId, isPublished);
      await load();
    } catch (err) {
      error = _friendlyError(err);
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  Future<void> deleteSong(String songId) async {
    submitting = true;
    error = null;
    notifyListeners();
    try {
      await _artistService.deleteSong(songId);
      await load();
    } catch (err) {
      error = _friendlyError(err);
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  Future<void> createAlbum({
    required String title,
    String? genreName,
    required List<String> songIds,
  }) async {
    submitting = true;
    error = null;
    notifyListeners();
    try {
      await _artistService.createAlbum(
        title: title,
        genreName: genreName,
        songIds: songIds,
      );
      await load();
    } catch (err) {
      error = _friendlyError(err);
      rethrow;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  Future<void> assignSongToAlbum({
    required String songId,
    String? albumId,
  }) async {
    submitting = true;
    error = null;
    notifyListeners();
    try {
      await _artistService.assignSongToAlbum(songId: songId, albumId: albumId);
      await load();
    } catch (err) {
      error = _friendlyError(err);
      notifyListeners();
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}

class AdminController extends ChangeNotifier {
  AdminController({
    required AdminService adminService,
    required FilePicker picker,
  })  : _adminService = adminService,
        _picker = picker;

  final AdminService _adminService;
  final FilePicker _picker;

  List<AdminUser> users = const [];
  bool loading = false;
  bool submitting = false;
  String? error;
  PlatformFile? selectedFile;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      users = await _adminService.listUsers();
    } catch (err) {
      error = _friendlyError(err);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> pickFile() async {
    final result = await _picker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['mp3', 'wav', 'ogg'],
      withData: kIsWeb,
    );
    selectedFile = result?.files.single;
    notifyListeners();
  }

  Future<void> updateUserStatus(String userId, String status) async {
    submitting = true;
    error = null;
    notifyListeners();
    try {
      await _adminService.updateUserStatus(userId, status);
      await load();
    } catch (err) {
      error = _friendlyError(err);
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  Future<void> uploadSong({
    required String title,
    required String artistName,
    required String genreName,
    required String durationSeconds,
  }) async {
    final file = selectedFile;
    if (file == null) {
      error = 'Selecciona un archivo de audio';
      notifyListeners();
      return;
    }

    submitting = true;
    error = null;
    notifyListeners();
    try {
      await _adminService.uploadSong(
        file: file,
        title: title,
        artistName: artistName,
        genreName: genreName,
        durationSeconds: durationSeconds,
      );
      selectedFile = null;
    } catch (err) {
      error = _friendlyError(err);
      rethrow;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  Future<void> createAlbum({
    required String title,
    String? artistName,
    String? genreName,
    required List<String> songIds,
  }) async {
    submitting = true;
    error = null;
    notifyListeners();
    try {
      await _adminService.createAlbum(
        title: title,
        artistName: artistName,
        genreName: genreName,
        songIds: songIds,
      );
    } catch (err) {
      error = _friendlyError(err);
      rethrow;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  Future<void> deleteSong(String songId) async {
    submitting = true;
    error = null;
    notifyListeners();
    try {
      await _adminService.deleteSong(songId);
    } catch (err) {
      error = _friendlyError(err);
      rethrow;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  Future<void> assignSongToAlbum({
    required String songId,
    String? albumId,
  }) async {
    submitting = true;
    error = null;
    notifyListeners();
    try {
      await _adminService.assignSongToAlbum(songId: songId, albumId: albumId);
    } catch (err) {
      error = _friendlyError(err);
      notifyListeners();
      rethrow;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}

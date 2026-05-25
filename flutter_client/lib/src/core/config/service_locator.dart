import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import 'app_config.dart';
import '../storage/session_storage.dart';
import '../../controllers/controllers.dart';
import '../../services/services.dart';

/// Patrón Singleton + Factory — ServiceLocator
///
/// Centraliza la creación e inyección de dependencias de la app.
/// Una única instancia (Singleton) contiene todos los servicios y
/// controladores, evitando que `main.dart` se convierta en un archivo
/// de cientos de líneas de wiring manual.
///
/// Uso:
///   await ServiceLocator.instance.initialize();
///   final auth = ServiceLocator.instance.authController;
class ServiceLocator {
  // ─── Singleton ─────────────────────────────────────────────────────────────

  ServiceLocator._();
  static final ServiceLocator instance = ServiceLocator._();

  // ─── Estado ────────────────────────────────────────────────────────────────

  bool _initialized = false;

  // ─── Servicios (acceso público de solo lectura) ────────────────────────────

  late final AuthController authController;
  late final CatalogController catalogController;
  late final FavoritesController favoritesController;
  late final PlaylistsController playlistsController;
  late final HistoryController historyController;
  late final RecommendationsController recommendationsController;
  late final PlayerController playerController;
  late final ArtistController artistController;
  late final AdminController adminController;
  late final DeployController deployController;

  // ─── Inicialización (Factory interno) ─────────────────────────────────────

  /// Construye y conecta todas las dependencias.
  /// Debe llamarse una sola vez en `main()` antes de `runApp()`.
  Future<void> initialize() async {
    if (_initialized) return;

    // ── Infraestructura ──────────────────────────────────────────────────────
    final preferences = await SharedPreferences.getInstance();
    final storage = SessionStorage(preferences);

    final authService = AuthService(
      baseUrl: AppConfig.apiBaseUrl,
      client: http.Client(),
    );

    authController = AuthController(authService: authService, storage: storage);

    final apiClient = ApiClient(
      baseUrl: AppConfig.apiBaseUrl,
      client: http.Client(),
      accessTokenProvider: () => authController.accessToken,
      refreshSession: authController.refreshSessionSilently,
      onUnauthorized: authController.forceLogout,
    );

    // ── Servicios de dominio ─────────────────────────────────────────────────
    final catalogService = CatalogService(apiClient);
    final favoritesService = FavoritesService(apiClient);
    final playlistsService = PlaylistsService(apiClient);
    final historyService = HistoryService(apiClient);
    final recommendationsService = RecommendationsService(apiClient);
    final streamingService = StreamingService(apiClient);
    final artistService = ArtistService(apiClient);
    final adminService = AdminService(apiClient);
    final deployService = DeployService(apiClient);

    // ── Controladores ────────────────────────────────────────────────────────
    catalogController = CatalogController(
      catalogService: catalogService,
      historyService: historyService,
    );
    favoritesController = FavoritesController(
      favoritesService: favoritesService,
    );
    playlistsController = PlaylistsController(
      playlistsService: playlistsService,
    );
    historyController = HistoryController(historyService: historyService);
    recommendationsController = RecommendationsController(
      recommendationsService: recommendationsService,
    );
    playerController = PlayerController(
      streamingService: streamingService,
      historyService: historyService,
      historyController: historyController,
    );
    artistController = ArtistController(
      artistService: artistService,
      picker: FilePicker.platform,
    );
    adminController = AdminController(
      adminService: adminService,
      picker: FilePicker.platform,
    );
    deployController = DeployController(deployService: deployService);

    // ── Bootstrap de sesión ──────────────────────────────────────────────────
    await authController.bootstrap();

    _initialized = true;
  }
}

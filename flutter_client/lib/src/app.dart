import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/controllers.dart';
import 'core/app_config.dart';
import 'views/app_shell.dart';
import 'views/auth_page.dart';

class SoundStreamApp extends StatelessWidget {
  const SoundStreamApp({
    super.key,
    required this.authController,
    required this.catalogController,
    required this.favoritesController,
    required this.playlistsController,
    required this.historyController,
    required this.recommendationsController,
    required this.playerController,
    required this.artistController,
    required this.adminController,
  });

  final AuthController authController;
  final CatalogController catalogController;
  final FavoritesController favoritesController;
  final PlaylistsController playlistsController;
  final HistoryController historyController;
  final RecommendationsController recommendationsController;
  final PlayerController playerController;
  final ArtistController artistController;
  final AdminController adminController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: authController),
        ChangeNotifierProvider<CatalogController>.value(value: catalogController),
        ChangeNotifierProvider<FavoritesController>.value(value: favoritesController),
        ChangeNotifierProvider<PlaylistsController>.value(value: playlistsController),
        ChangeNotifierProvider<HistoryController>.value(value: historyController),
        ChangeNotifierProvider<RecommendationsController>.value(
          value: recommendationsController,
        ),
        ChangeNotifierProvider<PlayerController>.value(value: playerController),
        ChangeNotifierProvider<ArtistController>.value(value: artistController),
        ChangeNotifierProvider<AdminController>.value(value: adminController),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0B7285),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF4F7F8),
          cardTheme: const CardThemeData(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: Colors.black12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFF0B7285), width: 1.4),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
          useMaterial3: true,
        ),
        home: const _RootView(),
      ),
    );
  }
}

class _RootView extends StatelessWidget {
  const _RootView();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        if (auth.isBootstrapping) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!auth.isAuthenticated) {
          return const AuthPage();
        }

        return const AppShell();
      },
    );
  }
}

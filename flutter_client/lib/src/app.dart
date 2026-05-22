import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/controllers.dart';
import 'core/config/app_config.dart';
import 'features/auth/views/auth_page.dart';
import 'features/layout/views/app_shell.dart';
import 'theme/app_theme.dart';

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
        ChangeNotifierProvider<CatalogController>.value(
          value: catalogController,
        ),
        ChangeNotifierProvider<FavoritesController>.value(
          value: favoritesController,
        ),
        ChangeNotifierProvider<PlaylistsController>.value(
          value: playlistsController,
        ),
        ChangeNotifierProvider<HistoryController>.value(
          value: historyController,
        ),
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
        theme: AppTheme.dark,
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

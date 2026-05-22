import 'package:flutter/widgets.dart';

import 'src/app.dart';
import 'src/core/config/service_locator.dart';

/// Punto de entrada de la app.
///
/// El Singleton ServiceLocator inicializa todas las dependencias
/// (Factory interno) y luego runApp() los recibe listos.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Un solo punto de inicialización — Singleton + Factory
  await ServiceLocator.instance.initialize();

  final sl = ServiceLocator.instance;

  runApp(
    SoundStreamApp(
      authController: sl.authController,
      catalogController: sl.catalogController,
      favoritesController: sl.favoritesController,
      playlistsController: sl.playlistsController,
      historyController: sl.historyController,
      recommendationsController: sl.recommendationsController,
      playerController: sl.playerController,
      artistController: sl.artistController,
      adminController: sl.adminController,
    ),
  );
}

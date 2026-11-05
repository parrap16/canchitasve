import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Punto de entrada de la aplicación CAIMANEROS.
///
/// Orden de inicialización:
/// 1. Carga de variables de entorno (.env)
/// 2. Inicialización del cliente Supabase
/// 3. Montaje del árbol de widgets envuelto en [ProviderScope]
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Variables de entorno
  await dotenv.load(fileName: '.env');

  // 2. Supabase
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    // ignore: deprecated_member_use
    anonKey: EnvConfig.supabaseAnonKey,
    debug: EnvConfig.isDevelopment,
  );

  // 3. App
  runApp(
    const ProviderScope(
      child: CaimanerosApp(),
    ),
  );
}

/// Widget raíz de la aplicación.
class CaimanerosApp extends ConsumerWidget {
  const CaimanerosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Caimaneros',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}

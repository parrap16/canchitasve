import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/complejos/presentation/pages/complejo_detalle_page.dart';
import '../../features/complejos/presentation/pages/complejos_list_page.dart';
import '../../features/complejos/presentation/pages/complejos_map_page.dart';
import '../services/supabase_service.dart';

/// Rutas nombradas de la aplicación CAIMANEROS.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String mapa = '/mapa';
  static const String complejoDetalle = '/complejos/:id';
}

/// Provider del router de la aplicación.
final appRouterProvider = Provider<GoRouter>((ref) {
  final supabase = ref.watch(supabaseClientProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final session = supabase.auth.currentSession;
      final isAuthenticated = session != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      // Si no está autenticado y no está en ruta de auth, redirigir a login
      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.login;
      }
      // Si ya está autenticado e intenta ir a login/register, redirigir a home
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const ComplejosListPage(),
      ),
      GoRoute(
        path: AppRoutes.mapa,
        builder: (context, state) => const ComplejosMapPage(),
      ),
      GoRoute(
        path: AppRoutes.complejoDetalle,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ComplejoDetallePage(complejoId: id);
        },
      ),
    ],
  );
});

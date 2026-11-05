import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centraliza el acceso a las variables de entorno.
///
/// Lanza un [StateError] con un mensaje descriptivo si alguna variable
/// obligatoria no está definida, previniendo fallos silenciosos en runtime.
abstract final class EnvConfig {
  // ── Supabase ────────────────────────────────────────────────────────────────

  static String get supabaseUrl => _require('SUPABASE_URL');

  static String get supabaseAnonKey => _require('SUPABASE_ANON_KEY');

  // ── Entorno ─────────────────────────────────────────────────────────────────

  static String get appEnv => dotenv.get('APP_ENV', fallback: 'production');

  static bool get isDevelopment => appEnv == 'development';

  static bool get isProduction => appEnv == 'production';

  // ── Feature flags ───────────────────────────────────────────────────────────

  static bool get enableFantasyModule =>
      dotenv.get('ENABLE_FANTASY_MODULE', fallback: 'false') == 'true';

  static bool get enablePushNotifications =>
      dotenv.get('ENABLE_PUSH_NOTIFICATIONS', fallback: 'false') == 'true';

  // ── Helpers privados ────────────────────────────────────────────────────────

  static String _require(String key) {
    final value = dotenv.maybeGet(key);
    if (value == null || value.isEmpty) {
      throw StateError(
        '[EnvConfig] Variable de entorno obligatoria "$key" no encontrada. '
        'Asegúrate de que el archivo .env existe y contiene "$key".',
      );
    }
    return value;
  }
}

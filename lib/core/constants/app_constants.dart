/// Constantes globales de la aplicación.
///
/// No instancies esta clase; úsala como namespace de constantes.
abstract final class AppConstants {
  // ── Supabase / Base de datos ─────────────────────────────────────────────────
  static const String tableUsuarios = 'usuarios';
  static const String tableGrupos = 'grupos';
  static const String tableMiembros = 'miembros_grupo';
  static const String tablePartidos = 'partidos';
  static const String tableEventos = 'eventos_partido';
  static const String tableFantasyLineups = 'fantasy_lineups';

  // ── Límites de negocio ───────────────────────────────────────────────────────
  static const int maxJugadoresPorEquipo = 11;
  static const int minJugadoresPorEquipo = 5;
  static const int maxGruposPorUsuario = 10;

  // ── Timeouts de red (ms) ────────────────────────────────────────────────────
  static const Duration requestTimeout = Duration(seconds: 15);

  // ── Paginación ───────────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ── Assets ───────────────────────────────────────────────────────────────────
  static const String logoPath = 'assets/images/logo.png';
  static const String defaultAvatarPath = 'assets/images/default_avatar.png';
}

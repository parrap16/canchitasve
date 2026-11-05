import 'package:logger/logger.dart';

/// Logger global de la aplicación.
///
/// Uso:
/// ```dart
/// AppLogger.info('Partido creado', data: partido.toJson());
/// AppLogger.error('Error al cargar grupos', error: e, stackTrace: st);
/// ```
abstract final class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
    // En producción sube el nivel para no exponer información sensible
    level: Level.debug,
  );

  static void debug(String message, {Object? data}) =>
      _logger.d(message, error: data);

  static void info(String message, {Object? data}) =>
      _logger.i(message, error: data);

  static void warning(String message, {Object? data}) =>
      _logger.w(message, error: data);

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}

import 'package:fpdart/fpdart.dart';
import 'app_failure.dart';

/// Alias de tipo para operaciones que pueden fallar.
///
/// [L] es siempre [AppFailure]; [R] es el tipo del resultado exitoso.
///
/// Ejemplo:
/// ```dart
/// Future<AppResult<List<Partido>>> obtenerPartidos();
/// ```
typedef AppResult<R> = Future<Either<AppFailure, R>>;

/// Alias síncrono para resultados que no son asíncronos.
typedef AppResultSync<R> = Either<AppFailure, R>;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/app_failure.dart';

/// Extensiones sobre [PostgrestException] y [AuthException] para
/// convertirlos en [AppFailure] de dominio.
///
/// Uso típico en un repositorio:
/// ```dart
/// } on AuthException catch (e) {
///   return Left(e.toAuthFailure());
/// } on PostgrestException catch (e) {
///   return Left(e.toDatabaseFailure());
/// } catch (e, st) {
///   return Left(AppFailure.unexpected(message: e.toString(), error: e));
/// }
/// ```
extension PostgrestExceptionX on PostgrestException {
  AppFailure toDatabaseFailure() => AppFailure.database(
        message: message,
        hint: hint,
      );
}

extension AuthExceptionX on AuthException {
  AppFailure toAuthFailure() => AppFailure.auth(
        message: message,
        code: statusCode,
      );
}

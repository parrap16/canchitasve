/// Jerarquía sellada de errores de dominio de CAIMANEROS (Dart 3 Sealed Classes).
sealed class AppFailure {
  const AppFailure({required this.message});

  final String message;

  const factory AppFailure.network({
    required String message,
    int? statusCode,
  }) = NetworkFailure;

  const factory AppFailure.auth({
    required String message,
    String? code,
  }) = AuthFailure;

  const factory AppFailure.database({
    required String message,
    String? hint,
  }) = DatabaseFailure;

  const factory AppFailure.validation({
    required String message,
    Map<String, String>? fieldErrors,
  }) = ValidationFailure;

  const factory AppFailure.unexpected({
    required String message,
    Object? error,
  }) = UnexpectedFailure;

  const factory AppFailure.notFound({
    required String message,
  }) = NotFoundFailure;

  const factory AppFailure.forbidden({
    required String message,
  }) = ForbiddenFailure;
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure({required super.message, this.statusCode});
  final int? statusCode;
}

final class AuthFailure extends AppFailure {
  const AuthFailure({required super.message, this.code});
  final String? code;
}

final class DatabaseFailure extends AppFailure {
  const DatabaseFailure({required super.message, this.hint});
  final String? hint;
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure({required super.message, this.fieldErrors});
  final Map<String, String>? fieldErrors;
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure({required super.message, this.error});
  final Object? error;
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure({required super.message});
}

final class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure({required super.message});
}

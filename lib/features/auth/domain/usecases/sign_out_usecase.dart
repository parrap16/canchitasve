import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/app_result.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../repositories/i_auth_repository.dart';

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

/// Caso de uso: cerrar sesión.
class SignOutUseCase {
  const SignOutUseCase(this._repository);

  final IAuthRepository _repository;

  AppResult<Unit> call() => _repository.signOut();
}

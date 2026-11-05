import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/app_result.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../entities/usuario_perfil.dart';
import '../repositories/i_auth_repository.dart';

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

/// Caso de uso: iniciar sesión con email y contraseña.
class SignInUseCase {
  const SignInUseCase(this._repository);

  final IAuthRepository _repository;

  AppResult<UsuarioPerfil> call({
    required String email,
    required String password,
  }) {
    if (email.isEmpty || !email.contains('@')) {
      return Future.value(
        const Left(AppFailure.auth(message: 'Email inválido')),
      );
    }
    if (password.length < 6) {
      return Future.value(
        const Left(AppFailure.auth(
          message: 'La contraseña debe tener mínimo 6 caracteres',
        )),
      );
    }
    return _repository.signInWithEmail(email: email, password: password);
  }
}

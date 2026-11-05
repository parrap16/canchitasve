import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/app_result.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../entities/usuario_perfil.dart';
import '../repositories/i_auth_repository.dart';

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

/// Caso de uso: registrar usuario con rol, nombre y teléfono.
class SignUpUseCase {
  const SignUpUseCase(this._repository);

  final IAuthRepository _repository;

  AppResult<UsuarioPerfil> call({
    required String email,
    required String password,
    required String nombre,
    required UserRole rol,
    String? telefono,
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
    if (nombre.trim().isEmpty) {
      return Future.value(
        const Left(AppFailure.auth(message: 'El nombre es obligatorio')),
      );
    }

    return _repository.signUpWithRole(
      email: email,
      password: password,
      nombre: nombre,
      rol: rol,
      telefono: telefono,
    );
  }
}

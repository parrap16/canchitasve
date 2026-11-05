import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/app_result.dart';
import '../entities/usuario.dart';
import '../entities/usuario_perfil.dart';

/// Contrato del repositorio de autenticación y perfiles de CAIMANEROS.
abstract interface class IAuthRepository {
  /// Devuelve el usuario actualmente autenticado, o null si no hay sesión.
  AppResultSync<Usuario?> getCurrentUser();

  /// Obtiene el perfil completo desde la tabla `perfiles`.
  Future<Either<AppFailure, UsuarioPerfil?>> getCurrentProfile();

  /// Inicia sesión con email y contraseña.
  AppResult<UsuarioPerfil> signInWithEmail({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario definiendo explícitamente su rol (jugador o administrador),
  /// nombre y teléfono.
  AppResult<UsuarioPerfil> signUpWithRole({
    required String email,
    required String password,
    required String nombre,
    required UserRole rol,
    String? telefono,
  });

  /// Cierra la sesión del usuario actual.
  AppResult<Unit> signOut();

  /// Stream que emite el estado de sesión cada vez que cambia.
  Stream<Usuario?> get authStateChanges;
}

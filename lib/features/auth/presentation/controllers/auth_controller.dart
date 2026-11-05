import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/usuario_perfil.dart';
import '../../domain/repositories/i_auth_repository.dart';

/// Estado de la autenticación en CAIMANEROS.
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.perfil);
  final UsuarioPerfil perfil;
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthError extends AuthState {
  const AuthError(this.failure);
  final AppFailure failure;
}

/// Provider para el controlador de autenticación.
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(const AuthInitial()) {
    checkInitialAuth();
  }

  final IAuthRepository _repo;

  Future<void> checkInitialAuth() async {
    final userResult = _repo.getCurrentUser();
    await userResult.fold(
      (_) async => state = const AuthUnauthenticated(),
      (user) async {
        if (user == null) {
          state = const AuthUnauthenticated();
          return;
        }
        final perfilResult = await _repo.getCurrentProfile();
        perfilResult.fold(
          (_) => state = const AuthUnauthenticated(),
          (perfil) {
            if (perfil != null) {
              state = AuthAuthenticated(perfil);
            } else {
              state = const AuthUnauthenticated();
            }
          },
        );
      },
    );
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    final result = await _repo.signInWithEmail(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        state = AuthError(failure);
        return false;
      },
      (perfil) {
        state = AuthAuthenticated(perfil);
        return true;
      },
    );
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String nombre,
    required UserRole rol,
    String? telefono,
  }) async {
    state = const AuthLoading();
    final result = await _repo.signUpWithRole(
      email: email,
      password: password,
      nombre: nombre,
      rol: rol,
      telefono: telefono,
    );

    return result.fold(
      (failure) {
        state = AuthError(failure);
        return false;
      },
      (perfil) {
        state = AuthAuthenticated(perfil);
        return true;
      },
    );
  }

  Future<void> signOut() async {
    state = const AuthLoading();
    final result = await _repo.signOut();
    result.fold(
      (failure) => state = AuthError(failure),
      (_) => state = const AuthUnauthenticated(),
    );
  }
}

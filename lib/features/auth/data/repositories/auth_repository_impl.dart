import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/app_result.dart';
import '../../../../core/extensions/supabase_exception_ext.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/entities/usuario_perfil.dart';
import '../../domain/repositories/i_auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepositoryImpl(client);
});

/// Implementación de [IAuthRepository] usando Supabase Auth y tabla `perfiles`.
class AuthRepositoryImpl implements IAuthRepository {
  const AuthRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  AppResultSync<Usuario?> getCurrentUser() {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return const Right(null);
      return Right(
        Usuario(
          id: user.id,
          email: user.email ?? '',
          nombre: user.userMetadata?['nombre'] as String?,
          creadoEn: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
        ),
      );
    } catch (e) {
      return Left(AppFailure.unexpected(message: e.toString(), error: e));
    }
  }

  @override
  Future<Either<AppFailure, UsuarioPerfil?>> getCurrentProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return const Right(null);

      final response = await _client
          .from('perfiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        // Fallback desde metadata si el trigger de perfiles aún no se ejecutó
        return Right(
          UsuarioPerfil(
            id: user.id,
            rol: UserRole.fromString(user.userMetadata?['rol'] as String?),
            nombre: (user.userMetadata?['nombre'] as String?) ?? 'Usuario',
            telefono: user.userMetadata?['telefono'] as String?,
            email: user.email,
          ),
        );
      }

      final perfil = UsuarioPerfil.fromJson(
        response,
        email: user.email,
      );
      return Right(perfil);
    } catch (e, st) {
      AppLogger.error('getCurrentProfile error', error: e, stackTrace: st);
      return Left(AppFailure.unexpected(message: e.toString(), error: e));
    }
  }

  @override
  AppResult<UsuarioPerfil> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        return const Left(
          AppFailure.auth(message: 'No se pudo obtener la sesión del usuario'),
        );
      }

      // Obtener o inicializar perfil
      final perfilResult = await getCurrentProfile();
      final Either<AppFailure, UsuarioPerfil> authResult = perfilResult.fold(
        Left.new,
        (perfil) {
          if (perfil != null) return Right(perfil);
          return Right(
            UsuarioPerfil(
              id: user.id,
              rol: UserRole.fromString(user.userMetadata?['rol'] as String?),
              nombre: (user.userMetadata?['nombre'] as String?) ?? 'Usuario',
              telefono: user.userMetadata?['telefono'] as String?,
              email: user.email,
            ),
          );
        },
      );
      return authResult;
    } on AuthException catch (e, st) {
      AppLogger.error('signInWithEmail AuthException', error: e, stackTrace: st);
      return Left(e.toAuthFailure());
    } catch (e, st) {
      AppLogger.error('signInWithEmail error inesperado', error: e, stackTrace: st);
      return Left(AppFailure.unexpected(message: e.toString(), error: e));
    }
  }

  @override
  AppResult<UsuarioPerfil> signUpWithRole({
    required String email,
    required String password,
    required String nombre,
    required UserRole rol,
    String? telefono,
  }) async {
    try {
      final metadata = {
        'nombre': nombre,
        'rol': rol.value,
        if (telefono != null && telefono.isNotEmpty) 'telefono': telefono,
      };

      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );

      final user = response.user;
      if (user == null) {
        return const Left(
          AppFailure.auth(message: 'Error al registrar el usuario en Supabase'),
        );
      }

      // Asegurar registro directo en `perfiles`
      try {
        await _client.from('perfiles').upsert({
          'id': user.id,
          'rol': rol.value,
          'nombre': nombre,
          if (telefono != null && telefono.isNotEmpty) 'telefono': telefono,
        });
      } catch (dbError) {
        AppLogger.warning('Trigger o upsert de perfil: $dbError');
      }

      final perfil = UsuarioPerfil(
        id: user.id,
        rol: rol,
        nombre: nombre,
        telefono: telefono,
        email: email,
        createdAt: DateTime.now(),
      );

      return Right(perfil);
    } on AuthException catch (e, st) {
      AppLogger.error('signUpWithRole AuthException', error: e, stackTrace: st);
      return Left(e.toAuthFailure());
    } catch (e, st) {
      AppLogger.error('signUpWithRole error inesperado', error: e, stackTrace: st);
      return Left(AppFailure.unexpected(message: e.toString(), error: e));
    }
  }

  @override
  AppResult<Unit> signOut() async {
    try {
      await _client.auth.signOut();
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(e.toAuthFailure());
    } catch (e) {
      return Left(AppFailure.unexpected(message: e.toString(), error: e));
    }
  }

  @override
  Stream<Usuario?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((event) {
        final user = event.session?.user;
        if (user == null) return null;
        return Usuario(
          id: user.id,
          email: user.email ?? '',
          nombre: user.userMetadata?['nombre'] as String?,
          creadoEn: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
        );
      });
}

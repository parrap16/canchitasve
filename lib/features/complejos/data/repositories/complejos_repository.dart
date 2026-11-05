import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/complejo_deportivo.dart';

final complejosRepositoryProvider = Provider<ComplejosRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ComplejosRepository(client);
});

class ComplejosRepository {
  ComplejosRepository(this._supabase);

  final SupabaseClient _supabase;

  /// Obtiene todos los complejos deportivos activos con sus canchas asociadas.
  Future<Either<AppFailure, List<ComplejoDeportivo>>> getComplejos({
    int? formato,
  }) async {
    try {
      final response = await _supabase
          .from('complejos_deportivos')
          .select('*, canchas(*)')
          .order('nombre', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      final complejos = data
          .map((item) => ComplejoDeportivo.fromJson(item as Map<String, dynamic>))
          .where((complejo) => complejo.hasFormato(formato))
          .toList();

      return Right(complejos);
    } on PostgrestException catch (e) {
      return Left(
        AppFailure.database(
          message: e.message,
          hint: e.hint,
        ),
      );
    } catch (e) {
      return Left(
        AppFailure.unexpected(
          message: e.toString(),
          error: e,
        ),
      );
    }
  }

  /// Obtiene el detalle de un complejo por su ID con sus canchas.
  Future<Either<AppFailure, ComplejoDeportivo>> getComplejoById(String id) async {
    try {
      final response = await _supabase
          .from('complejos_deportivos')
          .select('*, canchas(*)')
          .eq('id', id)
          .single();

      final complejo = ComplejoDeportivo.fromJson(response);
      return Right(complejo);
    } on PostgrestException catch (e) {
      return Left(
        AppFailure.database(
          message: e.message,
          hint: e.hint,
        ),
      );
    } catch (e) {
      return Left(
        AppFailure.unexpected(
          message: e.toString(),
          error: e,
        ),
      );
    }
  }
}

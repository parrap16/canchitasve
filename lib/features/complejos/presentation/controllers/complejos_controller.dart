import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../data/repositories/complejos_repository.dart';
import '../../domain/entities/complejo_deportivo.dart';

/// Filtro de formato de cancha activo (null = Todos, 5 = F5, 7 = F7, 11 = F11).
final formatoFiltroProvider = StateProvider<int?>((ref) => null);

/// Complejo seleccionado en el mapa interactivo (para mostrar tarjeta preview).
final complejoSeleccionadoProvider = StateProvider<ComplejoDeportivo?>((ref) => null);

/// Provider de lista de complejos deportivos filtrados por formato.
final complejosListProvider =
    FutureProvider.autoDispose<List<ComplejoDeportivo>>((ref) async {
  final repo = ref.watch(complejosRepositoryProvider);
  final formato = ref.watch(formatoFiltroProvider);

  final result = await repo.getComplejos(formato: formato);
  return result.fold(
    (AppFailure failure) => throw Exception(failure.message),
    (List<ComplejoDeportivo> complejos) => complejos,
  );
});

/// Provider para obtener un complejo específico por su ID.
final complejoDetalleProvider = FutureProvider.autoDispose
    .family<ComplejoDeportivo, String>((ref, id) async {
  final repo = ref.watch(complejosRepositoryProvider);
  final result = await repo.getComplejoById(id);
  return result.fold(
    (AppFailure failure) => throw Exception(failure.message),
    (ComplejoDeportivo complejo) => complejo,
  );
});

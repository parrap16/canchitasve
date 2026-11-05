import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Expone el cliente global de Supabase como un provider inmutable.
///
/// Úsalo en repositorios y servicios via `ref.watch(supabaseClientProvider)`.
/// No instancies [SupabaseClient] directamente en ningún otro lugar.
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

/// Provider de conveniencia para el módulo de autenticación de Supabase.
final supabaseAuthProvider = Provider<GoTrueClient>(
  (ref) => ref.watch(supabaseClientProvider).auth,
);

// Alias de GoTrueClient para no depender del nombre interno del paquete
// en los imports de features.
typedef SupabaseAuth = GoTrueClient;

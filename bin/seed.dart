import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase/supabase.dart';

/// Script de prueba / seed para poblar la base de datos de CAIMANEROS (Fase 1).
///
/// Ejecutar con:
///   dart run bin/seed.dart
///
/// O ejecutar las sentencias SQL generadas directamente en el SQL Editor de Supabase.
void main() async {
  stdout.writeln('==============================================');
  stdout.writeln('CAIMANEROS — Script de Inicialización (Seed)');
  stdout.writeln('==============================================');

  // 1. Cargar variables de entorno
  final envFile = File('.env');
  if (await envFile.exists()) {
    await dotenv.load(fileName: '.env');
  }

  final supabaseUrl = dotenv.maybeGet('SUPABASE_URL') ??
      Platform.environment['SUPABASE_URL'] ??
      '';
  final supabaseKey = dotenv.maybeGet('SUPABASE_ANON_KEY') ??
      dotenv.maybeGet('SUPABASE_SERVICE_ROLE_KEY') ??
      Platform.environment['SUPABASE_ANON_KEY'] ??
      '';

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    stdout.writeln(
      '⚠️ Error: SUPABASE_URL o SUPABASE_ANON_KEY no están configuradas en .env.\n'
      'Asegúrate de configurar el archivo .env con las credenciales de tu proyecto Supabase.',
    );
    exit(1);
  }

  stdout.writeln('📡 Conectando a Supabase ($supabaseUrl)...');
  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  try {
    // 2. Administrador de prueba
    // ID fijo de prueba para seed o primer usuario registrado
    const demoAdminId = 'a0000000-0000-0000-0000-000000000001';

    stdout.writeln('👤 Verificando perfil de administrador demo...');
    await supabase.from('perfiles').upsert({
      'id': demoAdminId,
      'rol': 'administrador',
      'nombre': 'Admin Caimaneros Maracaibo',
      'telefono': '+58 414 6123456',
    });

    // 3. Complejos Deportivos Reales (Maracaibo, Venezuela)
    final complejosSeed = [
      {
        'id': 'b1000000-0000-0000-0000-000000000001',
        'admin_id': demoAdminId,
        'nombre': 'Complejo Deportivo Vereda del Lago',
        'direccion': 'Paseo Vereda del Lago, Av. 2 El Milagro, Maracaibo, Zulia',
        // Referencia 1: Coordenadas Vereda del Lago (zona deportiva norte)
        'latitud': 10.655842,
        'longitud': -71.603518,
        'foto_url': 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=1200&auto=format&fit=crop',
        'precio_base': 25.00,
        'canchas': [
          {
            'formato': 5,
            'superficie': 'sintetica',
            'techada': false,
          },
          {
            'formato': 7,
            'superficie': 'sintetica',
            'techada': false,
          },
        ],
      },
      {
        'id': 'b2000000-0000-0000-0000-000000000002',
        'admin_id': demoAdminId,
        'nombre': 'Complejo Deportivo La Estancia',
        'direccion': 'Calle 67 con Av. 3D, Sector La Lago / Bella Vista, Maracaibo, Zulia',
        // Referencia 2: Coordenadas Sector La Lago / La Estancia Maracaibo
        'latitud': 10.678125,
        'longitud': -71.618450,
        'foto_url': 'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?q=80&w=1200&auto=format&fit=crop',
        'precio_base': 30.00,
        'canchas': [
          {
            'formato': 5,
            'superficie': 'sintetica',
            'techada': true,
          },
          {
            'formato': 5,
            'superficie': 'tabloncillo',
            'techada': true,
          },
          {
            'formato': 7,
            'superficie': 'sintetica',
            'techada': false,
          },
        ],
      },
      {
        'id': 'b3000000-0000-0000-0000-000000000003',
        'admin_id': demoAdminId,
        'nombre': 'San Francisco Futsal & Soccer Arena',
        'direccion': 'Av. 5 Urb. Coromoto, Sector Plaza El Sol, San Francisco, Zulia',
        'latitud': 10.612500,
        'longitud': -71.642100,
        'foto_url': 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=1200&auto=format&fit=crop',
        'precio_base': 35.00,
        'canchas': [
          {
            'formato': 5,
            'superficie': 'sintetica',
            'techada': true,
          },
          {
            'formato': 11,
            'superficie': 'sintetica',
            'techada': false,
          },
        ],
      },
    ];

    stdout.writeln('🏟️ Insertando complejos deportivos...');
    for (final c in complejosSeed) {
      final canchasData = c['canchas'] as List<Map<String, dynamic>>;
      final complejoRecord = Map<String, dynamic>.from(c)..remove('canchas');

      await supabase.from('complejos_deportivos').upsert(complejoRecord);
      stdout.writeln('  ✓ Complejo registrado: ${c['nombre']} (${c['latitud']}, ${c['longitud']})');

      for (final cancha in canchasData) {
        await supabase.from('canchas').upsert({
          'complejo_id': c['id'],
          'formato': cancha['formato'],
          'superficie': cancha['superficie'],
          'techada': cancha['techada'],
        });
        stdout.writeln('    - Cancha F${cancha['formato']} (${cancha['superficie']}, techada: ${cancha['techada']})');
      }
    }

    stdout.writeln('\n✅ ¡Base de datos poblada exitosamente para Fase 1!');
  } catch (e) {
    stdout.writeln('\n❌ Error durante el seed: $e');
  }
}

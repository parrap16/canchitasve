import 'cancha.dart';

/// Entidad de dominio para un Complejo Deportivo.
class ComplejoDeportivo {
  const ComplejoDeportivo({
    required this.id,
    required this.adminId,
    required this.nombre,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    this.fotoUrl,
    required this.precioBase,
    this.canchas = const <Cancha>[],
    this.createdAt,
  });

  final String id;
  final String adminId;
  final String nombre;
  final String direccion;
  final double latitud;
  final double longitud;
  final String? fotoUrl;
  final double precioBase;
  final List<Cancha> canchas;
  final DateTime? createdAt;

  List<int> get formatosDisponibles {
    final formatos = canchas.map((c) => c.formato).toSet().toList();
    formatos.sort();
    return formatos;
  }

  String get formatosBadge {
    if (formatosDisponibles.isEmpty) return 'F5';
    return formatosDisponibles.map((f) => 'F$f').join(' · ');
  }

  bool hasFormato(int? formato) {
    if (formato == null) return true;
    return canchas.any((c) => c.formato == formato);
  }

  factory ComplejoDeportivo.fromJson(Map<String, dynamic> json) {
    List<Cancha> canchasList = [];
    if (json['canchas'] is List) {
      canchasList = (json['canchas'] as List)
          .map((item) => Cancha.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return ComplejoDeportivo(
      id: json['id'] as String,
      adminId: json['admin_id'] as String,
      nombre: (json['nombre'] as String?) ?? 'Complejo Deportivo',
      direccion: (json['direccion'] as String?) ?? '',
      latitud: (json['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (json['longitud'] as num?)?.toDouble() ?? 0.0,
      fotoUrl: json['foto_url'] as String?,
      precioBase: (json['precio_base'] as num?)?.toDouble() ?? 0.0,
      canchas: canchasList,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admin_id': adminId,
      'nombre': nombre,
      'direccion': direccion,
      'latitud': latitud,
      'longitud': longitud,
      'foto_url': fotoUrl,
      'precio_base': precioBase,
    };
  }
}

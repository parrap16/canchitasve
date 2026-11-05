import '../../domain/entities/usuario.dart';

/// Modelo de datos (DTO) para la tabla `usuarios` en Supabase.
class UsuarioModel {
  const UsuarioModel({
    required this.id,
    required this.email,
    this.nombre,
    this.avatarUrl,
    required this.creadoEn,
  });

  final String id;
  final String email;
  final String? nombre;
  final String? avatarUrl;
  final DateTime creadoEn;

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      nombre: json['nombre'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      creadoEn: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'avatar_url': avatarUrl,
      'created_at': creadoEn.toIso8601String(),
    };
  }

  /// Convierte el DTO a la entidad de dominio.
  Usuario toDomain() => Usuario(
        id: id,
        email: email,
        nombre: nombre,
        avatarUrl: avatarUrl,
        creadoEn: creadoEn,
      );
}

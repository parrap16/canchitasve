/// Rol del usuario en el ecosistema CAIMANEROS.
enum UserRole {
  jugador('jugador', 'Jugador'),
  administrador('administrador', 'Administrador');

  const UserRole(this.value, this.label);
  final String value;
  final String label;

  static UserRole fromString(String? val) {
    if (val == 'administrador') return UserRole.administrador;
    return UserRole.jugador;
  }
}

/// Entidad de dominio para el perfil de usuario (tabla `perfiles`).
class UsuarioPerfil {
  const UsuarioPerfil({
    required this.id,
    required this.rol,
    required this.nombre,
    this.telefono,
    this.email,
    this.createdAt,
  });

  final String id;
  final UserRole rol;
  final String nombre;
  final String? telefono;
  final String? email;
  final DateTime? createdAt;

  bool get isAdmin => rol == UserRole.administrador;
  bool get isJugador => rol == UserRole.jugador;

  factory UsuarioPerfil.fromJson(Map<String, dynamic> json, {String? email}) {
    return UsuarioPerfil(
      id: json['id'] as String,
      rol: UserRole.fromString(json['rol'] as String?),
      nombre: (json['nombre'] as String?) ?? 'Usuario',
      telefono: json['telefono'] as String?,
      email: email,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rol': rol.value,
      'nombre': nombre,
      if (telefono != null) 'telefono': telefono,
    };
  }

  UsuarioPerfil copyWith({
    String? id,
    UserRole? rol,
    String? nombre,
    String? telefono,
    String? email,
    DateTime? createdAt,
  }) {
    return UsuarioPerfil(
      id: id ?? this.id,
      rol: rol ?? this.rol,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

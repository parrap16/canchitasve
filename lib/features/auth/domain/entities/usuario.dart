/// Entidad de dominio que representa a un usuario autenticado.
class Usuario {
  const Usuario({
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

  Usuario copyWith({
    String? id,
    String? email,
    String? nombre,
    String? avatarUrl,
    DateTime? creadoEn,
  }) {
    return Usuario(
      id: id ?? this.id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }
}

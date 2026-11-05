/// Superficie disponible en las canchas de CAIMANEROS.
enum SuperficieCancha {
  sintetica('sintetica', 'Grama Sintética'),
  tabloncillo('tabloncillo', 'Tabloncillo');

  const SuperficieCancha(this.value, this.label);
  final String value;
  final String label;

  static SuperficieCancha fromString(String? val) {
    if (val == 'tabloncillo') return SuperficieCancha.tabloncillo;
    return SuperficieCancha.sintetica;
  }
}

/// Entidad de dominio para una Cancha deportiva.
class Cancha {
  const Cancha({
    required this.id,
    required this.complejoId,
    required this.formato,
    required this.superficie,
    required this.techada,
    this.createdAt,
  });

  final String id;
  final String complejoId;
  final int formato; // 5, 7, 11
  final SuperficieCancha superficie;
  final bool techada;
  final DateTime? createdAt;

  String get formatoLabel => 'Fútbol $formato (F$formato)';

  factory Cancha.fromJson(Map<String, dynamic> json) {
    return Cancha(
      id: json['id'] as String,
      complejoId: json['complejo_id'] as String,
      formato: (json['formato'] as num?)?.toInt() ?? 5,
      superficie: SuperficieCancha.fromString(json['superficie'] as String?),
      techada: json['techada'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complejo_id': complejoId,
      'formato': formato,
      'superficie': superficie.value,
      'techada': techada,
    };
  }
}

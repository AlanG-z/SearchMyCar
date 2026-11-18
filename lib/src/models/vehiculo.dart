enum CategoriaVehiculo {
  bicicleta('Bicicleta'),
  moto('Moto'),
  auto('Auto');

  const CategoriaVehiculo(this.etiqueta);

  final String etiqueta;

  static CategoriaVehiculo desdeValor(Object? valor) {
    if (valor is! String) {
      return CategoriaVehiculo.auto;
    }

    return CategoriaVehiculo.values.firstWhere(
      (categoria) => categoria.name == valor,
      orElse: () => CategoriaVehiculo.auto,
    );
  }
}

class Vehiculo {
  const Vehiculo({
    required this.id,
    required this.categoria,
    required this.marca,
    required this.modelo,
    required this.patente,
    required this.color,
    this.anio,
    this.creadoEn,
  });

  final String id;
  final CategoriaVehiculo categoria;
  final String marca;
  final String modelo;
  final String patente;
  final String color;
  final int? anio;
  final DateTime? creadoEn;

  String get nombre => '$marca $modelo';

  factory Vehiculo.desdeJson(Map<String, dynamic> json) {
    return Vehiculo(
      id: json['id'].toString(),
      categoria: CategoriaVehiculo.desdeValor(json['categoria']),
      marca: json['marca'] as String? ?? '',
      modelo: json['modelo'] as String? ?? '',
      patente: json['patente'] as String? ?? '',
      color: json['color'] as String? ?? '',
      anio: (json['anio'] as num?)?.toInt(),
      creadoEn: DateTime.tryParse(json['creado_en']?.toString() ?? ''),
    );
  }
}

class VehiculoInput {
  const VehiculoInput({
    required this.categoria,
    required this.marca,
    required this.modelo,
    required this.patente,
    required this.color,
    this.anio,
  });

  final CategoriaVehiculo categoria;
  final String marca;
  final String modelo;
  final String patente;
  final String color;
  final int? anio;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'categoria': categoria.name,
      'marca': marca.trim(),
      'modelo': modelo.trim(),
      'patente': patente.trim().toUpperCase(),
      'color': color.trim(),
      'anio': anio,
    };
  }
}

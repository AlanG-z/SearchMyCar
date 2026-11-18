class UbicacionGuardada {
  const UbicacionGuardada({
    required this.id,
    required this.vehiculoId,
    required this.latitud,
    required this.longitud,
    this.precisionMetros,
    this.creadoEn,
  });

  final String id;
  final String vehiculoId;
  final double latitud;
  final double longitud;
  final double? precisionMetros;
  final DateTime? creadoEn;

  factory UbicacionGuardada.desdeJson(Map<String, dynamic> json) {
    return UbicacionGuardada(
      id: json['id'].toString(),
      vehiculoId: json['vehiculo_id'].toString(),
      latitud: (json['latitud'] as num?)?.toDouble() ?? 0,
      longitud: (json['longitud'] as num?)?.toDouble() ?? 0,
      precisionMetros: (json['precision_metros'] as num?)?.toDouble(),
      creadoEn: DateTime.tryParse(json['creado_en']?.toString() ?? ''),
    );
  }
}

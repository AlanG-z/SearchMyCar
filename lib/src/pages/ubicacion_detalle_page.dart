import 'package:dondeestacione/src/models/ubicacion.dart';
import 'package:dondeestacione/src/models/vehiculo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Muestra en el mapa una ubicación guardada en el historial.
class UbicacionDetallePage extends StatelessWidget {
  const UbicacionDetallePage({
    required this.ubicacion,
    this.vehiculo,
    this.tileProvider,
    super.key,
  });

  static const double _zoom = 16.5;

  final UbicacionGuardada ubicacion;
  final Vehiculo? vehiculo;
  final TileProvider? tileProvider;

  LatLng get _punto => LatLng(ubicacion.latitud, ubicacion.longitud);

  IconData _iconoCategoria(CategoriaVehiculo categoria) {
    return switch (categoria) {
      CategoriaVehiculo.bicicleta => Icons.pedal_bike,
      CategoriaVehiculo.moto => Icons.two_wheeler,
      CategoriaVehiculo.auto => Icons.directions_car,
    };
  }

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) {
      return 'Fecha desconocida';
    }

    final local = fecha.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');

    return '$dia/$mes/${local.year} · $hora:$minuto';
  }

  String _textoPrecision(double? precision) {
    if (precision == null || precision <= 0) {
      return 'Precisión no disponible';
    }

    return 'Precisión ±${precision.round()} m';
  }

  Widget _filaDato(IconData icono, String texto, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(color: Colors.blueGrey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirMapa() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: _punto,
        initialZoom: _zoom,
        minZoom: 2,
        maxZoom: 19,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.dondeestacione',
          tileProvider: tileProvider,
          maxNativeZoom: 19,
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _punto,
              width: 44,
              height: 44,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange.shade800,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.place, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
        const SimpleAttributionWidget(
          source: Text('OpenStreetMap contributors'),
        ),
      ],
    );
  }

  Widget _construirDetalle() {
    final categoria = vehiculo?.categoria ?? CategoriaVehiculo.auto;
    final colorCategoria = Colors.orange.shade800;
    final nombreVehiculo = vehiculo?.nombre ?? 'Vehículo no disponible';
    final detalleVehiculo = vehiculo == null
        ? 'La ubicación se guardó con un vehículo que ya no existe.'
        : '${vehiculo!.patente} · ${vehiculo!.color}';

    return Material(
      elevation: 8,
      color: Colors.white,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colorCategoria.withValues(alpha: 0.12),
                  child: Icon(
                    _iconoCategoria(categoria),
                    color: colorCategoria,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombreVehiculo,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        detalleVehiculo,
                        style: TextStyle(color: Colors.blueGrey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _filaDato(
              Icons.schedule,
              'Guardada el ${_formatearFecha(ubicacion.creadoEn)}',
              Colors.blueGrey.shade500,
            ),
            _filaDato(
              Icons.swap_vert,
              'Latitud ${ubicacion.latitud.toStringAsFixed(5)}',
              Colors.orange.shade800,
            ),
            _filaDato(
              Icons.swap_horiz,
              'Longitud ${ubicacion.longitud.toStringAsFixed(5)}',
              Colors.orange.shade800,
            ),
            _filaDato(
              Icons.gps_fixed,
              _textoPrecision(ubicacion.precisionMetros),
              Colors.blueGrey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación guardada'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(child: _construirMapa()),
          _construirDetalle(),
        ],
      ),
    );
  }
}

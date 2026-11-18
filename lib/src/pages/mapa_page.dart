import 'package:dondeestacione/src/models/vehiculo.dart';
import 'package:dondeestacione/src/pages/vehiculo_form_page.dart';
import 'package:dondeestacione/src/services/ubicacion_actual_service.dart';
import 'package:dondeestacione/src/services/ubicacion_service.dart';
import 'package:dondeestacione/src/services/vehiculo_service.dart';
import 'package:dondeestacione/src/widgets/main_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({
    required this.vehiculoService,
    required this.ubicacionService,
    required this.ubicacionActualService,
    this.tileProvider,
    super.key,
  });

  final VehiculoService vehiculoService;
  final UbicacionService ubicacionService;
  final UbicacionActualService ubicacionActualService;
  final TileProvider? tileProvider;

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  static const LatLng _centroInicial = LatLng(0, 0);
  static const double _zoomUbicacion = 16.5;

  final MapController _mapController = MapController();

  UbicacionActual? _ubicacion;
  UbicacionActualFailure? _falloUbicacion;
  List<Vehiculo> _vehiculos = const [];
  Vehiculo? _vehiculoSeleccionado;
  String? _errorVehiculos;
  bool _cargandoUbicacion = true;
  bool _cargandoVehiculos = true;
  bool _guardando = false;
  bool _mapaListo = false;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await Future.wait([_cargarVehiculos(), _obtenerUbicacion()]);
  }

  Future<void> _cargarVehiculos() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _cargandoVehiculos = true;
      _errorVehiculos = null;
    });

    try {
      final vehiculos = await widget.vehiculoService.listar();

      if (!mounted) {
        return;
      }

      final idSeleccionado = _vehiculoSeleccionado?.id;
      Vehiculo? seleccion = vehiculos.isEmpty ? null : vehiculos.first;

      if (idSeleccionado != null) {
        for (final vehiculo in vehiculos) {
          if (vehiculo.id == idSeleccionado) {
            seleccion = vehiculo;
            break;
          }
        }
      }

      setState(() {
        _vehiculos = vehiculos;
        _vehiculoSeleccionado = seleccion;
        _cargandoVehiculos = false;
        _errorVehiculos = null;
      });
    } on VehiculoFailure catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargandoVehiculos = false;
        _errorVehiculos = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargandoVehiculos = false;
        _errorVehiculos = 'No se pudieron cargar tus vehículos.';
      });
    }
  }

  Future<void> _obtenerUbicacion() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _cargandoUbicacion = true;
      _falloUbicacion = null;
    });

    try {
      final ubicacion = await widget.ubicacionActualService.obtener();

      if (!mounted) {
        return;
      }

      setState(() {
        _ubicacion = ubicacion;
        _cargandoUbicacion = false;
        _falloUbicacion = null;
      });

      _centrarEnUbicacion(ubicacion);
    } on UbicacionActualFailure catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargandoUbicacion = false;
        _falloUbicacion = error;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargandoUbicacion = false;
        _falloUbicacion = const UbicacionActualFailure(
          'No se pudo obtener tu ubicación. Inténtalo de nuevo.',
          UbicacionActualError.noDisponible,
        );
      });
    }
  }

  void _centrarEnUbicacion(UbicacionActual ubicacion) {
    if (!_mapaListo) {
      return;
    }

    _mapController.move(
      LatLng(ubicacion.latitud, ubicacion.longitud),
      _zoomUbicacion,
    );
  }

  Future<void> _abrirFormularioVehiculo() async {
    final guardado = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) =>
            VehiculoFormPage(vehiculoService: widget.vehiculoService),
      ),
    );

    if (guardado == true && mounted) {
      await _cargarVehiculos();
    }
  }

  Future<void> _abrirAjustes({required bool deUbicacion}) async {
    try {
      if (deUbicacion) {
        await widget.ubicacionActualService.abrirAjustesUbicacion();
      } else {
        await widget.ubicacionActualService.abrirAjustesAplicacion();
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudieron abrir los ajustes del dispositivo.'),
        ),
      );
    }
  }

  Future<void> _guardarUbicacion() async {
    final ubicacion = _ubicacion;
    final vehiculo = _vehiculoSeleccionado;

    if (_guardando || ubicacion == null || vehiculo == null) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      await widget.ubicacionService.guardar(
        vehiculoId: vehiculo.id,
        latitud: ubicacion.latitud,
        longitud: ubicacion.longitud,
        precisionMetros: ubicacion.precisionMetros,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ubicación guardada para ${vehiculo.nombre}.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on UbicacionFailure catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _guardando = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _guardando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la ubicación.')),
      );
    }
  }

  IconData _iconoCategoria(CategoriaVehiculo categoria) {
    return switch (categoria) {
      CategoriaVehiculo.bicicleta => Icons.pedal_bike,
      CategoriaVehiculo.moto => Icons.two_wheeler,
      CategoriaVehiculo.auto => Icons.directions_car,
    };
  }

  Widget _construirSelectorVehiculo() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
        child: _construirContenidoSelector(),
      ),
    );
  }

  Widget _construirContenidoSelector() {
    if (_cargandoVehiculos) {
      return const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Expanded(child: Text('Cargando vehículos...')),
        ],
      );
    }

    if (_errorVehiculos != null) {
      return Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorVehiculos!,
              style: TextStyle(color: Colors.red.shade900),
            ),
          ),
          TextButton(
            onPressed: _cargarVehiculos,
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    if (_vehiculos.isEmpty) {
      return Row(
        children: [
          Icon(Icons.garage_outlined, color: Colors.orange.shade800),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vehículo en uso',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text('No tienes vehículos registrados.'),
              ],
            ),
          ),
          TextButton(
            onPressed: _abrirFormularioVehiculo,
            child: const Text('Agregar'),
          ),
        ],
      );
    }

    return Row(
      children: [
        Icon(Icons.garage_outlined, color: Colors.orange.shade800),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vehículo en uso',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade600,
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<Vehiculo>(
                  key: const Key('mapa-vehiculo-selector'),
                  value: _vehiculoSeleccionado,
                  isExpanded: true,
                  isDense: true,
                  icon: const Icon(Icons.expand_more),
                  items: _vehiculos
                      .map((vehiculo) {
                        return DropdownMenuItem<Vehiculo>(
                          value: vehiculo,
                          child: Row(
                            children: [
                              Icon(
                                _iconoCategoria(vehiculo.categoria),
                                size: 18,
                                color: Colors.orange.shade800,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${vehiculo.nombre} · ${vehiculo.patente}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                      .toList(growable: false),
                  onChanged: _guardando
                      ? null
                      : (vehiculo) {
                          if (vehiculo == null) {
                            return;
                          }

                          setState(() {
                            _vehiculoSeleccionado = vehiculo;
                          });
                        },
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _abrirFormularioVehiculo,
          tooltip: 'Agregar vehículo',
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  Widget _construirAvisoUbicacion() {
    final fallo = _falloUbicacion;

    if (fallo == null) {
      return const SizedBox.shrink();
    }

    final mostrarAjustesApp =
        fallo.tipo == UbicacionActualError.permisoDenegadoPermanente;
    final mostrarAjustesUbicacion =
        fallo.tipo == UbicacionActualError.servicioDesactivado;

    return Card(
      color: Colors.red.shade50,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_off_outlined, color: Colors.red.shade700),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fallo.message,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: _cargandoUbicacion ? null : _obtenerUbicacion,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
                if (mostrarAjustesApp)
                  TextButton.icon(
                    onPressed: () => _abrirAjustes(deUbicacion: false),
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Abrir ajustes'),
                  ),
                if (mostrarAjustesUbicacion)
                  TextButton.icon(
                    onPressed: () => _abrirAjustes(deUbicacion: true),
                    icon: const Icon(Icons.gps_fixed),
                    label: const Text('Activar ubicación'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _textoUbicacion() {
    if (_cargandoUbicacion && _ubicacion == null) {
      return 'Obteniendo tu ubicación...';
    }

    final ubicacion = _ubicacion;

    if (ubicacion == null) {
      return 'Todavía no tenemos tu ubicación.';
    }

    final precision = ubicacion.precisionMetros <= 0
        ? 'sin precisión estimada'
        : 'precisión ±${ubicacion.precisionMetros.round()} m';

    return '${ubicacion.latitud.toStringAsFixed(5)}, '
        '${ubicacion.longitud.toStringAsFixed(5)} · $precision';
  }

  Widget _construirPanelGuardado() {
    final puedeGuardar =
        _ubicacion != null &&
        _vehiculoSeleccionado != null &&
        !_cargandoUbicacion &&
        !_guardando;

    return Material(
      elevation: 8,
      color: Colors.white,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.my_location, color: Colors.orange.shade800),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ubicación actual',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _textoUbicacion(),
                        key: const Key('mapa-texto-ubicacion'),
                        style: TextStyle(color: Colors.blueGrey.shade600),
                      ),
                    ],
                  ),
                ),
                if (_cargandoUbicacion)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              key: const Key('mapa-guardar-ubicacion'),
              onPressed: puedeGuardar ? _guardarUbicacion : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.orange.shade700,
                disabledBackgroundColor: Colors.orange.shade200,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _guardando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_guardando ? 'Guardando...' : 'Guardar ubicación'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirMapa() {
    final ubicacion = _ubicacion;
    final punto = ubicacion == null
        ? null
        : LatLng(ubicacion.latitud, ubicacion.longitud);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _centroInicial,
        initialZoom: 2,
        minZoom: 2,
        maxZoom: 19,
        onMapReady: () {
          _mapaListo = true;
          final actual = _ubicacion;

          if (actual != null) {
            _centrarEnUbicacion(actual);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.dondeestacione',
          tileProvider: widget.tileProvider,
          maxNativeZoom: 19,
        ),
        if (ubicacion != null) ...[
          CircleLayer(
            circles: [
              CircleMarker(
                point: punto!,
                radius: ubicacion.precisionMetros <= 0
                    ? 30
                    : ubicacion.precisionMetros,
                useRadiusInMeter: ubicacion.precisionMetros > 0,
                color: Colors.blue.withValues(alpha: 0.12),
                borderColor: Colors.blue.withValues(alpha: 0.4),
                borderStrokeWidth: 1,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: punto,
                width: 38,
                height: 38,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
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
                  child: const Icon(
                    Icons.navigation,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SimpleAttributionWidget(
          source: Text('OpenStreetMap contributors'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            key: const Key('mapa-actualizar-ubicacion'),
            onPressed: _cargandoUbicacion ? null : _obtenerUbicacion,
            tooltip: 'Actualizar ubicación',
            icon: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _construirMapa(),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _construirSelectorVehiculo(),
                      if (_falloUbicacion != null) ...[
                        const SizedBox(height: 8),
                        _construirAvisoUbicacion(),
                      ],
                    ],
                  ),
                ),
                if (_cargandoUbicacion)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(minHeight: 3),
                  ),
              ],
            ),
          ),
          _construirPanelGuardado(),
        ],
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 0),
    );
  }
}

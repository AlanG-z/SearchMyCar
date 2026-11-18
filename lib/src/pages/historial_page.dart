import 'package:dondeestacione/src/Routes/app_routes.dart';
import 'package:dondeestacione/src/models/ubicacion.dart';
import 'package:dondeestacione/src/models/vehiculo.dart';
import 'package:dondeestacione/src/pages/ubicacion_detalle_page.dart';
import 'package:dondeestacione/src/services/ubicacion_service.dart';
import 'package:dondeestacione/src/services/vehiculo_service.dart';
import 'package:dondeestacione/src/widgets/main_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({
    required this.ubicacionService,
    required this.vehiculoService,
    this.tileProvider,
    super.key,
  });

  final UbicacionService ubicacionService;
  final VehiculoService vehiculoService;
  final TileProvider? tileProvider;

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  List<UbicacionGuardada> _ubicaciones = const [];
  Map<String, Vehiculo> _vehiculosPorId = const {};
  final Set<String> _eliminando = <String>{};
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final ubicacionesFuture = widget.ubicacionService.listar();
      final vehiculosFuture = widget.vehiculoService.listar();

      final ubicaciones = await ubicacionesFuture;
      final vehiculos = await vehiculosFuture;

      if (!mounted) {
        return;
      }

      setState(() {
        _ubicaciones = ubicaciones;
        _vehiculosPorId = {
          for (final vehiculo in vehiculos) vehiculo.id: vehiculo,
        };
        _cargando = false;
        _error = null;
      });
    } on UbicacionFailure catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargando = false;
        _error = error.message;
      });
    } on VehiculoFailure catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargando = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargando = false;
        _error = 'No se pudo cargar el historial de ubicaciones.';
      });
    }
  }

  Future<void> _abrirDetalle(UbicacionGuardada ubicacion, Vehiculo? vehiculo) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => UbicacionDetallePage(
          ubicacion: ubicacion,
          vehiculo: vehiculo,
          tileProvider: widget.tileProvider,
        ),
      ),
    );
  }

  Future<void> _confirmarEliminacion(
    UbicacionGuardada ubicacion,
    Vehiculo? vehiculo,
  ) async {
    if (_eliminando.contains(ubicacion.id)) {
      return;
    }

    final nombre = vehiculo == null ? '' : ' de ${vehiculo.nombre}';

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar ubicación'),
          content: Text(
            'Se eliminará la ubicación$nombre guardada el '
            '${_formatearFecha(ubicacion.creadoEn)}.\n\n'
            'Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              key: const Key('historial-confirmar-eliminar'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmado != true || !mounted) {
      return;
    }

    setState(() {
      _eliminando.add(ubicacion.id);
    });

    try {
      await widget.ubicacionService.eliminar(ubicacion.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _ubicaciones = _ubicaciones
            .where((guardada) => guardada.id != ubicacion.id)
            .toList(growable: false);
        _eliminando.remove(ubicacion.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ubicación eliminada.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on UbicacionFailure catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _eliminando.remove(ubicacion.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _eliminando.remove(ubicacion.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo eliminar la ubicación.'),
          behavior: SnackBarBehavior.floating,
        ),
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

  Color _colorCategoria(CategoriaVehiculo categoria) {
    return switch (categoria) {
      CategoriaVehiculo.bicicleta => Colors.green.shade700,
      CategoriaVehiculo.moto => Colors.blue.shade700,
      CategoriaVehiculo.auto => Colors.orange.shade800,
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

  Widget _construirContenido() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 64,
                color: Colors.blueGrey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey.shade700),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _cargar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_ubicaciones.isEmpty) {
      return RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 80, 24, 100),
          children: [
            Icon(
              Icons.location_history_outlined,
              size: 80,
              color: Colors.orange.shade300,
            ),
            const SizedBox(height: 20),
            const Text(
              'Aún no hay ubicaciones guardadas',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Ve al mapa, elige tu vehículo y pulsa “Guardar ubicación”.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey.shade600),
            ),
            const SizedBox(height: 24),
            Center(
              child: FilledButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed(AppRoutes.mapa),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Ir al mapa'),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _ubicaciones.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final ubicacion = _ubicaciones[index];
          final vehiculo = _vehiculosPorId[ubicacion.vehiculoId];
          final categoria = vehiculo?.categoria ?? CategoriaVehiculo.auto;
          final color = _colorCategoria(categoria);
          final nombreVehiculo = vehiculo?.nombre ?? 'Vehículo';
          final detalleVehiculo = vehiculo == null
              ? 'Vehículo no disponible'
              : '${vehiculo.patente} · ${vehiculo.color}';

          return Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              key: Key('historial-ubicacion-${ubicacion.id}'),
              onTap: () => _abrirDetalle(ubicacion, vehiculo),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 6, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: color.withValues(alpha: 0.12),
                      child: Icon(_iconoCategoria(categoria), color: color),
                    ),
                    const SizedBox(width: 14),
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
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: Colors.blueGrey.shade500,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _formatearFecha(ubicacion.creadoEn),
                                  style: TextStyle(
                                    color: Colors.blueGrey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.my_location,
                                size: 16,
                                color: Colors.orange.shade800,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${ubicacion.latitud.toStringAsFixed(5)}, '
                                  '${ubicacion.longitud.toStringAsFixed(5)}\n'
                                  '${_textoPrecision(ubicacion.precisionMetros)}',
                                  style: TextStyle(
                                    color: Colors.blueGrey.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 14,
                                color: Colors.orange.shade800,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Toca para verlo en el mapa',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: Key('historial-eliminar-${ubicacion.id}'),
                      tooltip: 'Eliminar ubicación',
                      onPressed: _eliminando.contains(ubicacion.id)
                          ? null
                          : () => _confirmarEliminacion(ubicacion, vehiculo),
                      icon: _eliminando.contains(ubicacion.id)
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              Icons.delete_outline,
                              color: Colors.red.shade700,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de ubicaciones'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _cargando ? null : _cargar,
            tooltip: 'Actualizar historial',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _construirContenido(),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 2),
    );
  }
}

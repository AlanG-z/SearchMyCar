import 'package:dondeestacione/src/models/vehiculo.dart';
import 'package:dondeestacione/src/pages/vehiculo_form_page.dart';
import 'package:dondeestacione/src/services/vehiculo_service.dart';
import 'package:dondeestacione/src/widgets/main_bottom_navigation.dart';
import 'package:flutter/material.dart';

enum _AccionVehiculo { editar, eliminar }

class VehiculosPage extends StatefulWidget {
  const VehiculosPage({required this.vehiculoService, super.key});

  final VehiculoService vehiculoService;

  @override
  State<VehiculosPage> createState() => _VehiculosPageState();
}

class _VehiculosPageState extends State<VehiculosPage> {
  List<Vehiculo> _vehiculos = const [];
  bool _cargando = true;
  String? _error;
  String? _eliminandoId;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar({bool mostrarCarga = true}) async {
    if (mostrarCarga) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }

    try {
      final vehiculos = await widget.vehiculoService.listar();

      if (!mounted) {
        return;
      }

      setState(() {
        _vehiculos = vehiculos;
        _cargando = false;
        _error = null;
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
        _error = 'No se pudieron cargar tus vehículos.';
      });
    }
  }

  Future<void> _abrirFormulario([Vehiculo? vehiculo]) async {
    final guardado = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => VehiculoFormPage(
          vehiculoService: widget.vehiculoService,
          vehiculo: vehiculo,
        ),
      ),
    );

    if (guardado != true || !mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          vehiculo == null
              ? 'Vehículo agregado correctamente.'
              : 'Vehículo actualizado correctamente.',
        ),
      ),
    );

    await _cargar(mostrarCarga: false);
  }

  Future<void> _eliminar(Vehiculo vehiculo) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar vehículo'),
          content: Text(
            '¿Querés eliminar ${vehiculo.nombre}? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
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
      _eliminandoId = vehiculo.id;
    });

    try {
      await widget.vehiculoService.eliminar(vehiculo.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _vehiculos = _vehiculos
            .where((item) => item.id != vehiculo.id)
            .toList(growable: false);
        _eliminandoId = null;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Vehículo eliminado.')));
    } on VehiculoFailure catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _eliminandoId = null;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _eliminandoId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar el vehículo.')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis vehículos'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _cargando ? null : _cargar,
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _construirContenido(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 1),
    );
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

    if (_vehiculos.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _cargar(mostrarCarga: false),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 80, 24, 120),
          children: [
            Icon(
              Icons.garage_outlined,
              size: 80,
              color: Colors.orange.shade300,
            ),
            const SizedBox(height: 20),
            const Text(
              'Aún no tienes vehículos',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega tu bicicleta, moto o auto para empezar a administrarlo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey.shade600),
            ),
            const SizedBox(height: 24),
            Center(
              child: FilledButton.icon(
                onPressed: () => _abrirFormulario(),
                icon: const Icon(Icons.add),
                label: const Text('Agregar vehículo'),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _cargar(mostrarCarga: false),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _vehiculos.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final vehiculo = _vehiculos[index];
          final eliminando = _eliminandoId == vehiculo.id;

          return Card(
            clipBehavior: Clip.antiAlias,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: eliminando ? null : () => _abrirFormulario(vehiculo),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: _colorCategoria(vehiculo.categoria)
                          .withValues(alpha: 0.12),
                      child: Icon(
                        _iconoCategoria(vehiculo.categoria),
                        color: _colorCategoria(vehiculo.categoria),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _colorCategoria(vehiculo.categoria)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              vehiculo.categoria.etiqueta,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _colorCategoria(vehiculo.categoria),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            vehiculo.nombre,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            [
                              vehiculo.patente,
                              vehiculo.color,
                              if (vehiculo.anio != null) '${vehiculo.anio}',
                            ].join(' · '),
                            style: TextStyle(color: Colors.blueGrey.shade600),
                          ),
                        ],
                      ),
                    ),
                    if (eliminando)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      PopupMenuButton<_AccionVehiculo>(
                        tooltip: 'Opciones del vehículo',
                        onSelected: (accion) {
                          switch (accion) {
                            case _AccionVehiculo.editar:
                              _abrirFormulario(vehiculo);
                            case _AccionVehiculo.eliminar:
                              _eliminar(vehiculo);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem<_AccionVehiculo>(
                            value: _AccionVehiculo.editar,
                            child: ListTile(
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Editar'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem<_AccionVehiculo>(
                            value: _AccionVehiculo.eliminar,
                            child: ListTile(
                              leading: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              title: Text('Eliminar'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
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
}

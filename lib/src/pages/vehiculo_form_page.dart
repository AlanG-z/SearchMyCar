import 'package:dondeestacione/src/models/vehiculo.dart';
import 'package:dondeestacione/src/services/vehiculo_service.dart';
import 'package:flutter/material.dart';

class VehiculoFormPage extends StatefulWidget {
  const VehiculoFormPage({
    required this.vehiculoService,
    this.vehiculo,
    super.key,
  });

  final VehiculoService vehiculoService;
  final Vehiculo? vehiculo;

  bool get estaEditando => vehiculo != null;

  @override
  State<VehiculoFormPage> createState() => _VehiculoFormPageState();
}

class _VehiculoFormPageState extends State<VehiculoFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _marcaController;
  late final TextEditingController _modeloController;
  late final TextEditingController _patenteController;
  late final TextEditingController _colorController;
  late final TextEditingController _anioController;

  late CategoriaVehiculo _categoria;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final vehiculo = widget.vehiculo;

    _categoria = vehiculo?.categoria ?? CategoriaVehiculo.auto;
    _marcaController = TextEditingController(text: vehiculo?.marca ?? '');
    _modeloController = TextEditingController(text: vehiculo?.modelo ?? '');
    _patenteController = TextEditingController(text: vehiculo?.patente ?? '');
    _colorController = TextEditingController(text: vehiculo?.color ?? '');
    _anioController = TextEditingController(
      text: vehiculo?.anio?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _patenteController.dispose();
    _colorController.dispose();
    _anioController.dispose();
    super.dispose();
  }

  String? _validarRequerido(String? value, String mensaje) {
    if (value == null || value.trim().isEmpty) {
      return mensaje;
    }

    return null;
  }

  String? _validarAnio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final anio = int.tryParse(value.trim());
    final anioMaximo = DateTime.now().year + 1;

    if (anio == null || anio < 1900 || anio > anioMaximo) {
      return 'Ingresa un año entre 1900 y $anioMaximo';
    }

    return null;
  }

  Future<void> _guardar() async {
    if (_isLoading) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final anioTexto = _anioController.text.trim();
    final datos = VehiculoInput(
      categoria: _categoria,
      marca: _marcaController.text,
      modelo: _modeloController.text,
      patente: _patenteController.text,
      color: _colorController.text,
      anio: anioTexto.isEmpty ? null : int.parse(anioTexto),
    );

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final vehiculo = widget.vehiculo;

      if (vehiculo == null) {
        await widget.vehiculoService.crear(datos);
      } else {
        await widget.vehiculoService.actualizar(vehiculo.id, datos);
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on VehiculoFailure catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Ocurrió un error inesperado. Inténtalo de nuevo más tarde.';
      });
    }
  }

  InputDecoration _campoDecoration({
    required IconData icon,
    required String label,
    String? hint,
    String? helper,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.blueGrey.shade100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.orange, width: 1.5),
      ),
    );
  }

  IconData _iconoCategoria(CategoriaVehiculo categoria) {
    return switch (categoria) {
      CategoriaVehiculo.bicicleta => Icons.pedal_bike,
      CategoriaVehiculo.moto => Icons.two_wheeler,
      CategoriaVehiculo.auto => Icons.directions_car,
    };
  }

  @override
  Widget build(BuildContext context) {
    final esBicicleta = _categoria == CategoriaVehiculo.bicicleta;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.estaEditando ? 'Editar vehículo' : 'Nuevo vehículo'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Datos del vehículo',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Elige la categoría y completa la información.',
                      style: TextStyle(color: Colors.blueGrey.shade600),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<CategoriaVehiculo>(
                      key: const Key('vehicle-category-field'),
                      initialValue: _categoria,
                      isExpanded: true,
                      decoration: _campoDecoration(
                        icon: Icons.category_outlined,
                        label: 'Categoría',
                      ),
                      items: CategoriaVehiculo.values
                          .map((categoria) {
                            return DropdownMenuItem<CategoriaVehiculo>(
                              value: categoria,
                              child: Row(
                                children: [
                                  Icon(
                                    _iconoCategoria(categoria),
                                    color: Colors.orange.shade700,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(categoria.etiqueta),
                                ],
                              ),
                            );
                          })
                          .toList(growable: false),
                      onChanged: _isLoading
                          ? null
                          : (categoria) {
                              if (categoria == null) {
                                return;
                              }

                              setState(() {
                                _categoria = categoria;
                              });
                            },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      key: const Key('vehicle-brand-field'),
                      controller: _marcaController,
                      enabled: !_isLoading,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: _campoDecoration(
                        icon: Icons.factory_outlined,
                        label: 'Marca',
                        hint: esBicicleta ? 'Ej. Venzo' : 'Ej. Toyota',
                      ),
                      validator: (value) =>
                          _validarRequerido(value, 'Ingresa la marca'),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      key: const Key('vehicle-model-field'),
                      controller: _modeloController,
                      enabled: !_isLoading,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: _campoDecoration(
                        icon: Icons.directions_car_outlined,
                        label: 'Modelo',
                        hint: esBicicleta ? 'Ej. Mountain Bike' : 'Ej. Corolla',
                      ),
                      validator: (value) =>
                          _validarRequerido(value, 'Ingresa el modelo'),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      key: const Key('vehicle-plate-field'),
                      controller: _patenteController,
                      enabled: !_isLoading,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: _campoDecoration(
                        icon: Icons.pin_outlined,
                        label: esBicicleta
                            ? 'Patente o número de serie'
                            : 'Patente',
                        hint: esBicicleta ? 'Ej. BIC-001' : 'Ej. ABC-123',
                        helper: 'Se guarda en mayúsculas.',
                      ),
                      validator: (value) => _validarRequerido(
                        value,
                        esBicicleta
                            ? 'Ingresa la patente o número de serie'
                            : 'Ingresa la patente',
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      key: const Key('vehicle-color-field'),
                      controller: _colorController,
                      enabled: !_isLoading,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: _campoDecoration(
                        icon: Icons.palette_outlined,
                        label: 'Color',
                        hint: 'Ej. Blanco',
                      ),
                      validator: (value) =>
                          _validarRequerido(value, 'Ingresa el color'),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      key: const Key('vehicle-year-field'),
                      controller: _anioController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: _isLoading ? null : (_) => _guardar(),
                      decoration: _campoDecoration(
                        icon: Icons.calendar_today_outlined,
                        label: 'Año (opcional)',
                        hint: 'Ej. 2024',
                      ),
                      validator: _validarAnio,
                    ),
                    const SizedBox(height: 24),
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade900),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    FilledButton(
                      onPressed: _isLoading ? null : _guardar,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: Colors.orange.shade700,
                        disabledBackgroundColor: Colors.orange.shade300,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.estaEditando
                                  ? 'Guardar cambios'
                                  : 'Guardar vehículo',
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

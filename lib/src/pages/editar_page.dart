import 'package:dondeestacione/src/widgets/main_bottom_navigation.dart';
import 'package:flutter/material.dart';

class EditarPage extends StatelessWidget {
  const EditarPage({super.key});

  InputDecoration _campoDecoration({
    required IconData icon,
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
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

  @override
  Widget build(BuildContext context) {
    String modelo = '';
    String patente = '';
    String color = '';
    String marca = '';

    String tipoVehiculo = '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardar datos del vehículo'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ingrese los datos de su vehículo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Divider(
                    height: 32,
                    thickness: 1.5,
                    color: Colors.grey.shade300,
                  ),
                  TextFormField(
                    key: const Key('vehicle-model-field'),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: _campoDecoration(
                      icon: Icons.directions_car_outlined,
                      label: 'Modelo',
                      hint: 'Ej. Corolla',
                    ),
                    onChanged: (value) {
                      modelo = value;
                    },
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    key: const Key('vehicle-plate-field'),
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    decoration: _campoDecoration(
                      icon: Icons.pin_outlined,
                      label: 'Patente',
                      hint: 'Ej. ABC-123',
                    ),
                    onChanged: (value) {
                      patente = value.toUpperCase();
                    },
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    key: const Key('vehicle-color-field'),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: _campoDecoration(
                      icon: Icons.palette_outlined,
                      label: 'Color',
                      hint: 'Ej. Blanco',
                    ),
                    onChanged: (value) {
                      color = value;
                    },
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    key: const Key('vehicle-brand-field'),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: _campoDecoration(
                      icon: Icons.factory_outlined,
                      label: 'Marca',
                      hint: 'Ej. Toyota',
                    ),
                    onChanged: (value) {
                      marca = value;
                    },
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    key: const Key('vehicle-year-field'),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: _campoDecoration(
                      icon: Icons.calendar_today_outlined,
                      label: 'Año',
                      hint: 'Ej. 2024',
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    key: const Key('vehicle-type-field'),
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    decoration: _campoDecoration(
                      icon: Icons.category_outlined,
                      label: 'Tipo de vehículo',
                      hint: 'Ej. Sedán, SUV o camioneta',
                    ),
                    onChanged: (value) {
                      tipoVehiculo = value;
                    },
                  ),
                  Divider(
                    height: 32,
                    thickness: 1.5,
                    color: Colors.grey.shade300,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (modelo.isEmpty ||
                          patente.isEmpty ||
                          color.isEmpty ||
                          marca.isEmpty ||
                          tipoVehiculo.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Por favor, complete todos los campos.',
                            ),
                          ),
                        );
                      } else {
                        // Aquí puedes guardar los datos del vehículo
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Datos del vehículo guardados correctamente.',
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Guardar cambios',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 1),
    );
  }
}

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar vehículo'),
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
                  TextFormField(
                    key: const Key('vehicle-model-field'),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: _campoDecoration(
                      icon: Icons.directions_car_outlined,
                      label: 'Modelo',
                      hint: 'Ej. Corolla',
                    ),
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

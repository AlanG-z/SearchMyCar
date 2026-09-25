import 'package:dondeestacione/src/widgets/main_bottom_navigation.dart';
import 'package:flutter/material.dart';

class HistorialPage extends StatelessWidget {
  const HistorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registros'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.assignment_outlined, size: 80, color: Colors.orange),
              SizedBox(height: 20),
              Text(
                'Historial de ubicaciones',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Las ubicaciones que guardes aparecerán en esta página.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 2),
    );
  }
}

import 'package:dondeestacione/src/widgets/main_bottom_navigation.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueGrey.shade100,
                border: Border.all(color: Colors.blueGrey.shade400, width: 4),
              ),
              child: const Center(
                child: Icon(Icons.location_on, size: 80, color: Colors.red),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 260,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.directions_car),
                label: const Text('Guardar ubicación'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 0),
    );
  }
}

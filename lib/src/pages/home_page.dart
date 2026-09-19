
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                border: Border.all(
                  color: Colors.blueGrey.shade400,
                  width: 4, 
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.location_on,
                  size: 80,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 260,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.directions_car),
                label: const Text('Guardar ubicacion'),
              ),
            ),
            const SizedBox(height: 12),
              // /SizedBox(
              // /  width: 260,
              // /  child: OutlinedButton.icon(
              // /    onPressed: () {},
              // /    icon: const Icon(Icons.search),
              // /    label: const Text('Ver ubicaciones'),
              // /  ),
              // /),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() => _selectedIndex = index);
            },
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.orange.shade700,
            unselectedItemColor: Colors.blueGrey.shade400,
            elevation: 2,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map),
                label: 'Mapa',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.edit_outlined),
                activeIcon: Icon(Icons.edit),
                label: 'Editar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment_outlined),
                activeIcon: Icon(Icons.assignment),
                label: 'Registros',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Ajustes',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
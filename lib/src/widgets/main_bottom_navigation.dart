import 'package:dondeestacione/src/Routes/app_routes.dart';
import 'package:flutter/material.dart';

class MainBottomNavigation extends StatelessWidget {
  const MainBottomNavigation({required this.currentIndex, super.key});

  final int currentIndex;

  void _onDestinationSelected(BuildContext context, int index) {
    if (index == currentIndex) {
      return;
    }

    Navigator.of(context)
        .pushReplacementNamed(AppRoutes.bottomNavigationRoutes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onDestinationSelected(context, index),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.orange.shade700,
          unselectedItemColor: Colors.blueGrey.shade400,
          elevation: 2,
          items: const [
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
    );
  }
}

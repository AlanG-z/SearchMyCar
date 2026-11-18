import 'package:dondeestacione/src/Routes/app_routes.dart';
import 'package:dondeestacione/src/services/auth_service.dart';
import 'package:dondeestacione/src/widgets/main_bottom_navigation.dart';
import 'package:flutter/material.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({required this.authService, super.key});

  final AuthService authService;

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  bool _cerrandoSesion = false;

  Future<void> _cerrarSesion() async {
    if (_cerrandoSesion) {
      return;
    }

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text(
            '¿Querés cerrar sesión? Tus vehículos seguirán guardados en tu cuenta.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );

    if (confirmado != true || !mounted) {
      return;
    }

    setState(() {
      _cerrandoSesion = true;
    });

    try {
      await widget.authService.cerrarSesion();

      if (!mounted) {
        return;
      }

      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.inicio, (route) => false);
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cerrandoSesion = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cerrandoSesion = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cerrar la sesión.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final correo = widget.authService.correoActual;
    final correoMostrado = correo == null || correo.trim().isEmpty
        ? 'Sesión activa'
        : correo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.orange.shade100,
                    child: Icon(
                      Icons.person_outline,
                      color: Colors.orange.shade800,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cuenta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          correoMostrado,
                          key: const Key('current-user-email'),
                          style: TextStyle(color: Colors.blueGrey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: ListTile(
              leading: Icon(Icons.logout_outlined, color: Colors.red.shade700),
              title: Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red.shade700),
              ),
              subtitle: const Text('Cambia de cuenta o vuelve al inicio.'),
              trailing: _cerrandoSesion
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _cerrandoSesion ? null : _cerrarSesion,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Cada cuenta administra únicamente sus propios vehículos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blueGrey.shade500),
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 3),
    );
  }
}

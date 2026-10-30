import 'package:dondeestacione/src/app.dart';
import 'package:dondeestacione/src/config/supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!SupabaseConfig.estaConfigurado) {
    runApp(
      const _AvisoConfiguracion(
        mensaje: 'Abre lib/src/config/supabase_config.dart y coloca la URL y la clave pública de tu proyecto.',
      ),
    );
    return;
  }

  if (SupabaseConfig.usaClaveSecreta) {
    runApp(
      const _AvisoConfiguracion(
        mensaje: 'La clave configurada es privada. Usa la clave pública (publishable o anon), nunca la clave secreta.',
      ),
    );
    return;
  }

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url.trim(),
      publishableKey: SupabaseConfig.publishableKey.trim(),
    );
  } catch (_) {
    runApp(
      const _AvisoConfiguracion(
        mensaje: 'No se pudo inicializar Supabase. Revisa que la URL y la clave pública sean correctas.',
      ),
    );
    return;
  }

  final haySesionActiva = Supabase.instance.client.auth.currentSession != null;

  runApp(MyApp(isAuthenticated: haySesionActiva));
}

class _AvisoConfiguracion extends StatelessWidget {
  const _AvisoConfiguracion({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off_outlined,
                      size: 72,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Configura Supabase para continuar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      mensaje,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
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

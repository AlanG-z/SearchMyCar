/// Configuración pública de Supabase.
///
/// Escribe la URL y la clave pública en `_urlPorDefecto` y
/// `_clavePorDefecto`. También puedes pasarlas al ejecutar la app:
///
/// flutter run \
///   --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=tu_clave_publica
///
/// Nunca uses la clave `service_role` o `secret` dentro de una app Flutter.
abstract final class SupabaseConfig {
  static const String _urlPorDefecto =
      'https://pslfpwszwnctquhfrqln.supabase.co';
  static const String _clavePorDefecto =
      'sb_publishable_BqiCiMZ3zYtaWoEyZ4RvqA_juFpMmHj';

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: _urlPorDefecto,
  );

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: _clavePorDefecto,
  );

  static bool get estaConfigurado {
    final urlLimpia = url.trim();
    final claveLimpia = publishableKey.trim();
    final uri = Uri.tryParse(urlLimpia);

    return uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty &&
        claveLimpia.isNotEmpty &&
        !urlLimpia.startsWith('COLOCA_AQUI') &&
        !claveLimpia.startsWith('COLOCA_AQUI');
  }

  static bool get usaClaveSecreta =>
      publishableKey.trim().startsWith('sb_secret_') ||
      publishableKey.contains('service_role');
}

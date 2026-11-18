import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración pública de Supabase.
///
/// Los valores se leen en este orden:
///
/// 1. `--dart-define=SUPABASE_URL=...` y `--dart-define=SUPABASE_ANON_KEY=...`
///    (útil para CI o si prefieres no usar el archivo `.env`).
/// 2. El archivo `.env` en la raíz del proyecto:
///
/// ```
/// SUPABASE_URL=https://tu-proyecto.supabase.co
/// SUPABASE_ANON_KEY=tu_clave_publica
/// ```
///
/// También se aceptan los nombres `Url` y `Key`. Copia `.env.example` a `.env`
/// para empezar.
///
/// Nunca uses la clave `service_role` o `secret` dentro de una app Flutter.
abstract final class SupabaseConfig {
  static const String archivoEnv = '.env';

  static const List<String> _clavesUrl = ['SUPABASE_URL', 'Url'];
  static const List<String> _clavesClave = [
    'SUPABASE_ANON_KEY',
    'SUPABASE_KEY',
    'Key',
  ];

  static const String _urlDartDefine = String.fromEnvironment('SUPABASE_URL');
  static const String _claveDartDefine = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// Carga el archivo `.env`. Si no existe, la app continúa con los valores de
  /// `--dart-define` y mostrará el aviso de configuración si tampoco hay.
  static Future<void> cargar() async {
    if (dotenv.isInitialized) return;

    try {
      await dotenv.load(fileName: archivoEnv);
    } catch (_) {
      // Sin `.env` todavía se puede configurar con --dart-define.
    }
  }

  static String get url => _leer(_urlDartDefine, _clavesUrl);

  static String get publishableKey => _leer(_claveDartDefine, _clavesClave);

  static String _leer(String dartDefine, List<String> claves) {
    final desdeDartDefine = dartDefine.trim();
    if (desdeDartDefine.isNotEmpty) return desdeDartDefine;
    if (!dotenv.isInitialized) return '';

    for (final clave in claves) {
      final valor = dotenv.env[clave]
          ?.trim()
          .replaceAll('"', '')
          .replaceAll("'", '');
      if (valor != null && valor.isNotEmpty) return valor;
    }

    return '';
  }

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

import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthService {
  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  });
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class SupabaseAuthService implements AuthService {
  const SupabaseAuthService();

  @override
  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final respuesta = await Supabase.instance.client.auth.signInWithPassword(
        email: correo.trim(),
        password: contrasena,
      );

      if (respuesta.session == null) {
        throw const AuthFailure(
          'No se pudo iniciar sesión. Verifica tus datos e inténtalo de nuevo.',
        );
      }
    } on AuthFailure {
      rethrow;
    } on AuthException catch (error) {
      throw AuthFailure(_mensajeDeError(error));
    } catch (_) {
      throw const AuthFailure(
        'No se pudo conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.',
      );
    }
  }

  String _mensajeDeError(AuthException error) {
    if (error.statusCode == null) {
      return 'No se pudo conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.';
    }

    return switch (error.code) {
      'invalid_credentials' => 'Correo o contraseña incorrectos.',
      'email_not_confirmed' =>
        'Tu correo todavía no está confirmado. Revisa tu bandeja de entrada.',
      'too_many_requests' || 'over_request_rate_limit' =>
        'Demasiados intentos. Espera un momento antes de volver a probar.',
      'user_not_found' => 'No existe una cuenta con ese correo.',
      _ =>
        'No se pudo iniciar sesión. Verifica tus datos e inténtalo de nuevo.',
    };
  }
}

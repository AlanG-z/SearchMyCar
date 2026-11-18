import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthService {
  String? get correoActual;

  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  });

  Future<RegistroResultado> registrar({
    required String correo,
    required String contrasena,
  });

  Future<void> cerrarSesion();
}

class RegistroResultado {
  const RegistroResultado({required this.requiereConfirmacion});

  final bool requiereConfirmacion;
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
  String? get correoActual => Supabase.instance.client.auth.currentUser?.email;

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

  @override
  Future<RegistroResultado> registrar({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final respuesta = await Supabase.instance.client.auth.signUp(
        email: correo.trim(),
        password: contrasena,
      );

      if (respuesta.user == null) {
        throw const AuthFailure(
          'No se pudo crear la cuenta. Inténtalo de nuevo.',
        );
      }

      return RegistroResultado(requiereConfirmacion: respuesta.session == null);
    } on AuthFailure {
      rethrow;
    } on AuthException catch (error) {
      throw AuthFailure(_mensajeDeRegistro(error));
    } catch (_) {
      throw const AuthFailure(
        'No se pudo conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.',
      );
    }
  }

  @override
  Future<void> cerrarSesion() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } on AuthException catch (error) {
      throw AuthFailure(_mensajeDeError(error));
    } catch (_) {
      throw const AuthFailure(
        'No se pudo cerrar la sesión. Inténtalo de nuevo.',
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

  String _mensajeDeRegistro(AuthException error) {
    if (error.statusCode == null) {
      return 'No se pudo conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.';
    }

    return switch (error.code) {
      'user_already_exists' ||
      'email_exists' => 'Ya existe una cuenta con ese correo. Inicia sesión.',
      'weak_password' =>
        'La contraseña es demasiado débil. Usa al menos 8 caracteres.',
      'signup_disabled' =>
        'El registro está deshabilitado temporalmente. Inténtalo más tarde.',
      'email_address_invalid' => 'Ingresa un correo electrónico válido.',
      'too_many_requests' ||
      'over_request_rate_limit' ||
      'over_email_send_rate_limit' =>
        'Demasiados intentos. Espera unos minutos antes de volver a probar.',
      _ => 'No se pudo crear la cuenta. Inténtalo de nuevo.',
    };
  }
}

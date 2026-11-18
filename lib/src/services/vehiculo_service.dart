import 'package:dondeestacione/src/models/vehiculo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class VehiculoService {
  Future<List<Vehiculo>> listar();

  Future<Vehiculo> crear(VehiculoInput datos);

  Future<Vehiculo> actualizar(String id, VehiculoInput datos);

  Future<void> eliminar(String id);
}

class VehiculoFailure implements Exception {
  const VehiculoFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class SupabaseVehiculoService implements VehiculoService {
  const SupabaseVehiculoService();

  static const String _tabla = 'vehiculos';

  SupabaseClient get _cliente => Supabase.instance.client;

  User _usuarioActual() {
    final usuario = _cliente.auth.currentUser;

    if (usuario == null) {
      throw const VehiculoFailure(
        'Tu sesión venció. Vuelve a iniciar sesión para continuar.',
      );
    }

    return usuario;
  }

  @override
  Future<List<Vehiculo>> listar() {
    return _conManejoDeErrores(() async {
      final usuario = _usuarioActual();
      final filas = await _cliente
          .from(_tabla)
          .select()
          .eq('user_id', usuario.id)
          .order('creado_en', ascending: false);

      return filas
          .map((fila) => Vehiculo.desdeJson(fila))
          .toList(growable: false);
    });
  }

  @override
  Future<Vehiculo> crear(VehiculoInput datos) {
    return _conManejoDeErrores(() async {
      final usuario = _usuarioActual();
      final fila = await _cliente
          .from(_tabla)
          .insert(<String, Object?>{...datos.toMap(), 'user_id': usuario.id})
          .select()
          .single();

      return Vehiculo.desdeJson(fila);
    });
  }

  @override
  Future<Vehiculo> actualizar(String id, VehiculoInput datos) {
    return _conManejoDeErrores(() async {
      final usuario = _usuarioActual();
      final fila = await _cliente
          .from(_tabla)
          .update(datos.toMap())
          .eq('id', id)
          .eq('user_id', usuario.id)
          .select()
          .maybeSingle();

      if (fila == null) {
        throw const VehiculoFailure(
          'No se encontró el vehículo o no tienes permiso para editarlo.',
        );
      }

      return Vehiculo.desdeJson(fila);
    });
  }

  @override
  Future<void> eliminar(String id) {
    return _conManejoDeErrores(() async {
      final usuario = _usuarioActual();
      final eliminados = await _cliente
          .from(_tabla)
          .delete()
          .eq('id', id)
          .eq('user_id', usuario.id)
          .select('id');

      if (eliminados.isEmpty) {
        throw const VehiculoFailure(
          'No se encontró el vehículo o no tienes permiso para eliminarlo.',
        );
      }
    });
  }

  Future<T> _conManejoDeErrores<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on VehiculoFailure {
      rethrow;
    } on PostgrestException catch (error) {
      throw VehiculoFailure(_mensajeDeError(error));
    } catch (_) {
      throw const VehiculoFailure(
        'No se pudo conectar con Supabase. Revisa tu conexión e inténtalo de nuevo.',
      );
    }
  }

  String _mensajeDeError(PostgrestException error) {
    return switch (error.code) {
      '23505' => 'Ya tienes un vehículo guardado con esa patente.',
      '23514' => 'La categoría seleccionada no es válida.',
      '42501' => 'No tienes permiso para realizar esta acción.',
      '42P01' || 'PGRST204' =>
        'Falta actualizar la base de datos. Ejecuta la migración de Supabase.',
      'PGRST116' => 'El vehículo ya no existe.',
      _ => 'No se pudo completar la operación. Inténtalo de nuevo.',
    };
  }
}

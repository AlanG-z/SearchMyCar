import 'package:dondeestacione/src/models/ubicacion.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class UbicacionService {
  Future<void> guardar({
    required String vehiculoId,
    required double latitud,
    required double longitud,
    double? precisionMetros,
  });

  Future<List<UbicacionGuardada>> listar();

  Future<void> eliminar(String id);
}

class UbicacionFailure implements Exception {
  const UbicacionFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class SupabaseUbicacionService implements UbicacionService {
  const SupabaseUbicacionService();

  static const String _tabla = 'ubicaciones';

  SupabaseClient get _cliente => Supabase.instance.client;

  User _usuarioActual() {
    final usuario = _cliente.auth.currentUser;

    if (usuario == null) {
      throw const UbicacionFailure(
        'Tu sesión venció. Vuelve a iniciar sesión para continuar.',
      );
    }

    return usuario;
  }

  @override
  Future<void> guardar({
    required String vehiculoId,
    required double latitud,
    required double longitud,
    double? precisionMetros,
  }) async {
    try {
      final usuario = _usuarioActual();

      await _cliente.from(_tabla).insert(<String, Object?>{
        'user_id': usuario.id,
        'vehiculo_id': vehiculoId,
        'latitud': latitud,
        'longitud': longitud,
        'precision_metros': precisionMetros,
      });
    } on UbicacionFailure {
      rethrow;
    } on PostgrestException catch (error) {
      throw UbicacionFailure(_mensajeDeError(error));
    } catch (_) {
      throw const UbicacionFailure(
        'No se pudo guardar la ubicación. Revisa tu conexión e inténtalo de nuevo.',
      );
    }
  }

  @override
  Future<List<UbicacionGuardada>> listar() async {
    try {
      final usuario = _usuarioActual();
      final filas = await _cliente
          .from(_tabla)
          .select()
          .eq('user_id', usuario.id)
          .order('creado_en', ascending: false);

      return filas
          .map((fila) => UbicacionGuardada.desdeJson(fila))
          .toList(growable: false);
    } on UbicacionFailure {
      rethrow;
    } on PostgrestException catch (error) {
      throw UbicacionFailure(_mensajeDeListado(error));
    } catch (_) {
      throw const UbicacionFailure(
        'No se pudieron cargar las ubicaciones. Revisa tu conexión e inténtalo de nuevo.',
      );
    }
  }

  @override
  Future<void> eliminar(String id) async {
    try {
      final usuario = _usuarioActual();

      await _cliente
          .from(_tabla)
          .delete()
          .eq('id', id)
          .eq('user_id', usuario.id);
    } on UbicacionFailure {
      rethrow;
    } on PostgrestException catch (error) {
      throw UbicacionFailure(_mensajeDeEliminacion(error));
    } catch (_) {
      throw const UbicacionFailure(
        'No se pudo eliminar la ubicación. Revisa tu conexión e inténtalo de nuevo.',
      );
    }
  }

  String _mensajeDeError(PostgrestException error) {
    return switch (error.code) {
      '23503' => 'El vehículo seleccionado ya no existe. Actualiza la lista e inténtalo de nuevo.',
      '23514' => 'La ubicación recibida no es válida.',
      '42501' => 'No tienes permiso para guardar esta ubicación.',
      '42P01' || 'PGRST204' || 'PGRST205' => 'Falta actualizar la base de datos. Ejecuta la migración de ubicaciones.',
      _ => 'No se pudo guardar la ubicación. Inténtalo de nuevo.',
    };
  }

  String _mensajeDeEliminacion(PostgrestException error) {
    return switch (error.code) {
      '42501' => 'No tienes permiso para eliminar esta ubicación.',
      '42P01' || 'PGRST204' || 'PGRST205' => 'Falta actualizar la base de datos. Ejecuta la migración de ubicaciones.',
      _ => 'No se pudo eliminar la ubicación. Inténtalo de nuevo.',
    };
  }

  String _mensajeDeListado(PostgrestException error) {
    return switch (error.code) {
      '42501' => 'No tienes permiso para ver las ubicaciones guardadas.',
      '42P01' || 'PGRST204' || 'PGRST205' => 'Falta actualizar la base de datos. Ejecuta la migración de ubicaciones.',
      _ => 'No se pudieron cargar las ubicaciones. Inténtalo de nuevo.',
    };
  }
}

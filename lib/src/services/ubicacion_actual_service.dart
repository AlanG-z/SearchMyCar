import 'dart:async';

import 'package:geolocator/geolocator.dart';

enum UbicacionActualError {
  servicioDesactivado,
  permisoDenegado,
  permisoDenegadoPermanente,
  tiempoAgotado,
  noDisponible,
}

class UbicacionActual {
  const UbicacionActual({
    required this.latitud,
    required this.longitud,
    required this.precisionMetros,
  });

  final double latitud;
  final double longitud;
  final double precisionMetros;
}

class UbicacionActualFailure implements Exception {
  const UbicacionActualFailure(this.message, this.tipo);

  final String message;
  final UbicacionActualError tipo;

  @override
  String toString() => message;
}

abstract interface class UbicacionActualService {
  Future<UbicacionActual> obtener();

  Future<void> abrirAjustesAplicacion();

  Future<void> abrirAjustesUbicacion();
}

class GeolocatorUbicacionActualService implements UbicacionActualService {
  const GeolocatorUbicacionActualService();

  @override
  Future<UbicacionActual> obtener() async {
    try {
      final servicioActivo = await Geolocator.isLocationServiceEnabled();

      if (!servicioActivo) {
        throw const UbicacionActualFailure(
          'La ubicación del dispositivo está desactivada. Actívala para continuar.',
          UbicacionActualError.servicioDesactivado,
        );
      }

      var permiso = await Geolocator.checkPermission();

      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.denied) {
        throw const UbicacionActualFailure(
          'Necesitamos permiso de ubicación para mostrar dónde estás.',
          UbicacionActualError.permisoDenegado,
        );
      }

      if (permiso == LocationPermission.deniedForever) {
        throw const UbicacionActualFailure(
          'El permiso de ubicación está bloqueado. Actívalo desde los ajustes de la app.',
          UbicacionActualError.permisoDenegadoPermanente,
        );
      }

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 25),
        ),
      );

      return UbicacionActual(
        latitud: posicion.latitude,
        longitud: posicion.longitude,
        precisionMetros: posicion.accuracy,
      );
    } on UbicacionActualFailure {
      rethrow;
    } on TimeoutException {
      throw const UbicacionActualFailure(
        'No pudimos obtener tu ubicación a tiempo. Inténtalo de nuevo.',
        UbicacionActualError.tiempoAgotado,
      );
    } catch (_) {
      throw const UbicacionActualFailure(
        'No se pudo obtener tu ubicación. Revisa el GPS e inténtalo de nuevo.',
        UbicacionActualError.noDisponible,
      );
    }
  }

  @override
  Future<void> abrirAjustesAplicacion() async {
    await Geolocator.openAppSettings();
  }

  @override
  Future<void> abrirAjustesUbicacion() async {
    await Geolocator.openLocationSettings();
  }
}

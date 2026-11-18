import 'package:dondeestacione/src/Routes/app_routes.dart';
import 'package:dondeestacione/src/Routes/routes.dart';
import 'package:dondeestacione/src/services/auth_service.dart';
import 'package:dondeestacione/src/services/ubicacion_actual_service.dart';
import 'package:dondeestacione/src/services/ubicacion_service.dart';
import 'package:dondeestacione/src/services/vehiculo_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.authService,
    this.vehiculoService,
    this.ubicacionService,
    this.ubicacionActualService,
    this.mapaTileProvider,
    this.isAuthenticated = false,
  });

  final AuthService? authService;
  final VehiculoService? vehiculoService;
  final UbicacionService? ubicacionService;
  final UbicacionActualService? ubicacionActualService;
  final TileProvider? mapaTileProvider;
  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    final servicioDeAutenticacion = authService ?? const SupabaseAuthService();
    final servicioDeVehiculos =
        vehiculoService ?? const SupabaseVehiculoService();
    final servicioDeUbicaciones =
        ubicacionService ?? const SupabaseUbicacionService();
    final servicioUbicacionActual =
        ubicacionActualService ?? const GeolocatorUbicacionActualService();

    return MaterialApp(
      title: 'SearchMyCar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: isAuthenticated ? AppRoutes.mapa : AppRoutes.inicio,
      routes: getAplicationRoutes(
        authService: servicioDeAutenticacion,
        vehiculoService: servicioDeVehiculos,
        ubicacionService: servicioDeUbicaciones,
        ubicacionActualService: servicioUbicacionActual,
        mapaTileProvider: mapaTileProvider,
      ),
    );
  }
}

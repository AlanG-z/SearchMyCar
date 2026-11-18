import 'package:dondeestacione/src/Routes/app_routes.dart';
import 'package:dondeestacione/src/pages/configuracion_page.dart';
import 'package:dondeestacione/src/pages/historial_page.dart';
import 'package:dondeestacione/src/pages/inicio_page.dart';
import 'package:dondeestacione/src/pages/mapa_page.dart';
import 'package:dondeestacione/src/pages/registro_page.dart';
import 'package:dondeestacione/src/pages/vehiculos_page.dart';
import 'package:dondeestacione/src/services/auth_service.dart';
import 'package:dondeestacione/src/services/ubicacion_actual_service.dart';
import 'package:dondeestacione/src/services/ubicacion_service.dart';
import 'package:dondeestacione/src/services/vehiculo_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

Map<String, WidgetBuilder> getAplicationRoutes({
  required AuthService authService,
  required VehiculoService vehiculoService,
  required UbicacionService ubicacionService,
  required UbicacionActualService ubicacionActualService,
  TileProvider? mapaTileProvider,
}) {
  return <String, WidgetBuilder>{
    AppRoutes.inicio: (context) => InicioPage(authService: authService),
    AppRoutes.registro: (context) => RegistroPage(authService: authService),
    AppRoutes.mapa: (context) => MapaPage(
      vehiculoService: vehiculoService,
      ubicacionService: ubicacionService,
      ubicacionActualService: ubicacionActualService,
      tileProvider: mapaTileProvider,
    ),
    AppRoutes.vehiculos: (context) =>
        VehiculosPage(vehiculoService: vehiculoService),
    AppRoutes.registros: (context) => HistorialPage(
      ubicacionService: ubicacionService,
      vehiculoService: vehiculoService,
    ),
    AppRoutes.ajustes: (context) => ConfiguracionPage(authService: authService),
  };
}

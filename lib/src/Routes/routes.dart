import 'package:dondeestacione/src/Routes/app_routes.dart';
import 'package:dondeestacione/src/pages/configuracion_page.dart';
import 'package:dondeestacione/src/pages/editar_page.dart';
import 'package:dondeestacione/src/pages/historial_page.dart';
import 'package:dondeestacione/src/pages/home_page.dart';
import 'package:dondeestacione/src/pages/inicio_page.dart';
import 'package:dondeestacione/src/services/auth_service.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> getAplicationRoutes({
  required AuthService authService,
}) {
  return <String, WidgetBuilder>{
    AppRoutes.inicio: (context) => InicioPage(authService: authService),
    AppRoutes.mapa: (context) => const MyHomePage(title: 'Mapa'),
    AppRoutes.editar: (context) => const EditarPage(),
    AppRoutes.registros: (context) => const HistorialPage(),
    AppRoutes.ajustes: (context) => const ConfiguracionPage(),
  };
}

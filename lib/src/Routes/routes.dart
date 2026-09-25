import 'package:dondeestacione/src/Routes/app_routes.dart';
import 'package:dondeestacione/src/pages/configuracion_page.dart';
import 'package:dondeestacione/src/pages/editar_page.dart';
import 'package:dondeestacione/src/pages/historial_page.dart';
import 'package:dondeestacione/src/pages/home_page.dart';
import 'package:dondeestacione/src/pages/inicio_page.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> getAplicationRoutes() {
  return <String, WidgetBuilder>{
    AppRoutes.inicio: (context) => const InicioPage(),
    AppRoutes.mapa: (context) => const MyHomePage(title: 'Mapa'),
    AppRoutes.editar: (context) => const EditarPage(),
    AppRoutes.registros: (context) => const HistorialPage(),
    AppRoutes.ajustes: (context) => const ConfiguracionPage(),
  };
}

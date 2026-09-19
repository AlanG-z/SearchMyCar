import 'package:dondeestacione/src/pages/home_page.dart';
import 'package:dondeestacione/src/pages/inicio_page.dart';
import 'package:flutter/cupertino.dart';

Map<String, WidgetBuilder> getAplicationRoutes(){
  return <String, WidgetBuilder>{
    "/": (context) => const InicioPage(),
    "/home": (context) => const MyHomePage(title: 'SearchMyCar'),
  };
} 
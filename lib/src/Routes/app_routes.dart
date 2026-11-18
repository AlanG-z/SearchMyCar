abstract final class AppRoutes {
  static const String inicio = '/';
  static const String registro = '/registro';
  static const String mapa = '/mapa';
  static const String vehiculos = '/vehiculos';
  static const String registros = '/registros';
  static const String ajustes = '/ajustes';

  static const List<String> bottomNavigationRoutes = <String>[
    mapa,
    vehiculos,
    registros,
    ajustes,
  ];
}

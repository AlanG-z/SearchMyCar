abstract final class AppRoutes {
  static const String inicio = '/';
  static const String mapa = '/mapa';
  static const String editar = '/editar';
  static const String registros = '/registros';
  static const String ajustes = '/ajustes';

  static const List<String> bottomNavigationRoutes = <String>[
    mapa,
    editar,
    registros,
    ajustes,
  ];
}

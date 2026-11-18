import 'dart:convert';
import 'dart:typed_data';

import 'package:dondeestacione/src/app.dart';
import 'package:dondeestacione/src/models/ubicacion.dart';
import 'package:dondeestacione/src/models/vehiculo.dart';
import 'package:dondeestacione/src/services/auth_service.dart';
import 'package:dondeestacione/src/services/ubicacion_actual_service.dart';
import 'package:dondeestacione/src/services/ubicacion_service.dart';
import 'package:dondeestacione/src/services/vehiculo_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

const _emailField = Key('login-email-field');
const _passwordField = Key('login-password-field');
const _registerEmailField = Key('register-email-field');
const _registerPasswordField = Key('register-password-field');
const _registerConfirmPasswordField = Key('register-confirm-password-field');

class _FakeAuthService implements AuthService {
  _FakeAuthService({
    this.error,
    this.errorDeRegistro,
    this.requiereConfirmacion = false,
  });

  final String? error;
  final String? errorDeRegistro;
  final bool requiereConfirmacion;

  int llamadas = 0;
  int registros = 0;
  int cierres = 0;
  String? correoRecibido;
  String? contrasenaRecibida;
  String? correoRegistrado;
  String? contrasenaRegistrada;

  @override
  String? get correoActual => 'conductor@searchmycar.com';

  @override
  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    llamadas++;
    correoRecibido = correo;
    contrasenaRecibida = contrasena;

    if (error != null) {
      throw AuthFailure(error!);
    }
  }

  @override
  Future<RegistroResultado> registrar({
    required String correo,
    required String contrasena,
  }) async {
    registros++;
    correoRegistrado = correo;
    contrasenaRegistrada = contrasena;

    if (errorDeRegistro != null) {
      throw AuthFailure(errorDeRegistro!);
    }

    return RegistroResultado(requiereConfirmacion: requiereConfirmacion);
  }

  @override
  Future<void> cerrarSesion() async {
    cierres++;
    if (error != null) {
      throw AuthFailure(error!);
    }
  }
}

class _FakeVehiculoService implements VehiculoService {
  _FakeVehiculoService({List<Vehiculo>? vehiculos})
    : _vehiculos = List<Vehiculo>.from(vehiculos ?? const []);

  final List<Vehiculo> _vehiculos;
  int listados = 0;
  int creados = 0;
  int actualizados = 0;
  int eliminados = 0;
  int _siguienteId = 100;

  List<Vehiculo> get vehiculos => List.unmodifiable(_vehiculos);

  @override
  Future<List<Vehiculo>> listar() async {
    listados++;
    return List<Vehiculo>.unmodifiable(_vehiculos);
  }

  @override
  Future<Vehiculo> crear(VehiculoInput datos) async {
    creados++;
    final vehiculo = Vehiculo(
      id: 'vehiculo-${_siguienteId++}',
      categoria: datos.categoria,
      marca: datos.marca.trim(),
      modelo: datos.modelo.trim(),
      patente: datos.patente.trim().toUpperCase(),
      color: datos.color.trim(),
      anio: datos.anio,
    );
    _vehiculos.insert(0, vehiculo);
    return vehiculo;
  }

  @override
  Future<Vehiculo> actualizar(String id, VehiculoInput datos) async {
    actualizados++;
    final indice = _vehiculos.indexWhere((vehiculo) => vehiculo.id == id);

    if (indice == -1) {
      throw const VehiculoFailure('No se encontró el vehículo.');
    }

    final actualizado = Vehiculo(
      id: id,
      categoria: datos.categoria,
      marca: datos.marca.trim(),
      modelo: datos.modelo.trim(),
      patente: datos.patente.trim().toUpperCase(),
      color: datos.color.trim(),
      anio: datos.anio,
    );
    _vehiculos[indice] = actualizado;
    return actualizado;
  }

  @override
  Future<void> eliminar(String id) async {
    eliminados++;
    _vehiculos.removeWhere((vehiculo) => vehiculo.id == id);
  }
}

class _FakeUbicacionActualService implements UbicacionActualService {
  _FakeUbicacionActualService({this.error});

  final UbicacionActual ubicacion = const UbicacionActual(
    latitud: -34.6037,
    longitud: -58.3816,
    precisionMetros: 12,
  );
  final UbicacionActualFailure? error;
  int llamadas = 0;
  int ajustesAplicacion = 0;
  int ajustesUbicacion = 0;

  @override
  Future<UbicacionActual> obtener() async {
    llamadas++;

    if (error != null) {
      throw error!;
    }

    return ubicacion;
  }

  @override
  Future<void> abrirAjustesAplicacion() async {
    ajustesAplicacion++;
  }

  @override
  Future<void> abrirAjustesUbicacion() async {
    ajustesUbicacion++;
  }
}

class _FakeUbicacionService implements UbicacionService {
  _FakeUbicacionService({List<UbicacionGuardada>? ubicaciones})
    : _ubicaciones = List<UbicacionGuardada>.from(ubicaciones ?? const []);

  final List<UbicacionGuardada> _ubicaciones;
  final List<
    ({
      String vehiculoId,
      double latitud,
      double longitud,
      double? precisionMetros,
    })
  >
  guardadas = [];
  int listados = 0;
  final List<String> eliminados = [];
  int _siguienteId = 1;

  @override
  Future<void> guardar({
    required String vehiculoId,
    required double latitud,
    required double longitud,
    double? precisionMetros,
  }) async {
    guardadas.add((
      vehiculoId: vehiculoId,
      latitud: latitud,
      longitud: longitud,
      precisionMetros: precisionMetros,
    ));
    _ubicaciones.insert(
      0,
      UbicacionGuardada(
        id: 'ubicacion-${_siguienteId++}',
        vehiculoId: vehiculoId,
        latitud: latitud,
        longitud: longitud,
        precisionMetros: precisionMetros,
        creadoEn: DateTime.now(),
      ),
    );
  }

  @override
  Future<List<UbicacionGuardada>> listar() async {
    listados++;
    return List<UbicacionGuardada>.unmodifiable(_ubicaciones);
  }

  @override
  Future<void> eliminar(String id) async {
    eliminados.add(id);
    _ubicaciones.removeWhere((ubicacion) => ubicacion.id == id);
  }
}

final Uint8List _pixelTransparente = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
);

class _FakeTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MemoryImage(_pixelTransparente);
  }
}

Future<_FakeAuthService> _mostrarApp(
  WidgetTester tester, {
  String? errorDeAcceso,
  String? errorDeRegistro,
  bool requiereConfirmacion = false,
  _FakeVehiculoService? vehiculoService,
  _FakeUbicacionService? ubicacionService,
  _FakeUbicacionActualService? ubicacionActualService,
}) async {
  final authService = _FakeAuthService(
    error: errorDeAcceso,
    errorDeRegistro: errorDeRegistro,
    requiereConfirmacion: requiereConfirmacion,
  );
  await tester.pumpWidget(
    MyApp(
      authService: authService,
      vehiculoService: vehiculoService ?? _FakeVehiculoService(),
      ubicacionService: ubicacionService ?? _FakeUbicacionService(),
      ubicacionActualService:
          ubicacionActualService ?? _FakeUbicacionActualService(),
      mapaTileProvider: _FakeTileProvider(),
    ),
  );
  return authService;
}

Future<void> iniciarSesion(WidgetTester tester) async {
  await tester.enterText(find.byKey(_emailField), 'conductor@searchmycar.com');
  await tester.enterText(find.byKey(_passwordField), '123456');
  await tester.tap(find.text('Iniciar sesión'));
  await tester.pumpAndSettle();
}

Future<void> _irAVehiculos(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.byIcon(Icons.garage_outlined),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('muestra el acceso y valida los campos', (tester) async {
    final authService = await _mostrarApp(tester);

    expect(find.text('SearchMyCar'), findsOneWidget);
    expect(find.byKey(_emailField), findsOneWidget);
    expect(find.byKey(_passwordField), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('¿No tienes cuenta?'), findsOneWidget);
    expect(find.text('Regístrate'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.textContaining('Bienvenido'), findsNothing);

    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();

    expect(find.text('Ingresa tu correo electrónico'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
    expect(find.text('Guardar ubicación'), findsNothing);
    expect(authService.llamadas, 0);
  });

  testWidgets('envía las credenciales y abre el mapa', (tester) async {
    final authService = await _mostrarApp(tester);

    await iniciarSesion(tester);

    expect(authService.llamadas, 1);
    expect(authService.correoRecibido, 'conductor@searchmycar.com');
    expect(authService.contrasenaRecibida, '123456');
    expect(find.text('Guardar ubicación'), findsOneWidget);
    expect(find.text('Mapa'), findsWidgets);
  });

  testWidgets('muestra el error cuando Supabase rechaza el acceso', (
    tester,
  ) async {
    await _mostrarApp(
      tester,
      errorDeAcceso: 'Correo o contraseña incorrectos.',
    );

    await iniciarSesion(tester);

    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
    expect(find.text('Guardar ubicación'), findsNothing);
  });

  testWidgets('abre directamente el mapa si ya hay una sesión activa', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        authService: _FakeAuthService(),
        vehiculoService: _FakeVehiculoService(),
        ubicacionService: _FakeUbicacionService(),
        ubicacionActualService: _FakeUbicacionActualService(),
        mapaTileProvider: _FakeTileProvider(),
        isAuthenticated: true,
      ),
    );

    expect(find.text('Guardar ubicación'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsNothing);
  });

  testWidgets('muestra la ubicación actual y la guarda con el vehículo', (
    tester,
  ) async {
    final vehiculo = Vehiculo(
      id: 'vehiculo-1',
      categoria: CategoriaVehiculo.auto,
      marca: 'Toyota',
      modelo: 'Corolla',
      patente: 'ABC-123',
      color: 'Blanco',
      anio: 2022,
    );
    final vehiculoService = _FakeVehiculoService(vehiculos: [vehiculo]);
    final ubicacionService = _FakeUbicacionService();
    final ubicacionActualService = _FakeUbicacionActualService();

    await _mostrarApp(
      tester,
      vehiculoService: vehiculoService,
      ubicacionService: ubicacionService,
      ubicacionActualService: ubicacionActualService,
    );
    await iniciarSesion(tester);

    expect(ubicacionActualService.llamadas, 1);
    expect(find.text('Ubicación actual'), findsOneWidget);
    expect(find.textContaining('-34.60370'), findsOneWidget);
    expect(find.textContaining('Toyota Corolla'), findsOneWidget);

    await tester.tap(find.byKey(const Key('mapa-guardar-ubicacion')));
    await tester.pumpAndSettle();

    expect(ubicacionService.guardadas, hasLength(1));
    final guardada = ubicacionService.guardadas.single;
    expect(guardada.vehiculoId, 'vehiculo-1');
    expect(guardada.latitud, -34.6037);
    expect(guardada.longitud, -58.3816);
    expect(guardada.precisionMetros, 12);
    expect(
      find.text('Ubicación guardada para Toyota Corolla.'),
      findsOneWidget,
    );
  });

  testWidgets('muestra las ubicaciones guardadas en el historial', (
    tester,
  ) async {
    final vehiculo = Vehiculo(
      id: 'vehiculo-1',
      categoria: CategoriaVehiculo.auto,
      marca: 'Toyota',
      modelo: 'Corolla',
      patente: 'ABC-123',
      color: 'Blanco',
      anio: 2022,
    );
    final ubicacionService = _FakeUbicacionService(
      ubicaciones: [
        UbicacionGuardada(
          id: 'ubicacion-1',
          vehiculoId: 'vehiculo-1',
          latitud: -34.6037,
          longitud: -58.3816,
          precisionMetros: 12,
          creadoEn: DateTime(2026, 11, 9, 14, 30),
        ),
      ],
    );

    await _mostrarApp(
      tester,
      vehiculoService: _FakeVehiculoService(vehiculos: [vehiculo]),
      ubicacionService: ubicacionService,
    );
    await iniciarSesion(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.byIcon(Icons.assignment_outlined),
      ),
    );
    await tester.pumpAndSettle();

    expect(ubicacionService.listados, 1);
    expect(find.text('Historial de ubicaciones'), findsOneWidget);
    expect(find.text('Toyota Corolla'), findsOneWidget);
    expect(find.text('ABC-123 · Blanco'), findsOneWidget);
    expect(find.textContaining('-34.60370'), findsOneWidget);
    expect(find.textContaining('Precisión ±12 m'), findsOneWidget);
    expect(find.textContaining('09/11/2026'), findsOneWidget);
  });

  testWidgets('abre una ubicación pasada en el mapa y permite eliminarla', (
    tester,
  ) async {
    final vehiculo = Vehiculo(
      id: 'vehiculo-1',
      categoria: CategoriaVehiculo.auto,
      marca: 'Toyota',
      modelo: 'Corolla',
      patente: 'ABC-123',
      color: 'Blanco',
      anio: 2022,
    );
    final ubicacionService = _FakeUbicacionService(
      ubicaciones: [
        UbicacionGuardada(
          id: 'ubicacion-1',
          vehiculoId: 'vehiculo-1',
          latitud: -34.6037,
          longitud: -58.3816,
          precisionMetros: 12,
          creadoEn: DateTime(2026, 11, 9, 14, 30),
        ),
      ],
    );

    await _mostrarApp(
      tester,
      vehiculoService: _FakeVehiculoService(vehiculos: [vehiculo]),
      ubicacionService: ubicacionService,
    );
    await iniciarSesion(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.byIcon(Icons.assignment_outlined),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('historial-ubicacion-ubicacion-1')));
    await tester.pumpAndSettle();

    expect(find.text('Ubicación guardada'), findsOneWidget);
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.text('Latitud -34.60370'), findsOneWidget);
    expect(find.text('Longitud -58.38160'), findsOneWidget);
    expect(find.text('Toyota Corolla'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('historial-eliminar-ubicacion-1')));
    await tester.pumpAndSettle();

    expect(find.text('Eliminar ubicación'), findsOneWidget);
    expect(ubicacionService.eliminados, isEmpty);

    await tester.tap(find.byKey(const Key('historial-confirmar-eliminar')));
    await tester.pumpAndSettle();

    expect(ubicacionService.eliminados, ['ubicacion-1']);
    expect(find.text('Aún no hay ubicaciones guardadas'), findsOneWidget);
    expect(find.text('Ubicación eliminada.'), findsOneWidget);
  });

  testWidgets('avisa cuando el permiso de ubicación está bloqueado', (
    tester,
  ) async {
    final ubicacionService = _FakeUbicacionService();
    await _mostrarApp(
      tester,
      ubicacionService: ubicacionService,
      ubicacionActualService: _FakeUbicacionActualService(
        error: const UbicacionActualFailure(
          'El permiso de ubicación está bloqueado. Actívalo desde los ajustes de la app.',
          UbicacionActualError.permisoDenegadoPermanente,
        ),
      ),
    );
    await iniciarSesion(tester);

    expect(
      find.text(
        'El permiso de ubicación está bloqueado. Actívalo desde los ajustes de la app.',
      ),
      findsOneWidget,
    );
    expect(find.text('Abrir ajustes'), findsOneWidget);

    await tester.tap(find.byKey(const Key('mapa-guardar-ubicacion')));
    await tester.pumpAndSettle();

    expect(ubicacionService.guardadas, isEmpty);
  });

  testWidgets('valida el formulario de registro y crea la cuenta', (
    tester,
  ) async {
    final authService = await _mostrarApp(tester, requiereConfirmacion: true);

    await tester.tap(find.text('Regístrate'));
    await tester.pumpAndSettle();

    expect(find.text('Crea tu cuenta'), findsOneWidget);

    final botonCrear = find.widgetWithText(FilledButton, 'Crear cuenta');
    await tester.ensureVisible(botonCrear);
    await tester.tap(botonCrear);
    await tester.pump();

    expect(find.text('Ingresa tu correo electrónico'), findsOneWidget);
    expect(find.text('Ingresa una contraseña'), findsOneWidget);
    expect(find.text('Repite tu contraseña'), findsOneWidget);
    expect(authService.registros, 0);

    await tester.enterText(
      find.byKey(_registerEmailField),
      'nuevo@searchmycar.com',
    );
    await tester.enterText(find.byKey(_registerPasswordField), 'segura123');
    await tester.enterText(
      find.byKey(_registerConfirmPasswordField),
      'segura123',
    );
    await tester.ensureVisible(botonCrear);
    await tester.tap(botonCrear);
    await tester.pumpAndSettle();

    expect(authService.registros, 1);
    expect(authService.correoRegistrado, 'nuevo@searchmycar.com');
    expect(authService.contrasenaRegistrada, 'segura123');
    expect(find.text('Cuenta creada'), findsOneWidget);
    expect(find.textContaining('confirma la cuenta'), findsOneWidget);

    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);
  });

  testWidgets('muestra el error cuando el registro falla', (tester) async {
    await _mostrarApp(
      tester,
      errorDeRegistro: 'Ya existe una cuenta con ese correo. Inicia sesión.',
    );

    await tester.tap(find.text('Regístrate'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(_registerEmailField),
      'nuevo@searchmycar.com',
    );
    await tester.enterText(find.byKey(_registerPasswordField), 'segura123');
    await tester.enterText(
      find.byKey(_registerConfirmPasswordField),
      'segura123',
    );

    final botonCrear = find.widgetWithText(FilledButton, 'Crear cuenta');
    await tester.ensureVisible(botonCrear);
    await tester.tap(botonCrear);
    await tester.pumpAndSettle();

    expect(
      find.text('Ya existe una cuenta con ese correo. Inicia sesión.'),
      findsOneWidget,
    );
  });

  testWidgets('la barra inferior abre cada página', (tester) async {
    await _mostrarApp(tester);
    await iniciarSesion(tester);

    Finder navigationIcon(IconData icon) {
      return find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.byIcon(icon),
      );
    }

    BottomNavigationBar navigationBar() {
      return tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
    }

    expect(navigationBar().currentIndex, 0);

    await tester.tap(navigationIcon(Icons.garage_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Mis vehículos'), findsOneWidget);
    expect(find.text('Aún no tienes vehículos'), findsOneWidget);
    expect(navigationBar().currentIndex, 1);

    await tester.tap(navigationIcon(Icons.assignment_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Historial de ubicaciones'), findsOneWidget);
    expect(find.text('Aún no hay ubicaciones guardadas'), findsOneWidget);
    expect(navigationBar().currentIndex, 2);

    await tester.tap(navigationIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Cuenta'), findsOneWidget);
    expect(find.text('conductor@searchmycar.com'), findsOneWidget);
    expect(navigationBar().currentIndex, 3);

    await tester.tap(navigationIcon(Icons.map_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Guardar ubicación'), findsOneWidget);
    expect(navigationBar().currentIndex, 0);
  });

  testWidgets('permite agregar un vehículo con categoría', (tester) async {
    final vehiculoService = _FakeVehiculoService();
    await _mostrarApp(tester, vehiculoService: vehiculoService);
    await iniciarSesion(tester);
    await _irAVehiculos(tester);

    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo vehículo'), findsOneWidget);
    expect(find.byKey(const Key('vehicle-category-field')), findsOneWidget);

    await tester.tap(find.byKey(const Key('vehicle-category-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Moto').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('vehicle-brand-field')),
      'Yamaha',
    );
    await tester.enterText(
      find.byKey(const Key('vehicle-model-field')),
      'FZ 250',
    );
    await tester.enterText(
      find.byKey(const Key('vehicle-plate-field')),
      'abc-123',
    );
    await tester.enterText(
      find.byKey(const Key('vehicle-color-field')),
      'Negro',
    );
    await tester.enterText(find.byKey(const Key('vehicle-year-field')), '2024');

    final botonGuardar = find.widgetWithText(FilledButton, 'Guardar vehículo');
    await tester.ensureVisible(botonGuardar);
    await tester.tap(botonGuardar);
    await tester.pumpAndSettle();

    expect(vehiculoService.creados, 1);
    expect(vehiculoService.vehiculos.single.categoria, CategoriaVehiculo.moto);
    expect(vehiculoService.vehiculos.single.patente, 'ABC-123');
    expect(find.text('Yamaha FZ 250'), findsOneWidget);
    expect(find.text('Moto'), findsOneWidget);
  });

  testWidgets('permite eliminar un vehículo propio', (tester) async {
    final vehiculo = Vehiculo(
      id: 'vehiculo-1',
      categoria: CategoriaVehiculo.auto,
      marca: 'Toyota',
      modelo: 'Corolla',
      patente: 'ABC-123',
      color: 'Blanco',
      anio: 2022,
    );
    final vehiculoService = _FakeVehiculoService(vehiculos: [vehiculo]);
    await _mostrarApp(tester, vehiculoService: vehiculoService);
    await iniciarSesion(tester);
    await _irAVehiculos(tester);

    expect(find.text('Toyota Corolla'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(find.text('Eliminar vehículo'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();

    expect(vehiculoService.eliminados, 1);
    expect(find.text('Toyota Corolla'), findsNothing);
    expect(find.text('Aún no tienes vehículos'), findsOneWidget);
  });

  testWidgets('permite cerrar sesión desde ajustes', (tester) async {
    final authService = await _mostrarApp(tester);
    await iniciarSesion(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.byIcon(Icons.settings_outlined),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(authService.cierres, 1);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
  });
}

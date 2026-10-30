import 'package:dondeestacione/src/app.dart';
import 'package:dondeestacione/src/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _emailField = Key('login-email-field');
const _passwordField = Key('login-password-field');

class _FakeAuthService implements AuthService {
  _FakeAuthService({this.error});

  final String? error;
  int llamadas = 0;
  String? correoRecibido;
  String? contrasenaRecibida;

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
}

Future<_FakeAuthService> _mostrarApp(
  WidgetTester tester, {
  String? errorDeAcceso,
}) async {
  final authService = _FakeAuthService(error: errorDeAcceso);
  await tester.pumpWidget(MyApp(authService: authService));
  return authService;
}

Future<void> iniciarSesion(WidgetTester tester) async {
  await tester.enterText(find.byKey(_emailField), 'conductor@searchmycar.com');
  await tester.enterText(find.byKey(_passwordField), '123456');
  await tester.tap(find.text('Iniciar sesión'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('muestra el acceso y valida los campos', (tester) async {
    final authService = await _mostrarApp(tester);

    expect(find.text('SearchMyCar'), findsOneWidget);
    expect(find.byKey(_emailField), findsOneWidget);
    expect(find.byKey(_passwordField), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
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
      MyApp(authService: _FakeAuthService(), isAuthenticated: true),
    );

    expect(find.text('Guardar ubicación'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsNothing);
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

    await tester.tap(navigationIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Guardar datos del vehículo'), findsOneWidget);
    expect(
      find.byKey(const Key('vehicle-model-field'), skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('vehicle-plate-field'), skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('vehicle-color-field'), skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('vehicle-brand-field'), skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('vehicle-year-field'), skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('vehicle-type-field'), skipOffstage: false),
      findsOneWidget,
    );
    expect(navigationBar().currentIndex, 1);

    await tester.tap(navigationIcon(Icons.assignment_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Historial de ubicaciones'), findsOneWidget);
    expect(navigationBar().currentIndex, 2);

    await tester.tap(navigationIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Configuración'), findsOneWidget);
    expect(navigationBar().currentIndex, 3);

    await tester.tap(navigationIcon(Icons.map_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Guardar ubicación'), findsOneWidget);
    expect(navigationBar().currentIndex, 0);
  });
}

import 'package:dondeestacione/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _emailField = Key('login-email-field');
const _passwordField = Key('login-password-field');

Future<void> iniciarSesion(WidgetTester tester) async {
  await tester.enterText(find.byKey(_emailField), 'conductor@searchmycar.com');
  await tester.enterText(find.byKey(_passwordField), '123456');
  await tester.tap(find.text('Iniciar sesión'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('muestra el acceso y valida los campos', (tester) async {
    await tester.pumpWidget(const MyApp());

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
  });

  testWidgets('permite ingresar y abre el mapa', (tester) async {
    await tester.pumpWidget(const MyApp());

    await iniciarSesion(tester);

    expect(find.text('Guardar ubicación'), findsOneWidget);
    expect(find.text('Mapa'), findsWidgets);
  });

  testWidgets('la barra inferior abre cada página', (tester) async {
    await tester.pumpWidget(const MyApp());
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
    expect(find.text('Editar vehículo'), findsOneWidget);
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

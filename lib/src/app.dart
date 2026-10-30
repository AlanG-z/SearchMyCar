import 'package:dondeestacione/src/Routes/app_routes.dart';
import 'package:dondeestacione/src/Routes/routes.dart';
import 'package:dondeestacione/src/services/auth_service.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.authService, this.isAuthenticated = false});

  final AuthService? authService;
  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    final servicioDeAutenticacion = authService ?? const SupabaseAuthService();

    return MaterialApp(
      title: 'SearchMyCar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: isAuthenticated ? AppRoutes.mapa : AppRoutes.inicio,
      routes: getAplicationRoutes(authService: servicioDeAutenticacion),
    );
  }
}

import 'package:dondeestacione/src/Routes/app_routes.dart';
import 'package:flutter/material.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  static const Key emailFieldKey = Key('login-email-field');
  static const Key passwordFieldKey = Key('login-password-field');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _iniciarSesion() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRoutes.mapa);
  }

  String? _validarCorreo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu correo electrónico';
    }

    final correo = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!correo.hasMatch(value.trim())) {
      return 'Ingresa un correo electrónico válido';
    }

    return null;
  }

  String? _validarContrasena(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu contraseña';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF3E5), Colors.white],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final verticalPadding = constraints.maxHeight < 600 ? 24.0 : 48.0;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  verticalPadding,
                  24,
                  verticalPadding,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - (verticalPadding * 2),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: AutofillGroup(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Align(
                                child: Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Icon(
                                    Icons.directions_car,
                                    size: 48,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'SearchMyCar',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: Colors.orange.shade900,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Inicia sesión para encontrar tu vehículo',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: Colors.blueGrey.shade600),
                              ),
                              const SizedBox(height: 32),
                              Card(
                                elevation: 3,
                                shadowColor: Colors.orange.withValues(
                                  alpha: 0.18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: Colors.orange.withValues(
                                      alpha: 0.15,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      TextFormField(
                                        key: emailFieldKey,
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.email,
                                        ],
                                        autocorrect: false,
                                        decoration: const InputDecoration(
                                          labelText: 'Correo electrónico',
                                          hintText: 'nombre@correo.com',
                                          prefixIcon: Icon(
                                            Icons.email_outlined,
                                          ),
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: _validarCorreo,
                                      ),
                                      const SizedBox(height: 18),
                                      TextFormField(
                                        key: passwordFieldKey,
                                        controller: _passwordController,
                                        obscureText: _hidePassword,
                                        textInputAction: TextInputAction.done,
                                        autofillHints: const [
                                          AutofillHints.password,
                                        ],
                                        onFieldSubmitted: (_) =>
                                            _iniciarSesion(),
                                        decoration: InputDecoration(
                                          labelText: 'Contraseña',
                                          prefixIcon: const Icon(
                                            Icons.lock_outline,
                                          ),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _hidePassword = !_hidePassword;
                                              });
                                            },
                                            tooltip: _hidePassword
                                                ? 'Mostrar contraseña'
                                                : 'Ocultar contraseña',
                                            icon: Icon(
                                              _hidePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                        .visibility_off_outlined,
                                            ),
                                          ),
                                          border: const OutlineInputBorder(),
                                        ),
                                        validator: _validarContrasena,
                                      ),
                                      const SizedBox(height: 24),
                                      FilledButton.icon(
                                        onPressed: _iniciarSesion,
                                        icon: const Icon(Icons.login),
                                        label: const Text('Iniciar sesión'),
                                        style: FilledButton.styleFrom(
                                          minimumSize: const Size.fromHeight(
                                            52,
                                          ),
                                          backgroundColor:
                                              Colors.orange.shade700,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

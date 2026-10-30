import 'package:dondeestacione/src/Routes/app_routes.dart';
import 'package:dondeestacione/src/services/auth_service.dart';
import 'package:flutter/material.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({required this.authService, super.key});

  final AuthService authService;

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
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (_isLoading) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.authService.iniciarSesion(
        correo: _emailController.text,
        contrasena: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacementNamed(AppRoutes.mapa);
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Ocurrió un error inesperado. Inténtalo de nuevo más tarde.';
      });
    }
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
                                        enabled: !_isLoading,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.email,
                                        ],
                                        autocorrect: false,
                                        onChanged: (_) {
                                          if (_errorMessage != null) {
                                            setState(() {
                                              _errorMessage = null;
                                            });
                                          }
                                        },
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
                                        enabled: !_isLoading,
                                        obscureText: _hidePassword,
                                        textInputAction: TextInputAction.done,
                                        autofillHints: const [
                                          AutofillHints.password,
                                        ],
                                        onChanged: (_) {
                                          if (_errorMessage != null) {
                                            setState(() {
                                              _errorMessage = null;
                                            });
                                          }
                                        },
                                        onFieldSubmitted: _isLoading
                                            ? null
                                            : (_) => _iniciarSesion(),
                                        decoration: InputDecoration(
                                          labelText: 'Contraseña',
                                          prefixIcon: const Icon(
                                            Icons.lock_outline,
                                          ),
                                          suffixIcon: IconButton(
                                            onPressed: _isLoading
                                                ? null
                                                : () {
                                                    setState(() {
                                                      _hidePassword =
                                                          !_hidePassword;
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
                                      const SizedBox(height: 20),
                                      if (_errorMessage != null) ...[
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.red.shade200,
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: Colors.red.shade700,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  _errorMessage!,
                                                  style: TextStyle(
                                                    color: Colors.red.shade900,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                      FilledButton(
                                        onPressed: _isLoading
                                            ? null
                                            : _iniciarSesion,
                                        style: FilledButton.styleFrom(
                                          minimumSize: const Size.fromHeight(
                                            52,
                                          ),
                                          backgroundColor:
                                              Colors.orange.shade700,
                                          disabledBackgroundColor:
                                              Colors.orange.shade300,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.login),
                                                  SizedBox(width: 8),
                                                  Text('Iniciar sesión'),
                                                ],
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Ingresa con una cuenta creada en Supabase.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.blueGrey.shade500),
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

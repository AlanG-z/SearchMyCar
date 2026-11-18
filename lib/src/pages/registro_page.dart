import 'package:dondeestacione/src/Routes/app_routes.dart';
import 'package:dondeestacione/src/services/auth_service.dart';
import 'package:flutter/material.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({required this.authService, super.key});

  final AuthService authService;

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  static const Key emailFieldKey = Key('register-email-field');
  static const Key passwordFieldKey = Key('register-password-field');
  static const Key confirmPasswordFieldKey = Key(
    'register-confirm-password-field',
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _hidePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
      return 'Ingresa una contraseña';
    }

    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    return null;
  }

  String? _validarConfirmacion(String? value) {
    if (value == null || value.isEmpty) {
      return 'Repite tu contraseña';
    }

    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  Future<void> _registrar() async {
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
      final resultado = await widget.authService.registrar(
        correo: _emailController.text,
        contrasena: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      if (!resultado.requiereConfirmacion) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.mapa, (route) => false);
        return;
      }

      setState(() {
        _isLoading = false;
      });

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            icon: Icon(
              Icons.mark_email_read_outlined,
              color: Colors.orange.shade700,
              size: 40,
            ),
            title: const Text('Cuenta creada'),
            content: const Text(
              'Revisa tu correo electrónico y confirma la cuenta para poder iniciar sesión.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendido'),
              ),
            ],
          );
        },
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
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

  InputDecoration _campoDecoration({
    required IconData icon,
    required String label,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF3E5), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.person_add_alt_1_outlined,
                          size: 64,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Crea tu cuenta',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Registra tus datos para guardar y administrar tus vehículos.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.blueGrey.shade600),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          elevation: 3,
                          shadowColor: Colors.orange.withValues(alpha: 0.18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: Colors.orange.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  key: emailFieldKey,
                                  controller: _emailController,
                                  enabled: !_isLoading,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email],
                                  autocorrect: false,
                                  decoration: _campoDecoration(
                                    icon: Icons.email_outlined,
                                    label: 'Correo electrónico',
                                  ),
                                  validator: _validarCorreo,
                                ),
                                const SizedBox(height: 18),
                                TextFormField(
                                  key: passwordFieldKey,
                                  controller: _passwordController,
                                  enabled: !_isLoading,
                                  obscureText: _hidePassword,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    helperText: 'Mínimo 8 caracteres',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () {
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
                                            : Icons.visibility_off_outlined,
                                      ),
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: _validarContrasena,
                                ),
                                const SizedBox(height: 18),
                                TextFormField(
                                  key: confirmPasswordFieldKey,
                                  controller: _confirmPasswordController,
                                  enabled: !_isLoading,
                                  obscureText: _hidePassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: _isLoading
                                      ? null
                                      : (_) => _registrar(),
                                  decoration: InputDecoration(
                                    labelText: 'Repetir contraseña',
                                    prefixIcon: const Icon(
                                      Icons.lock_reset_outlined,
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: _validarConfirmacion,
                                ),
                                const SizedBox(height: 20),
                                if (_errorMessage != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(12),
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
                                  onPressed: _isLoading ? null : _registrar,
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),
                                    backgroundColor: Colors.orange.shade700,
                                    disabledBackgroundColor:
                                        Colors.orange.shade300,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Crear cuenta'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Si la confirmación por correo está activa, recibirás un enlace para activar tu cuenta.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.blueGrey.shade500),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text('¿Ya tienes cuenta?'),
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              child: const Text('Inicia sesión'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

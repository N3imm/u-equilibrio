
// UBICACIÓN: lib/screens/login_screen.dart (REEMPLAZA el que ya tenías)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/aparecer.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _cargando = false;
  bool _ocultarPassword = true;
  String? _errorMensaje;

  Future<void> _manejarLogin() async {
    if (_cargando) return;
    setState(() {
      _cargando = true;
      _errorMensaje = null;
    });

    final error = await _authService.iniciarSesion(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _cargando = false;
      _errorMensaje = error;
    });
    // Si no hay error, main.dart detecta el cambio de sesión automáticamente
    // (gracias al StreamBuilder) y te lleva a la pantalla principal solo.
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Encabezado con degradado institucional, logo y nombre de la app.
  Widget _encabezado(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 32,
        24,
        40,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2B2B2D),
            ColoresUTS.grisOscuro,
            Color(0xFF55575A),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Aparecer(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/logo.png',
                height: 90,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.self_improvement,
                  size: 80,
                  color: ColoresUTS.verde,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Aparecer(
            retrasoMs: 200,
            child: Text(
              'U-Equilibrio',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Aparecer(
            retrasoMs: 300,
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: ColoresUTS.verde,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Aparecer(
            retrasoMs: 400,
            child: Text(
              'Tu bienestar universitario, en equilibrio',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// Mensaje de error que aparece suavemente (se expande al mostrarse).
  Widget _mensajeError() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: _errorMensaje == null
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMensaje!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Íconos claros en la barra de estado, porque el fondo es oscuro.
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              _encabezado(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Aparecer(
                  retrasoMs: 500,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Inicia sesión',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: ColoresUTS.grisOscuro,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ingresa para continuar con tu seguimiento',
                        style: TextStyle(color: ColoresUTS.gris),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordController,
                        obscureText: _ocultarPassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _manejarLogin(),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _ocultarPassword
                                ? 'Mostrar contraseña'
                                : 'Ocultar contraseña',
                            icon: Icon(
                              _ocultarPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _ocultarPassword = !_ocultarPassword,
                            ),
                          ),
                        ),
                      ),
                      _mensajeError(),
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _cargando ? null : _manejarLogin,
                          child: _cargando
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: ColoresUTS.grisOscuro,
                                  ),
                                )
                              : const Text('Iniciar sesión'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('¿No tienes cuenta? Regístrate'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

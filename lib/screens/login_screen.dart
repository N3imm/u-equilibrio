
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
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
  String? _errorMensaje;

  Future<void> _manejarLogin() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 20),
            if (_errorMensaje != null)
              Text(_errorMensaje!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            _cargando
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _manejarLogin,
                    child: const Text('Iniciar sesión'),
                  ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text('¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}
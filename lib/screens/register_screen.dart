
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _cargando = false;
  String? _errorMensaje;

  Future<void> _manejarRegistro() async {
    setState(() {
      _cargando = true;
      _errorMensaje = null;
    });

    final error = await _authService.registrarUsuario(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (error == null) {
      // Registro exitoso: Firebase ya deja al usuario con sesión iniciada.
      // main.dart (StreamBuilder) lo llevará a Home automáticamente.
      Navigator.of(context).pop();
    } else {
      setState(() {
        _cargando = false;
        _errorMensaje = error;
      });
    }
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
      appBar: AppBar(title: const Text('Crear cuenta')),
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
              decoration: const InputDecoration(
                labelText: 'Contraseña (mínimo 6 caracteres)',
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMensaje != null)
              Text(_errorMensaje!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            _cargando
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _manejarRegistro,
                    child: const Text('Registrarme'),
                  ),
          ],
        ),
      ),
    );
  }
}
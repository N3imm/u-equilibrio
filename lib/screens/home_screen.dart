import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'automonitoreo_screen.dart';
import 'pausas_activas_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final usuario = authService.usuarioActual;

    return Scaffold(
      appBar: AppBar(
        title: const Text('U-Equilibrio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => authService.cerrarSesion(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¡Bienvenido!\n${usuario?.email ?? ''}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.mood),
              label: const Text('Registrar mi estrés de hoy'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AutomonitoreoScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.self_improvement),
              label: const Text('Ver pausas activas'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PausasActivasScreen()),
                );
              },
            ),
          ],
        ), 
      ),
    );
  }
}
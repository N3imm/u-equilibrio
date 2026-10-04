import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'automonitoreo_screen.dart';
import 'pausas_activas_screen.dart';
import '../theme/app_theme.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: ColoresUTS.verde,
                      child: Icon(Icons.person, color: ColoresUTS.grisOscuro),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '¡Bienvenido!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ColoresUTS.grisOscuro,
                            ),
                          ),
                          Text(
                            usuario?.email ?? '',
                            style: const TextStyle(color: ColoresUTS.gris),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              icon: const Icon(Icons.mood),
              label: const Text('Registrar mi estrés de hoy'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AutomonitoreoScreen()),
                );
              },
            ),
            const SizedBox(height: 14),
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
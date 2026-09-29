
import 'package:flutter/material.dart';
import '../services/estres_service.dart';
import '../models/registro_estres.dart';
import '../models/pausa_activa.dart';
import '../data/pausas_predefinidas.dart';

/// Muestra una pausa activa sugerida según el nivel de estrés del
/// último registro guardado (objetivo específico 3: sistema de
/// sugerencias de pausas activas), seguida del catálogo completo.
class PausasActivasScreen extends StatelessWidget {
  const PausasActivasScreen({super.key});

  String _categoriaSugerida(int nivel) {
    if (nivel >= 4) return 'respiracion';
    if (nivel == 3) return 'estiramiento';
    return 'general';
  }

  String _mensajeSugerencia(int nivel) {
    if (nivel >= 4) {
      return 'Tu último registro muestra un nivel de estrés alto. '
          'Te recomendamos un ejercicio de respiración:';
    }
    if (nivel == 3) {
      return 'Tu último registro muestra un nivel de estrés medio. '
          'Un estiramiento te puede ayudar:';
    }
    return 'Tu nivel de estrés está bajo, ¡bien hecho! '
        'Aquí tienes una pausa de mantenimiento:';
  }

  @override
  Widget build(BuildContext context) {
    final estresService = EstresService();

    return Scaffold(
      appBar: AppBar(title: const Text('Pausas activas')),
      body: StreamBuilder<List<RegistroEstres>>(
        stream: estresService.streamRegistros(),
        builder: (context, snapshot) {
          final registros = snapshot.data ?? [];
          final hayRegistros = registros.isNotEmpty;
          final ultimoNivel = hayRegistros ? registros.first.nivel : 3;
          final categoriaSugerida = _categoriaSugerida(ultimoNivel);

          final sugeridas = pausasPredefinidas
              .where((p) => p.categoria == categoriaSugerida)
              .toList();
          final resto = pausasPredefinidas
              .where((p) => p.categoria != categoriaSugerida)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (hayRegistros) ...[
                Text(
                  _mensajeSugerencia(ultimoNivel),
                  style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                ...sugeridas.map((p) => _TarjetaPausa(pausa: p, destacada: true)),
                const SizedBox(height: 20),
                const Text('Otras pausas disponibles',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
              ] else ...[
                const Text(
                  'Todavía no tienes registros de estrés. '
                  'Aquí tienes algunas pausas activas para empezar:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
              ],
              ...resto.map((p) => _TarjetaPausa(pausa: p, destacada: false)),
            ],
          );
        },
      ),
    );
  }
}

class _TarjetaPausa extends StatelessWidget {
  final PausaActiva pausa;
  final bool destacada;

  const _TarjetaPausa({required this.pausa, required this.destacada});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: destacada ? Colors.teal.withOpacity(0.1) : null,
      shape: destacada
          ? RoundedRectangleBorder(
              side: const BorderSide(color: Colors.teal),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(pausa.titulo),
        subtitle: Text(pausa.descripcion),
        trailing: Text('${pausa.duracionMinutos} min'),
      ),
    );
  }
}
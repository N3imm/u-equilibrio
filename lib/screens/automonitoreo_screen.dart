// UBICACIÓN: lib/screens/automonitoreo_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../services/estres_service.dart';
import '../models/registro_estres.dart';
import '../theme/app_theme.dart';

class AutomonitoreoScreen extends StatefulWidget {
  const AutomonitoreoScreen({super.key});

  @override
  State<AutomonitoreoScreen> createState() => _AutomonitoreoScreenState();
}

class _AutomonitoreoScreenState extends State<AutomonitoreoScreen> {
  final EstresService _estresService = EstresService();
  final _notasController = TextEditingController();
  int _nivelSeleccionado = 3;
  bool _guardando = false;

  static const List<String> _emojis = ['😄', '🙂', '😐', '😟', '😫'];
  static const List<String> _etiquetas = [
    'Muy bajo',
    'Bajo',
    'Medio',
    'Alto',
    'Muy alto',
  ];

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      await _estresService.guardarRegistro(
        _nivelSeleccionado,
        _notasController.text.trim(),
      );
      _notasController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro guardado')),
        );
      }
    } catch (e) {
      // Si algo falla (ej. sin conexión a internet), ahora lo verás
      // en pantalla en vez de quedarte con el círculo de carga pegado.
      if (mounted) {
        final mensaje = (e is FirebaseException && e.code == 'permission-denied')
            ? 'Permiso denegado: revisa las reglas de seguridad de Firestore.'
            : 'Error al guardar: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje)),
        );
      }
    } finally {
      // El "finally" se ejecuta SIEMPRE, haya error o no,
      // así que el botón nunca vuelve a quedarse en modo "cargando" para siempre.
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/${fecha.year} '
        '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('¿Cómo te sientes hoy?')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (i) {
                    final nivel = i + 1;
                    final seleccionado = nivel == _nivelSeleccionado;
                    return GestureDetector(
                      onTap: () => setState(() => _nivelSeleccionado = nivel),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: seleccionado
                                  ? ColoresUTS.verde.withOpacity(0.3)
                                  : Colors.transparent,
                              border: Border.all(
                                color: seleccionado ? ColoresUTS.verde : Colors.grey,
                              ),
                            ),
                            child: Text(_emojis[i],
                                style: const TextStyle(fontSize: 28)),
                          ),
                          const SizedBox(height: 4),
                          Text(_etiquetas[i], style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notasController,
                  decoration: const InputDecoration(
                    labelText: '¿Qué está pasando? (opcional)',
                  ),
                ),
                const SizedBox(height: 12),
                _guardando
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _guardar,
                        child: const Text('Guardar registro'),
                      ),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child:
                  Text('Historial', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<RegistroEstres>>(
              stream: _estresService.streamRegistros(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No se pudo cargar el historial. '
                        'Verifica tu conexión y los permisos de Firestore.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final registros = snapshot.data!;
                if (registros.isEmpty) {
                  return const Center(child: Text('Todavía no tienes registros'));
                }
                return ListView.builder(
                  itemCount: registros.length,
                  itemBuilder: (context, index) {
                    final r = registros[index];
                    return ListTile(
                      leading: Text(_emojis[r.nivel - 1],
                          style: const TextStyle(fontSize: 24)),
                      title: Text(_etiquetas[r.nivel - 1]),
                      subtitle: r.notas.isNotEmpty ? Text(r.notas) : null,
                      trailing: Text(_formatearFecha(r.fecha),
                          style: const TextStyle(fontSize: 11)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
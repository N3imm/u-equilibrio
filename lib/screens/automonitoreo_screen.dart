
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import '../data/niveles_estres.dart';
import '../services/estres_service.dart';
import '../models/registro_estres.dart';
import '../theme/app_theme.dart';
import '../utils/resumen_estres.dart';
import '../widgets/encabezado_uts.dart';

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

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      await _estresService.guardarRegistro(
        _nivelSeleccionado,
        _notasController.text.trim(),
      );
      _notasController.clear();
      // Vibración corta como confirmación de que se guardó.
      HapticFeedback.lightImpact();
      final textoRacha = await _textoRacha();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registro guardado$textoRacha')),
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

  /// Calcula la racha después de guardar y devuelve el texto para el aviso.
  /// Si algo falla, devuelve vacío: el registro ya se guardó y eso es lo
  /// importante, así que un error aquí no debe mostrarse como error al guardar.
  Future<String> _textoRacha() async {
    try {
      final registros = await _estresService
          .streamRegistros()
          .first
          .timeout(const Duration(seconds: 3));
      final racha = calcularRacha(registros);
      return racha >= 2 ? ' · 🔥 Racha de $racha días' : '';
    } catch (_) {
      return '';
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

  /// Selector de nivel, campo de notas y botón de guardar.
  Widget _formulario() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (i) {
              final nivel = i + 1;
              final seleccionado = nivel == _nivelSeleccionado;
              final color = NivelesEstres.colores[i];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  // Vibración suave al elegir un nivel.
                  HapticFeedback.selectionClick();
                  setState(() => _nivelSeleccionado = nivel);
                },
                child: Column(
                  children: [
                    // El emoji elegido "crece" con un pequeño rebote.
                    AnimatedScale(
                      scale: seleccionado ? 1.3 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutBack,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: seleccionado
                              ? color.withOpacity(0.25)
                              : Colors.transparent,
                          border: Border.all(
                            color: seleccionado ? color : Colors.grey.shade400,
                            width: seleccionado ? 2.5 : 1,
                          ),
                        ),
                        child: Text(
                          NivelesEstres.emojis[i],
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            seleccionado ? FontWeight.bold : FontWeight.normal,
                        color: seleccionado
                            ? ColoresUTS.grisOscuro
                            : ColoresUTS.gris,
                      ),
                      child: Text(NivelesEstres.etiquetas[i]),
                    ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const EncabezadoUTS(
            titulo: '¿Cómo te sientes hoy?',
            subtitulo: 'Elige el nivel que mejor te describe',
          ),
          // Todo lo de abajo se desplaza junto: así nada se desborda
          // cuando aparece el teclado, aunque el encabezado ocupe más espacio.
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _formulario()),
                const SliverToBoxAdapter(child: Divider()),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Text(
                      'Historial',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                StreamBuilder<List<RegistroEstres>>(
                  stream: _estresService.streamRegistros(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const SliverToBoxAdapter(
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
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }
                    final registros = snapshot.data!;
                    if (registros.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text('Todavía no tienes registros'),
                          ),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final r = registros[index];
                          return ListTile(
                            // El emoji va dentro de un círculo del color de su nivel.
                            leading: Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: NivelesEstres.colores[r.nivel - 1]
                                    .withOpacity(0.25),
                              ),
                              child: Text(
                                NivelesEstres.emojis[r.nivel - 1],
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                            title: Text(NivelesEstres.etiquetas[r.nivel - 1]),
                            subtitle: r.notas.isNotEmpty ? Text(r.notas) : null,
                            trailing: Text(
                              _formatearFecha(r.fecha),
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        },
                        childCount: registros.length,
                      ),
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
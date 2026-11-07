
import 'package:flutter/material.dart';
import '../data/niveles_estres.dart';
import '../models/registro_estres.dart';
import '../theme/app_theme.dart';
import '../utils/resumen_estres.dart';

/// Muestra la racha de días seguidos registrando el estado de ánimo y un
/// gráfico de barras con el promedio de cada uno de los últimos 7 días.
class TarjetaSemana extends StatelessWidget {
  final List<RegistroEstres> registros;

  const TarjetaSemana({super.key, required this.registros});

  // Inicial de cada día de la semana. DateTime.weekday: 1 = lunes ... 7 = domingo.
  static const List<String> _iniciales = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  static const double _alturaMaxima = 80;

  String _mensajeRacha(int racha, bool registroHoy) {
    if (racha == 0) return 'Registra cómo te sientes hoy para empezar una racha';
    if (!registroHoy) return 'Registra hoy para no perder tu racha';
    if (racha == 1) return '¡Buen comienzo! Vuelve mañana';
    return '¡Sigue así!';
  }

  Widget _barra(DiaResumen d, bool esHoy) {
    final promedio = d.promedio;
    final altura =
        promedio == null ? 6.0 : _alturaMaxima * (promedio / 5).clamp(0.2, 1.0);
    final color = promedio == null
        ? Colors.grey.shade300
        : NivelesEstres.colores[promedio.round().clamp(1, 5).toInt() - 1];
    final inicial = _iniciales[d.dia.weekday - 1];

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // La barra "crece" desde cero hasta su altura.
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: altura),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, h, _) => Container(
            width: 22,
            height: h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Hoy se resalta con una pastilla verde limón.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: esHoy ? ColoresUTS.verde : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            inicial,
            style: TextStyle(
              fontSize: 12,
              fontWeight: esHoy ? FontWeight.bold : FontWeight.normal,
              color: esHoy ? ColoresUTS.grisOscuro : ColoresUTS.gris,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final racha = calcularRacha(registros);
    final dias = resumenSemanal(registros);
    final registroHoy = dias.last.cantidad > 0;

    final conDatos = dias.where((d) => d.promedio != null).toList();
    String? textoPromedio;
    if (conDatos.isNotEmpty) {
      final suma = conDatos.fold<double>(0, (total, d) => total + d.promedio!);
      final nivel = (suma / conDatos.length).round().clamp(1, 5).toInt();
      textoPromedio = 'Promedio de la semana: '
          '${NivelesEstres.emojis[nivel - 1]} ${NivelesEstres.etiquetas[nivel - 1]}';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 30)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        racha == 0
                            ? 'Sin racha todavía'
                            : '$racha ${racha == 1 ? 'día' : 'días'} seguidos',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _mensajeRacha(racha, registroHoy),
                        style: const TextStyle(color: ColoresUTS.gris),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < dias.length; i++)
                    _barra(dias[i], i == dias.length - 1),
                ],
              ),
            ),
            if (textoPromedio != null) ...[
              const SizedBox(height: 12),
              Text(
                textoPromedio,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ColoresUTS.grisOscuro,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/pausa_activa.dart';
import '../theme/app_theme.dart';
import '../widgets/encabezado_uts.dart';

enum _Estado { inactivo, enCurso, terminado }

/// Una fase del ciclo de respiración (inhalar, sostener o exhalar).
class _Fase {
  final String nombre;
  final int segundos;
  final double escala; // tamaño al que debe llegar el círculo en esta fase

  const _Fase(this.nombre, this.segundos, this.escala);
}

/// Guía visual de respiración: un círculo que se expande al inhalar,
/// se mantiene al sostener y se contrae al exhalar, con cuenta regresiva.
class GuiaRespiracionScreen extends StatefulWidget {
  final PausaActiva pausa;

  const GuiaRespiracionScreen({super.key, required this.pausa});

  @override
  State<GuiaRespiracionScreen> createState() => _GuiaRespiracionScreenState();
}

class _GuiaRespiracionScreenState extends State<GuiaRespiracionScreen> {
  static const double _escalaMaxima = 1.6;

  _Estado _estado = _Estado.inactivo;
  String _instruccion = 'Listo';
  int _segundos = 0;
  int _cicloActual = 0;
  double _escala = 1.0;
  int _duracionAnimacionMs = 600;

  // Cada vez que se inicia, se detiene o se cierra la pantalla, este número
  // cambia. El ciclo en ejecución lo revisa y se detiene si ya no coincide,
  // así nunca quedan dos guías corriendo a la vez.
  int _token = 0;

  List<int> get _ritmo => widget.pausa.ritmo!;

  String get _descripcionRitmo {
    final partes = <String>['Inhala ${_ritmo[0]} s'];
    if (_ritmo[1] > 0) partes.add('Sostén ${_ritmo[1]} s');
    partes.add('Exhala ${_ritmo[2]} s');
    return partes.join('  ·  ');
  }

  Future<void> _comenzar() async {
    final miToken = ++_token;
    final fases = <_Fase>[
      _Fase('Inhala', _ritmo[0], _escalaMaxima),
      if (_ritmo[1] > 0) _Fase('Sostén', _ritmo[1], _escalaMaxima),
      _Fase('Exhala', _ritmo[2], 1.0),
    ];

    setState(() => _estado = _Estado.enCurso);

    for (var ciclo = 1; ciclo <= widget.pausa.ciclos; ciclo++) {
      for (final fase in fases) {
        if (!mounted || miToken != _token) return;
        setState(() {
          _cicloActual = ciclo;
          _instruccion = fase.nombre;
          _escala = fase.escala;
          _duracionAnimacionMs = fase.segundos * 1000;
        });
        // Vibración suave en cada cambio de fase.
        HapticFeedback.lightImpact();

        // Cuenta regresiva: un tic por segundo.
        for (var s = fase.segundos; s >= 1; s--) {
          if (!mounted || miToken != _token) return;
          setState(() => _segundos = s);
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }

    if (!mounted || miToken != _token) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _estado = _Estado.terminado;
      _instruccion = '¡Muy bien!';
      _escala = 1.0;
      _duracionAnimacionMs = 600;
    });
  }

  void _detener() {
    _token++; // invalida el ciclo en ejecución
    setState(() {
      _estado = _Estado.inactivo;
      _instruccion = 'Listo';
      _escala = 1.0;
      _duracionAnimacionMs = 600;
    });
  }

  @override
  void dispose() {
    _token++; // si se cierra la pantalla, el ciclo se detiene
    super.dispose();
  }

  /// El círculo animado. El texto va aparte para que NO se agrande con él.
  Widget _circulo() {
    final duracion = Duration(milliseconds: _duracionAnimacionMs);
    // El círculo interior crece un poco menos que el halo exterior,
    // lo que da sensación de profundidad.
    final escalaInterior = 1.0 + (_escala - 1.0) * 0.75;

    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedScale(
            scale: _escala,
            duration: duracion,
            curve: Curves.easeInOut,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColoresUTS.verde.withOpacity(0.25),
              ),
            ),
          ),
          AnimatedScale(
            scale: escalaInterior,
            duration: duracion,
            curve: Curves.easeInOut,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColoresUTS.verde,
                boxShadow: [
                  BoxShadow(
                    color: ColoresUTS.verde.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _instruccion,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: ColoresUTS.grisOscuro,
                ),
              ),
              if (_estado == _Estado.enCurso)
                Text(
                  '$_segundos',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: ColoresUTS.grisOscuro,
                  ),
                ),
            ],
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
          EncabezadoUTS(
            titulo: widget.pausa.titulo,
            subtitulo: 'Sigue el círculo y respira a su ritmo',
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _circulo(),
                    const SizedBox(height: 16),
                    Text(
                      _descripcionRitmo,
                      style: const TextStyle(color: ColoresUTS.gris),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _estado == _Estado.terminado
                          ? 'Completaste ${widget.pausa.ciclos} ciclos 🎉'
                          : (_estado == _Estado.enCurso
                              ? 'Ciclo $_cicloActual de ${widget.pausa.ciclos}'
                              : '${widget.pausa.ciclos} ciclos en total'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ColoresUTS.grisOscuro,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (_estado == _Estado.enCurso)
                      OutlinedButton.icon(
                        onPressed: _detener,
                        icon: const Icon(Icons.stop_circle_outlined),
                        label: const Text('Detener'),
                      )
                    else
                      SizedBox(
                        width: 220,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _comenzar,
                          icon: Icon(
                            _estado == _Estado.terminado
                                ? Icons.replay
                                : Icons.play_arrow,
                          ),
                          label: Text(
                            _estado == _Estado.terminado
                                ? 'Repetir'
                                : 'Comenzar',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
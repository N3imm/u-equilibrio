
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/niveles_estres.dart';
import '../models/registro_estres.dart';
import '../services/auth_service.dart';
import '../services/estres_service.dart';
import '../theme/app_theme.dart';
import '../widgets/aparecer.dart';
import 'automonitoreo_screen.dart';
import 'pausas_activas_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Saludo según la hora del dispositivo.
  String _saludo() {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Buenos días ☀️';
    if (hora < 19) return 'Buenas tardes 🌤️';
    return 'Buenas noches 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final estresService = EstresService();
    final usuario = authService.usuarioActual;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Íconos claros en la barra de estado, porque el fondo es oscuro.
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              _Encabezado(
                saludo: _saludo(),
                email: usuario?.email ?? '',
                onSalir: () => authService.cerrarSesion(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Aparecer(
                      retrasoMs: 100,
                      child: _TituloSeccion('Tu último registro'),
                    ),
                    const SizedBox(height: 8),
                    Aparecer(
                      retrasoMs: 200,
                      // Se actualiza solo en tiempo real: si guardas un
                      // registro nuevo, esta tarjeta cambia al volver aquí.
                      child: StreamBuilder<List<RegistroEstres>>(
                        stream: estresService.streamRegistros(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const _TarjetaMensaje(
                              emoji: '⚠️',
                              texto: 'No se pudo cargar tu último registro.',
                            );
                          }
                          if (!snapshot.hasData) {
                            return const Card(
                              child: Padding(
                                padding: EdgeInsets.all(28),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            );
                          }
                          final registros = snapshot.data!;
                          if (registros.isEmpty) {
                            return const _TarjetaMensaje(
                              emoji: '🌱',
                              texto: 'Aún no has registrado cómo te sientes. '
                                  '¡Empieza hoy!',
                            );
                          }
                          return _TarjetaUltimoRegistro(
                            registro: registros.first,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Aparecer(
                      retrasoMs: 300,
                      child: _TituloSeccion('¿Qué quieres hacer?'),
                    ),
                    const SizedBox(height: 8),
                    Aparecer(
                      retrasoMs: 400,
                      child: _TarjetaAccion(
                        icono: Icons.mood,
                        titulo: 'Registrar mi estrés de hoy',
                        subtitulo: 'Cuéntanos cómo te sientes',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AutomonitoreoScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    Aparecer(
                      retrasoMs: 500,
                      child: _TarjetaAccion(
                        icono: Icons.self_improvement,
                        titulo: 'Ver pausas activas',
                        subtitulo: 'Ejercicios para relajarte un momento',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PausasActivasScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Encabezado con degradado institucional, saludo y botón de cerrar sesión.
class _Encabezado extends StatelessWidget {
  final String saludo;
  final String email;
  final VoidCallback onSalir;

  const _Encabezado({
    required this.saludo,
    required this.email,
    required this.onSalir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 16,
        8,
        32,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Aparecer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    saludo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ColoresUTS.verde,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: onSalir,
          ),
        ],
      ),
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  final String texto;

  const _TituloSeccion(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: ColoresUTS.grisOscuro,
      ),
    );
  }
}

/// Tarjeta simple con un emoji y un mensaje (estado vacío o de error).
class _TarjetaMensaje extends StatelessWidget {
  final String emoji;
  final String texto;

  const _TarjetaMensaje({required this.emoji, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(child: Text(texto)),
          ],
        ),
      ),
    );
  }
}

/// Muestra el último estado de ánimo registrado, con una barra de nivel
/// que se llena con animación al aparecer.
class _TarjetaUltimoRegistro extends StatelessWidget {
  final RegistroEstres registro;

  const _TarjetaUltimoRegistro({required this.registro});

  String _fechaRelativa(DateTime fecha) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final dia = DateTime(fecha.year, fecha.month, fecha.day);
    final dias = hoy.difference(dia).inDays;
    final hora = '${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}';
    if (dias == 0) return 'Hoy, $hora';
    if (dias == 1) return 'Ayer, $hora';
    return 'Hace $dias días, $hora';
  }

  @override
  Widget build(BuildContext context) {
    final nivel = registro.nivel.clamp(1, 5).toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: NivelesEstres.colores[nivel - 1].withOpacity(0.25),
                  ),
                  child: Text(
                    NivelesEstres.emojis[nivel - 1],
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estrés: ${NivelesEstres.etiquetas[nivel - 1]}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _fechaRelativa(registro.fecha),
                        style: const TextStyle(color: ColoresUTS.gris),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: nivel / 5),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, valor, _) => LinearProgressIndicator(
                  value: valor,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  color: NivelesEstres.colores[nivel - 1],
                ),
              ),
            ),
            if (registro.notas.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '“${registro.notas}”',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: ColoresUTS.gris,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Tarjeta grande y tocable para acceder a una sección de la app.
class _TarjetaAccion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _TarjetaAccion({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Recorta el efecto de toque (ripple) a las esquinas redondeadas.
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: ColoresUTS.verde,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icono, color: ColoresUTS.grisOscuro, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        fontSize: 13,
                        color: ColoresUTS.gris,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: ColoresUTS.gris),
            ],
          ),
        ),
      ),
    );
  }
}
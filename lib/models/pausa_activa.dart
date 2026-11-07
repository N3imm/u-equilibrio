// UBICACIÓN: lib/models/pausa_activa.dart (REEMPLAZA el que ya tenías)

/// Representa una actividad de pausa activa (ejercicio breve
/// para ayudar a reducir el estrés durante la jornada académica).
class PausaActiva {
  final String titulo;
  final String descripcion;
  final int duracionMinutos;
  final String categoria; // 'respiracion', 'estiramiento' o 'general'
  final String? videoUrl; // Video demostrativo opcional (YouTube, en español)

  /// Ritmo de respiración en segundos: [inhalar, sostener, exhalar].
  /// Si es null, la pausa no tiene guía animada. Un 0 en "sostener"
  /// significa que ese tiempo se omite.
  final List<int>? ritmo;

  /// Cuántas veces se repite el ciclo completo en la guía animada.
  final int ciclos;

  const PausaActiva({
    required this.titulo,
    required this.descripcion,
    required this.duracionMinutos,
    required this.categoria,
    this.videoUrl,
    this.ritmo,
    this.ciclos = 4,
  });
}
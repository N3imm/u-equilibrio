
/// Representa una actividad de pausa activa (ejercicio breve
/// para ayudar a reducir el estrés durante la jornada académica).
class PausaActiva {
  final String titulo;
  final String descripcion;
  final int duracionMinutos;
  final String categoria; // 'respiracion', 'estiramiento' o 'general'
  final String? videoUrl; // Video demostrativo opcional (YouTube, en español)

  const PausaActiva({
    required this.titulo,
    required this.descripcion,
    required this.duracionMinutos,
    required this.categoria,
    this.videoUrl,
  });
}